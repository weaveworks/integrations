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
