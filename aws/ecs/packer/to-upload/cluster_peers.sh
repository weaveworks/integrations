#!/bin/bash
# This script prints a list of IPs of the EC2 instances in your cluster.
# You should:
#   - provide the ECS_CLUSTER var in the /etc/ecs/ecs.config file;
#   - tag the autoscaling groups with Key=cluster; Value=<ECS cluster name>.

set -eu

aws=/usr/local/bin/aws

export AWS_DEFAULT_REGION=$(curl -s curl http://169.254.169.254/latest/dynamic/instance-identity/document | \
                            jq -r .region)

if [ ! -e /etc/ecs/ecs.config ]; then
  >&2 echo "there's no ECS config file"
  exit 1
fi

source /etc/ecs/ecs.config

if [ -z "$ECS_CLUSTER" ]; then
  >&2 echo "there's no ECS cluster defined"
  exit 1
fi

current_instance_id=$(curl -s curl http://169.254.169.254/latest/meta-data/instance-id)

peer_ids=$($aws autoscaling describe-auto-scaling-groups --no-paginate | \
  jq -r ".AutoScalingGroups[] | select(.Tags[].Key==\"cluster\" and .Tags[].Value==\"$ECS_CLUSTER\") | .Instances | .[] | select(.InstanceId != \"$current_instance_id\") | .InstanceId")

if [ -z "$peer_ids" ]; then
  # no peers found
  exit 0
fi

peer_ips=$($aws ec2 describe-instances --instance-ids $peer_ids | \
  jq -r '.Reservations | .[] | .Instances | .[] | .NetworkInterfaces | .[] | .PrivateIpAddress')

echo $peer_ips | tr '\n' ' '
echo
