#!/bin/bash
# This script print a list of IPs of the EC2 instances in your current Autoscaling Group.
set -eu

aws=/usr/local/bin/aws

export AWS_DEFAULT_REGION=$(curl -s curl http://169.254.169.254/latest/dynamic/instance-identity/document | \
                            jq -r .region)
current_instance_id=$(curl -s curl http://169.254.169.254/latest/meta-data/instance-id)
current_autoscaling_group=$($aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?InstanceId==\`$current_instance_id\`].AutoScalingGroupName"  --output text)

if [ -z "$current_autoscaling_group" ]; then
  >&2 echo "instance doesn't belong to an autoscaling group"
  exit 1
fi

peer_instances=$($aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[? AutoScalingGroupName==\`$current_autoscaling_group\` && InstanceId!=\`$current_instance_id\`].InstanceId" --output text)

if [ -z "$peer_instances" ]; then
# no peers found
  exit 0
fi

peer_ips=$($aws ec2 describe-instances --instance-ids $peer_instances --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress' --output text)
echo $peer_ips

