<!--- Do not change the title, otherwise links to
https://github.com/weaveworks/integrations/tree/master/aws/ecs#weaves-ecs-amis
will break -->
# Weave's ECS AMIs

To make [Weave Net](http://weave.works/net), [Weave Run](http://weave.works/run)
and [Weave Scope](http://weave.works/scope) easier to use with
[Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html),
a set of Amazon Machine Images (AMIs) are provided. These AMIs are fully
compatible with the
[ECS-Optimized Amazon Linux AMI](https://aws.amazon.com/marketplace/pp/B00U6QTYI2).

The following are the latest supported Weave AMIs for each region:

<!--- This table is machine-parsed by
https://github.com/weaveworks/guides/blob/master/aws-ecs/setup.sh, please do
not remove it and respect the format! -->

| Region         | AMI          |
|----------------|--------------|
| us-east-1      | ami-c9673fac |
| us-west-1      | ami-a577b4e1 |
| us-west-2      | ami-24db3617 |
| eu-west-1      | ami-bb2b12cc |
| ap-northeast-1 | ami-548fe054 |
| ap-southeast-2 | ami-f75500cd |

## What's in the Weave ECS AMIs?

These latest Weave ECS AMIs are based on Amazon's
[ECS-Optimized Amazon Linux AMI](https://aws.amazon.com/marketplace/pp/B00U6QTYI2),
version `2015.09.a` and also includes:

* [Weave Net and Weave Run 1.2.0](https://github.com/weaveworks/weave/blob/master/CHANGELOG.md#release-120)
* [Weave Scope 0.8.0](https://github.com/weaveworks/scope/blob/master/CHANGELOG.md#release-080)


## Deployment Requirements

### 1. Required open ports

For `Weave Net` and `Weave Run` to function properly, ensure that the Amazon ECS
container instances can communicate over these ports: TCP 6783, as well as, UDP
6783 and UDP 6784.

In addition to those open ports, launching `Weave Scope` in standalone mode,
requires that all instances are able to communicate over TCP port 4040 (more on
this in the `Weave Scope` section below).

See the
[relevant section of the `setup.sh`](https://github.com/weaveworks/guides/blob/c2d25d4cfd766ca739444eea06fefc57aa7a59ff/aws-ecs/setup.sh#L115-L120)
script from
[Service Discovery and Load Balancing with Weave on Amazon ECS](http://weave.works/guides/service-discovery-with-weave-aws-ecs.html)
for an example.

### 2. Additional Amazon ECS API action permissions

Besides the Amazon ECS API actions required by all container instances,
(particularily those indicated in the
[`AmazonEC2ContainerServiceforEC2Role`](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html)
managed policy), to ensure that instance peers can be discovered, any instances
using the Weave ECS AMI also require the following two actions:

1. `ec2:DescribeInstances`
2. `autoscaling:DescribeAutoScalingInstances`

[`weave-ecs-policy.json`](https://github.com/weaveworks/guides/blob/master/aws-ecs/data/weave-ecs-policy.json#L16-L17)
(see the guide
[Service Discovery and Load Balancing with Weave on Amazon ECS](http://weave.works/guides/service-discovery-with-weave-aws-ecs.html)
which describes the minimal policy definition.)

For more information on IAM policies see
[IAM Policies for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-policies-for-amazon-ec2.html).

### 3. Auto Scaling Group Membership

Amazon ECS container instances must be a member of an
[Auto Scaling Group](http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingGroup.html)
to join a Weave network.

## Peer Discovery

At boot time, instances running the ECS Weave AMI form a Weave network with all
the other instances in the same
[Auto Scaling Group](http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/AutoScalingGroup.html).

The `Weave Scope` probes also report back to the apps running in all the instances from the same auto scaling group when
running in standalone mode.

## Weave Scope

There are two methods for running `Weave Scope` within the Weave ECS AMIs:

* [Standalone mode](https://github.com/weaveworks/scope#using-weave-scope-in-standalone-mode) (default)
* [Cloud service mode](https://github.com/weaveworks/scope#using-weave-scope-in-cloud-service-mode)

###Using `Weave Scope` in Standalone Mode

Running `Weave Scope` in standalone mode is the default mode.

The following occurs on all Amazon ECS container instances:

1. A `Weave Scope` probe is launched that collects instance information.
2. A `Weave Scope` app runs that enables cluster visualization.

Since all instances run an app and show the same information, you don't have to
worry about placing the app, thereby eliminating a
[*Leader election problem*](https://en.wikipedia.org/wiki/Leader_election).

However, running the app on all instances impacts performance, resulting in `N *
N = N^2` connections in the Auto Scaling Group with N instances (i.e. all (N)
probes talk to all (N) apps in every instances). To avoid this problem, we
recommend you run `Weave Scope` in cloud service mode.

The `Weave Scope` app runs a web-based application, which listens on TCP port
4040 where you can connect with your browser.

`Weave Scope` probes also forward information to the apps on TCP
port 4040. Ensure that your Amazon ECS container instances can talk to each
other on that port before running `Weave Scope` in standalone mode (see the
[Required open ports](#1.-required-open-ports) for more details).

###Using `Weave Scope` in Cloud Service Mode

In cloud service mode, you can visualize Amazon ECS containers using your
account at [http://scope.weave.works](http://scope.weave.works). For that
purpose, Amazon ECS container instances run a `Weave Scope` probe and reports
data from the container instances to the `Weave Scope` service at
[http://scope.weave.works](http://scope.weave.works).

To configure your ECS container instances to run `Weave Scope` in cloud service
mode, store the `Weave Scope` service token in the`/etc/weave/scope.config`
file.

>Note: The `Weave Scope` service token can be found in your `Weave Scope` service account at [http://scope.weave.works](http://scope.weave.works).

For example, this command configures the instance to start `Weave Scope` in
cloud service mode and to use the `Weave Scope` service token
`3hud3h6ys3jhg9bq66n8xxa4b147dt5z`.

~~~bash
echo SCOPE_AAS_PROBE_TOKEN=3hud3h6ys3jhg9bq66n8xxa4b147dt5z >> /etc/weave/scope.config
~~~

You can do this at instance-initialization time using
[User Data](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts),
which is similar to how
[ECS Cluster Mapping is configured](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html#instance-launch-user-data-step).

<!--- Do not change the title, otherwise links to
https://github.com/weaveworks/integrations/tree/master/aws/ecs#creating-your-own-customized-weave-ecs-ami
will break (e.g. from the ECS guide) -->
## Creating Your Own Customized Weave ECS AMI

Clone the integrations repository and then change to the `packer` directory.

~~~bash
git clone https://github.com/weaveworks/integrations
cd aws/ecs/packer
~~~

Download an SFTP-enabled version of [Packer](https://www.packer.io/) (needed
until https://github.com/mitchellh/packer/pull/2504 is merged) to build the AMI.

~~~bash
wget https://dl.bintray.com/2opremio/generic/packer-sftp_0.8.1_linux_amd64.zip
unzip packer-sftp_0.8.1_linux_amd64.zip -d ~/bin
~~~

Finally, invoke `./build-all-amis.sh` to build the `Weave ECS` images for all
regions. This step installs (in the image) the version of ecs-init we just
built, AWS-CLI, jq, Weave/master, init scripts for `Weave` and it also updates the ECS
agent to use the `Weave Docker API Proxy`.

Customize the image by modifying `template.json` to match your
requirements.

~~~bash
AWS_ACCSS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=YYYY  ./build-all-amis.sh
~~~

If building an AMI for a particular region, set the `ONLY_REGION` variable to
that region when invoking the script:

~~~bash
ONLY_REGION=us-east-1 AWS_ACCSS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=YYYY  ./build-all-amis.sh
~~~

##Further Reading

Read the
[Service Discovery and Load Balancing with Weave on Amazon ECS](http://weave.works/guides/service-discovery-with-weave-aws-ecs.html)
guide for more information about the AMIs.
