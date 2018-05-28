# Docker Image for Build Android

[![Docker Automated buil](https://img.shields.io/docker/automated/dingdayu/android-ci.svg)](https://hub.docker.com/r/dingdayu/android-ci/)
[![Docker Pulls](https://img.shields.io/docker/pulls/dingdayu/android-ci.svg)](https://hub.docker.com/r/dingdayu/android-ci/)

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
  only:
    tags
  artifacts:
    paths:
    - app/build/outputs/
```

## Add `app/version.properties`

```file
# The base build number used in CI build
VERSION_CI_BASE_BUILD=100
# The following lines are only used in manually build
VERSION_MINOR=2
VERSION_BUILD=99
VERSION_PATCH=5
VERSION_MAJOR=1
```

File at: [app/version.properties](app/version.properties)

## Edit `app/build.gradle`

Under `compileSdkVersion 26` add:

```gradle
    def versionString, versionBuild  // 版本字符串和版本号
    def runTasks = gradle.startParameter.taskNames  // 获取gradle的启动任务列表
    if (':app:assembleRelease' in runTasks || 'assembleRelease' in runTasks) {  // 检查是否为Release构建
        def versionPropsFile = file('version.properties')  // 检查version.properties文件是否存在
        if (!versionPropsFile.canRead()) {
            throw new Exception('Could not read version.properties!')
        }
        // 加载version.properties
        def Properties versionProps = new Properties()
        versionProps.load(new FileInputStream(versionPropsFile))
        def versionMajor, versionMinor, versionPatch
        if (System.getenv('GITLAB_CI') == null) {  // 判断是否在Gitlab CI中运行
            println '[VERSIONING] Build manually...'
            // 从version.properties中读取所有版本信息
            versionMajor = versionProps['VERSION_MAJOR']
            versionMinor = versionProps['VERSION_MINOR']
            versionPatch = versionProps['VERSION_PATCH']
            versionBuild = versionProps['VERSION_BUILD'].toInteger()
        } else {
            println '[VERSIONING] Build automatically...'
            // 获取tag字符串
            def tag = System.getenv('CI_COMMIT_TAG')
            if (tag == null) {
                throw new Exception('[VERSIONING] Only tagged build is supported in automatic build')
            }
            // 从tag字符串中提取版本号
            (versionMajor, versionMinor, versionPatch) = tag.trim().replace('v', '').split('\\.')
            // 从CI_PEPELINE_ID获取Build，并加上一个值以避免和现有版本冲突
            versionBuild = System.getenv('CI_PIPELINE_ID').toInteger() + versionProps['VERSION_CI_BASE_BUILD'].toInteger()
        }
        // 构建versionString
        versionString = "${versionMajor}.${versionMinor}.${versionPatch}"
    } else {  // Debug下默认填充versionString和versionBuild
        versionBuild = Integer.MAX_VALUE
        versionString = '0.0.0'
    }

```

update `defaultConfig`

```gradle
    defaultConfig {
        applicationId "com.dingdayu.hello"
        minSdkVersion 15
        targetSdkVersion 26
        versionCode versionBuild
        versionName versionString
        multiDexEnabled true
        archivesBaseName = "app-${versionString}-${versionBuild}"  // 设置APK文件名
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
```

File at: [app/build.gradle](app/build.gradle)
