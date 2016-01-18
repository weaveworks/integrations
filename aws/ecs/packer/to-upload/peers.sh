#!/bin/bash
# This script print a list of IPs based on
#   1) TAG: this will match IPs for instances that have matching values for that Tag key set in /etc/weave/weave.config under
#        the environment variable WEAVE_AWS_PEER_TAG
#   2) Autoscaling Group: if this instance is part of an autoscaling group, this will return IPs for its peers
#   3) Spot Fleet: Finally, if this instance is part of a spot fleet, this will return IPs for all instances in the fleet
set -eu

if [ -e '/etc/weave/weave.config' ]; then
  source /etc/weave/weave.config
fi

WEAVE_AWS_PEER_TAG="${WEAVE_AWS_PEER_TAG:-}"

__awscli=
__instance_id=
__region=
__instance_autoscaling_group=
__peer_autoscaling_instance_ids=
__list_of_active_spot_fleets=
__spot_fleet_request_id=
__peer_spot_fleet_instance_ids=
__peer_private_ips=
__peer_tag_instance_ids=

check_data() {
  if [[ "${1}x" == "x" ]]; then
    return 1
  fi
}

check_exit() {
  if [[ "${1}" != "0" ]]; then
    >&2 echo "${FUNCNAME[1]} Exited with a nonzero status"
    exit 2
  fi
}

get_from_curl() {
  local __endpoint="${1}"
  local __retry_attempts=3
  local __retry_delay=1
  local __retries=0
  local __retval=
  # the metadata service occasionally returns empty with a 200 status, so retry a couple times just in case (very rare)
  while true; do
    local __retval=$(curl -s "http://169.254.169.254/latest/${__endpoint}")
    if check_data "${__retval}"; then
      break
    else
      sleep "${__retry_delay}"
      __retries=$(( __retries + 1 ))
      if [[ "${__retries}" -eq "${__retry_attempts}" ]]; then
        >&2 echo "${FUNCNAME[0]} WARNING: Curl could not reach metadata for latest/${__endpoint}"
        exit # Not necessarily a problem but bail out, i.e. reboot: https://github.com/weaveworks/integrations/issues/20
      fi
    fi
  done
  printf "${__retval}"
}

get_region() {
  if ! check_data "${__region}"; then
    __region="$(get_from_curl "meta-data/placement/availability-zone" | sed 's/[a-z]\+$//g'; check_exit "${PIPESTATUS[1]}")"
    if ! check_data "${__region}"; then
      >&2 echo "${FUNCNAME[0]} ERROR Could not find region!"
      exit 2
    fi
  fi
}

get_instance_id() {
  if ! check_data "${__instance_id}"; then
    __instance_id="$(get_from_curl "meta-data/instance-id")"
    if ! check_data "${__instance_id}"; then
      >&2 echo "${FUNCNAME[0]} ERROR Could not find instance_id!"
      exit 2
    fi
  fi
}

get_awscli() {
  if ! check_data "${__awscli}"; then
    get_region
    local system_awscli="$(which aws)"
    if ! check_data "${system_awscli}"; then system_awscli="/usr/local/bin/aws"; fi
    if ! $system_awscli --version > /dev/null 2>&1; then
      >&2 echo "${FUNCNAME[0]}: Could not find aws-cli"
      exit 2
    fi
    __awscli="${system_awscli} --region ${__region} "
  fi
}

get_instance_autoscaling_group() {
  if ! check_data "${__instance_autoscaling_group}"; then
    get_awscli
    get_instance_id
    local __autoscaling_group_filter="AutoScalingInstances[?InstanceId == '${__instance_id}'].AutoScalingGroupName"
    __instance_autoscaling_group="$(${__awscli} autoscaling describe-auto-scaling-instances --query "${__autoscaling_group_filter}" --output text)"
    if ! check_data "${__instance_autoscaling_group}"; then
      >&2 echo "${FUNCNAME[0]}: WARNING Instance does not belong to an autoscaling group"
      return 1
    fi
  fi
}

get_autoscaling_peer_instance_ids() {
  if ! check_data "${__peer_autoscaling_instance_ids}"; then
    get_awscli
    if get_instance_autoscaling_group; then
      get_instance_id
      local __peer_instances_filter="AutoScalingInstances[?AutoScalingGroupName == '${__instance_autoscaling_group}']|[?InstanceId != '${__instance_id}'].InstanceId"
      __peer_autoscaling_instance_ids="$(${__awscli} autoscaling describe-auto-scaling-instances --query "${__peer_instances_filter}" --output text)"
      check_exit $?
      if ! check_data "${__peer_autoscaling_instance_ids}"; then
        >&2 echo "${FUNCNAME[0]}: WARNING autoscaling group has no other instances"
        return 1
      fi
    else
      return 1
    fi
  fi
}

