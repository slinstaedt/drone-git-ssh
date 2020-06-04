# Drone plugin for cloning git repos via ssh

Usage via *.drone.yml*:
```
kind: pipeline
name: default

clone:
  disable: true

steps:
  - name: clone
    image: kamalook/drone-git-ssh
    settings:
      git_key: { from_secret: git-key }
      ssh_config_strict_host_key_checking: accept-new
```
