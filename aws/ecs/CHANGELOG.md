## Weaveworks ECS Image (2016-09-22)

New features:
- Update base AMIs to 2016.03.i and Weave Version to 1.6.2 [#108](github.com/weaveworks/integrations/pull/108)

## Weaveworks ECS Image (2016-08-22)

New features:
- Upgrade Weave Net to version 1.6.1, Weave Scope to version 0.17.1 and update base AMI to version `2016.03.g` [#105](github.com/weaveworks/integrations/pull/105)

## Weaveworks ECS Image (2016-06-21)

New features:
- Upgrade Weave Net to version 1.6.0 and Weave Scope to version 0.16.0 [#98](github.com/weaveworks/integrations/pull/98)

## Weaveworks ECS Image (2016-06-10)

New features:
- Upgrade base AMI to `2016.03.c`, upgrade Weave Net to version 1.5.2 and Weave Scope to version 0.15.0 [#94](github.com/weaveworks/integrations/pull/94)


## Weaveworks ECS Image (2016-04-25)

New features:
- Upgrade base AMI to `2016.03.a`, upgrade Weave Net to version 1.5.0 and Weave Scope to version 0.14.0 [#91](https://github.com/weaveworks/integrations/pull/91)
- Use upstream packer [#90](https://github.com/weaveworks/integrations/pull/90)

Bug fixes:
- Launch Weave Scope correctly in Service mode [31e2c2640](https://github.com/weaveworks/integrations/commit/31e2c26405f52b3731684369185d9c868a08d281)

## Weaveworks ECS Image (2016-03-08)

New features:
- Use weave:peerGroupName tag to identify peers [#75](https://github.com/weaveworks/integrations/pull/75)
- Discover Weave Apps using the Weave Network [#79](https://github.com/weaveworks/integrations/pull/79)
- Upgrade base AMI to `2015.09.g` [#81](https://github.com/weaveworks/integrations/pull/82)
- Upgrade Weave Net to version 1.4.5 [#80](https://github.com/weaveworks/integrations/pull/80)
- Upgrade Weave Scope to version 0.13.1 [#78](https://github.com/weaveworks/integrations/pull/78)


## Weaveworks ECS Image (2016-01-15)

New features:
- Upgrade base AMI to `2015.09.d`
- Upgrade Weave Net to version 1.4.2 [#57](https://github.com/weaveworks/integrations/pull/57)

## Weaveworks ECS Image (2015-12-17.b)

Bug fixes:
- Really make sure Weave Scope starts after Weave Net
  [#51](https://github.com/weaveworks/integrations/issues/51)


## Weaveworks ECS Image (2015-12-17)

New features:
- Upgrade base AMI to `2015.09.c` and include two new regions (eu-central-1 and ap-southeast-1)
  [#47](https://github.com/weaveworks/integrations/pull/47)
- Upgrade Weave Net/Run to version 1.4.0
  [#46](https://github.com/weaveworks/integrations/pull/46)
- Upgrade Weave Scope to version 0.11.1
  [#49](https://github.com/weaveworks/integrations/pull/49)


## Weaveworks ECS Image (2015-11-23)

New features:
- Upgrade base AMI to `2015.09.b`
  [#39](https://github.com/weaveworks/integrations/pull/39)
- Upgrade Weave Net/Run version 1.3.1 and Weave Scope to version 0.10.0
  [#38](https://github.com/weaveworks/integrations/pull/38)

Bug fixes:
- Scope won't be able to inspect the Weave network if started after Weave
  [#35](https://github.com/weaveworks/integrations/issues/35)


## Weaveworks ECS Image (2015-10-26)

Bug fixes:
- Really bundle Weave 1.2
  [#33](https://github.com/weaveworks/integrations/issues/33)

## Weaveworks ECS Image (2015-10-22)

New features:
- Update base images to the latest version (2015.09.a)
  [#30](https://github.com/weaveworks/integrations/pull/10)
- Use Weave 1.2 (**EDIT**: not really, the 2015-10-26 release fixes this)
  [#31](https://github.com/weaveworks/integrations/pull/31)

Bug fixes:
- Weave proxy unexpectedly closes the connection when spawning the ecs-agent.
  (implicitly fixed by upgrading to Weave 1.2, see
  [weave/#1514](https://github.com/weaveworks/weave/issues/1514))


## Weaveworks ECS Image (2015-10-07)

New features:
- Update base images to the latest version (2015.03.g).
  [#10](https://github.com/weaveworks/integrations/pull/10)
- Make Upstart jobs more robust
  [#2](https://github.com/weaveworks/integrations/issues/2)
- Use Scope 0.8.0
  [#7](https://github.com/weaveworks/integrations/pull/7)
- Use Weave 1.1.1
  [#18](https://github.com/weaveworks/integrations/pull/18)

Bug fixes:
- `/etc/init/ecs.conf` gets overwritten when upgrading the ecs-init package
  [#4](https://github.com/weaveworks/integrations/issues/4)
- ECS doesn't stop correctly
  [#11](https://github.com/weaveworks/integrations/issues/11)
- Upstart hangs on ECS' pre-start if Weave couldn't start
  [#16](https://github.com/weaveworks/integrations/issues/16)
- Start ECS only after Weave proxy is ready to take requests
  [#13](https://github.com/weaveworks/integrations/issues/13)