get_list_of_active_spot_fleets() {
  if ! check_data "${__list_of_active_spot_fleets}" ;then
    get_awscli
    local __spot_fleet_active_filter="SpotFleetRequestConfigs[?SpotFleetRequestState == 'active'].SpotFleetRequestId"
    __list_of_active_spot_fleets="$(${__awscli} ec2 describe-spot-fleet-requests --query "${__spot_fleet_active_filter}" --output text)"
    check_exit $?
    if ! check_data "${__list_of_active_spot_fleets}"; then
      >&2 echo "${FUNCNAME[0]}: WARNING There are no active spot fleets"
      return 1
    fi
  fi
}

get_spot_fleet_request_id() {
  if ! check_data "${__spot_fleet_request_id}"; then
    get_awscli
    get_instance_id
    if get_list_of_active_spot_fleets; then
      local __spot_fleet_instance_filter="ActiveInstances[?InstanceId == '${__instance_id}'].InstanceId"
      for spot_fleet_id in "${__list_of_active_spot_fleets}"; do
        local __possible_spot_fleet="$(${__awscli} ec2 describe-spot-fleet-instances --spot-fleet-request-id "${spot_fleet_id}" --query "${__spot_fleet_instance_filter}" --output text)"
        if [ "${__possible_spot_fleet}" == "${__instance_id}" ]; then
          __spot_fleet_request_id="${spot_fleet_id}"
          break
        fi
      done
      if ! check_data "${__spot_fleet_request_id}"; then
        >&2 echo "${FUNCNAME[0]} WARNING Spot Fleet ID not found.. must not be in a spot fleet"
        return 1
      fi
    else
      return 1
    fi
  fi
}

get_peer_spot_fleet_instance_ids() {
  if ! check_data "${__peer_spot_fleet_instance_ids}"; then
    get_awscli
    if get_spot_fleet_request_id; then
      get_instance_id
      local __peer_instances_filter="ActiveInstances[?InstanceId != '${__instance_id}'].InstanceId"
      __peer_spot_fleet_instance_ids="$(${__awscli} ec2 describe-spot-fleet-instances --spot-fleet-request-id "${__spot_fleet_request_id}" --query "${__peer_instances_filter}" --output text)"
      check_exit $?
      if ! check_data "${__peer_spot_fleet_instance_ids}"; then
        >&2 echo "${FUNCNAME[0]} WARNING No other instances found in spot fleet: ${__spot_fleet_request_id}"
        return 1
      fi
    else
      return 1
    fi
  fi
}

# IF instance has a KEY ${WEAVE_AWS_PEER_TAG} find all the others like it
#
# i.e. if this instance is tagged WEAVE_ECS=prod this will get all the other instance ids that have that key/value pair
get_peer_tag_instance_ids() {
  if ! check_data "${__peer_tag_instance_ids}"; then
    get_instance_id
    get_awscli
    if check_data "${WEAVE_AWS_PEER_TAG}"; then
      local __instance_tag_filter="Reservations[].Instances[?InstanceId == '${__instance_id}'].Tags[][?Key == '${WEAVE_AWS_PEER_TAG}'].Value"
      local __keyval=
      __keyval=$(${__awscli} ec2 describe-instances --filters "Name=tag-key,Values=${WEAVE_AWS_PEER_TAG}" --query "${__instance_tag_filter}" --output text)
      if check_data "${__keyval}"; then
        local __instance_ids_filter="Name=tag-key,Values=${WEAVE_AWS_PEER_TAG},Name=tag-value,Values=${__keyval}"
        local __instance_ids_query="Reservations[].Instances[?InstanceId != '${__instance_id}'].InstanceId"
        __peer_tag_instance_ids=$(${__awscli} ec2 describe-instances --filters "${__instance_ids_filter}" --query "${__instance_ids_query}" --output text)
        if ! check_data "${__peer_tag_instance_ids}"; then
          >&2 echo "${FUNCNAME[0]} WARNING No other instances found with tag ${WEAVE_AWS_PEER_TAG}=${__keyval}"
          return 1
        fi
      else
        return 1
      fi
    else
      >&2 echo "${FUNCNAME[0]} WARNING WEAVE_AWS_PEER_TAG not set in /etc/weave/weave.config"
      return 1
    fi
  fi
}

get_peer_private_ips() {
  if ! check_data "${__peer_private_ips}"; then
    get_awscli
    local __instance_ids=
    if get_peer_tag_instance_ids; then
      __instance_ids="${__peer_tag_instance_ids}"
    elif get_autoscaling_peer_instance_ids; then
      __instance_ids="${__peer_autoscaling_instance_ids}"
    elif get_peer_spot_fleet_instance_ids; then
      __instance_ids="${__peer_spot_fleet_instance_ids}"
    else
      return 1
    fi
    local __peer_ip_filter="Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress"
    __peer_private_ips="$(${__awscli} ec2 describe-instances --instance-ids ${__instance_ids} --query "${__peer_ip_filter}" --output text)"
    check_exit $?
  fi
}

if get_peer_private_ips; then
  echo "${__peer_private_ips}" | tr '\n' ' '
  echo
else
  >&2 echo "${FUNCNAME[0]}: Could not get peer IP's"
  exit 1
fi

