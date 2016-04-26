#!/bin/bash
set -eu
# This script prints the list of Weave peers (IPs) of the EC2 instance executing the script.
# The peers are identified as follows:
# If the current instance is tagged with weave:peerGroupName=VALUE -> all other instances tagged as weave:peerGroupName=VALUE
# Otherwise, all the other instances in the same Autoscaling Group (default)

aws=/usr/local/bin/aws


export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
current_instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

PEER_GROUP_NAME=$($aws ec2 describe-instances --instance-ids $current_instance_id --query 'Reservations[0].Instances[0].Tags[?Key==`weave:peerGroupName`].Value' --output text)

if [ -n "$PEER_GROUP_NAME" ]; then
    peer_instances=$($aws ec2 describe-tags --filters "Name=resource-type,Values=instance,Name=tag:weave:peerGroupName,Values=$PEER_GROUP_NAME" --query "Tags[?ResourceId!=\`$current_instance_id\`].ResourceId" --output text)

else
    current_autoscaling_group=$($aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?InstanceId==\`$current_instance_id\`].AutoScalingGroupName"  --output text)

    if [ -z "$current_autoscaling_group" ]; then
	>&2 echo "instance doesn't belong to an autoscaling group"
	exit 1
    fi

    peer_instances=$($aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[? AutoScalingGroupName==\`$current_autoscaling_group\` && InstanceId!=\`$current_instance_id\`].InstanceId" --output text)
fi


if [ -z "$peer_instances" ]; then
# no peers found
  exit 0
fi

peer_ips=$($aws ec2 describe-instances --instance-ids $peer_instances --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress' --output text)
echo $peer_ips

