# Weave's ECS AMIs

So that [Weave Net](http://weave.works/net), [Weave Run](http://weave.works/run)
and [Weave Scope](http://weave.works/scope) can be used *out of the box* in
[Amazon's ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html),
we provide a set of AMIs which are fully compatible with the
[ECS-Optimized Amazon Linux AMI](https://aws.amazon.com/marketplace/pp/B00U6QTYI2).

The following are the latest supported Weave AMIs for each region:

<!--- This table is machine-parsed by
https://github.com/weaveworks/guides/blob/master/aws-ecs/setup.sh, please do
not remove it and respect the format! -->

| Region         | AMI          |
|----------------|--------------|
| us-east-1      | ami-5f8ce33a |
| us-west-1      | ami-81c53fc5 |
| us-west-2      | ami-13766b23 |
| eu-west-1      | ami-1b9abb6c |
| ap-northeast-1 | ami-dee863de |
| ap-southeast-2 | ami-cf1e51f5 |


## Build Your Own Weave ECS AMI


Clone the integrations repository and go to the `packer` directory.

```bash
git clone http://github.com/weaveworks/integrations
cd aws/ecs/packer
```

Download an SFTP-enabled version of [Packer](https://www.packer.io/) (needed
until https://github.com/mitchellh/packer/pull/2504 is merged) to build the AMI.

```bash
wget https://dl.bintray.com/2opremio/generic/packer-sftp_0.8.1_linux_amd64.zip
unzip packer-sftp_0.8.1_linux_amd64.zip -d ~/bin
```

Finally, invoke `./build-all-amis.sh` to build `Weave ECS` images for all
regions. This step installs (in the image) the version of ecs-init we just
built, AWS-CLI, jq, Weave/master, init scripts for Weave and it also updates the ECS
agent to use weaveproxy.

Customize the image by modifying `template.json` to match your
requirements.

```bash
AWS_ACCSS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=YYYY  ./build-all-amis.sh
```

If you only want to build an AMI for a particular region, set `ONLY_REGION` to
that region when invoking the script:

```bash
ONLY_REGION=us-east-1 AWS_ACCSS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=YYYY  ./build-all-amis.sh
```
