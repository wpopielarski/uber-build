# Uber build script for Scala IDE

> One build script to rule them all.

Build script design to unify all compound builds needed around [Scala IDE][scala-ide].
It supports rebuilding everything from source, starting from Scala all the way to the product,
as well as producing the Scala IDE release or providing CI support for the Scala pull requests
validator.

The main usages are:

* generate the Scala IDE releases (IDE, plugins and bundle), with or without publishing.
* check integration of Scala IDE and the plugins nighlty.
* perform Scala IDE builds as part of the Scala pull request validator
* rebuild Scala pr validation builds locally, to study failures
* build Scala IDE against any custom version of Scala, to test changes made to the compiler

The current build works for Scala 2.10.x and 2.11.x, and Scala IDE 4.0.x.


[scala-ide]: https://github.com/scala-ide/scala-ide/
[worksheet]: https://github.com/scala-ide/scala-worksheet/

## Invocation

```bash
./uber-build <config_file> [scala_version] [scala_git_hash]
```

* `config_file` - the config file containing the build parameters. The uncommented lines override the values from `config/default.conf`.
* `scala_git_hash` - overrides the value `SCALA_GIT_HASH` defined in the config file.
* `scala_version` overrides the value `SCALA_VERSION` defined in the config file.

## scala-local-build

Builds Scala IDE from any source version of Scala.

* base config file: `scala-local-build.conf`
* relevant config parameters:
  * `SCALA_GIT_REPO` - modify to use Scala hash from a different repository
* extra command line parameters: `<scala_version> <scala_git_hash>`

## release, release-dryrun

Generates and publishes (only with `release`) a Scala IDE release, build on a released version of Scala.

* example config files: `release-30x.conf`, `release-40x-210.conf`
* relevant config parameters:
  * `OPERATION` - keep it, and commit with, `release-dryrun` most of the time. Switch to `release` only when doing the real release, after having done a successful dryrun.
  * `SCALA_VERSION` - the version of Scala to use
  * `SCALA_IDE_VERSION_TAG` - `b?` for special builds, `m?` for milestones, `rc?` for RCs, `v` for final versions.
  * `*_GIT_BRANCH` - the source to use for each project. Should be a tag when doing the publishing.
  * `*_GIT_REPO` - usefull to test tags or small fixes on your forks, before pushing the changes to the main repos.
* no extra command line parameters

## nightly

Builds all Scala IDE projects from the master branches. Used nightly to check that all masters build together.

* example config files: `nightly-4.0.x-juno-2.10.conf`
* relevant config parameters:
  * `*_GIT_BRANCH` - all should be on `master`
  * `PLUGINS` - list the plugins to build, all plugins may no work with all configurations.
* no extra command line parameters

## scala-pr-validator

Runs a build up to Scala IDE. The goal is to check that a Scala PR is not going to break Scala IDE and its dependencies.
(to document)

* config file: `validator.conf`
* config parameters should not be modified.
* This build requires an extra maven repository to fetch pre-build Scala binaries. The simplest way to set it up
is to add the following in the `~/.m2/settings.xml` file.
```xml
    <profile>
      <id>pr-scala</id>
      <repositories>
        <repository>
          <id>scala-pr-builds</id>
          <url>http://private-repo.typesafe.com/typesafe/scala-pr-validation-snapshots/</url>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
      </repositories>
    </profile>
```
* to enable the profile, extra Maven parameters are needed. Use:
```bash
export MAVEN_ARGS="-Ppr-scala"
```
* extra command line parameters: `<scala_version>`


## scala-pr-rebuild

(to document)


