# Docker Image for Build Android

安卓自动化继承Docker

## Edit gitlab-run/config.toml

Modify the configuration file: `/etc/gitlab-runner/config.toml` Add `pull_policy = "if-not-present"` under the corresponding runner node.

```
[[runners]]
  name = "Android Build Runner"
  url = "https://git.xyser.com/"
  token = "3dc54666cacafd************e"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "alpine:latest"
    privileged = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
    // 加入这行
    pull_policy = "if-not-present"
  [runners.cache]
```

## Example .gitlab-ci.yml file

Please add your required sdk package with sdkmanager command, see example below.

```yaml
image: dingdayu/android-ci

stages:
  - test
  - build

before_script:
  - export GRADLE_USER_HOME=`pwd`/.gradle
  - chmod +x ./gradlew
  - sdkmanager "platforms;android-22"         # Specify compileSdkVersion Depends on your android project
  - sdkmanager "build-tools;25.0.3"           # Specify build tool to install, depends on your android project
  - sdkmanager "extras;android;m2repository"  # You can add sdkmanager command to install another package here
  - sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" # If you need constraint-layout support

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - .gradle/

test:
  stage: test
  script:
     - ./gradlew check

build:
  stage: build
  script:
  - ./gradlew assemble --stacktrace
  artifacts:
    paths:
    - app/build/outputs/
```