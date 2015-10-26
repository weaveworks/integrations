## Weaveworks ECS Image (2015-10-26)

Bug fixes:
- Really bundle Weave 1.2
  [#33](https://github.com/weaveworks/integrations/issues/33)

## Weaveworks ECS Image (2015-10-22)

New features:
- Update base images to the latest version (2015.09.a)
  [#30](https://github.com/weaveworks/integrations/pull/10)
- Use Weave 1.2 (**EDIT**: not really, the 2015-10-26 release fixes this)
  [#31](https://github.com/weaveworks/integrations/pull/18)

Bug fixes:
- Weave proxy unexpectedly closes the connection when spawning the ecs-agent.
  (implicitly fixed by upgrading to Weave 1.1.2, see
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
