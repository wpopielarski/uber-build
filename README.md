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
./uber-build <config_file> [scala_git_hash] [scala_version]
```

* `config_file` - the config file containing the build parameters. The uncommented lines override the values from `config/default.conf`.
* `scala_git_hash` - overrides the value `SCALA_GIT_HASH` defined in the config file.
* `scala_version` overrides the value `SCALA_VERSION` defined in the config file.

## scala-local-build

Builds Scala IDE from any source version of Scala.

* base config file: `scala-local-build.conf`
* relevant config parameters:
  * `SCALA_GIT_REPO` - modify to use Scala hash from a different repository
* extra command line parameters: `<scala_git_hash> <scala_version>`

## release, release-dryrun

Generate and publish (only with `release`) a Scala IDE release, build on a released version of Scala.

* example config files: `release-30x.conf`, `release-40x-210.conf`
* relevant config parameters:
  * `OPERATION` - keep it, and commit with, `release-dryrun` most of the time. Switch to `release` only when doing the real release, after having done a successful dryrun.
  * `SCALA_VERSION` - the version of Scala to use
  * `SCALA_IDE_VERSION_TAG` - `b?` for special builds, `m?` for milestones, `rc?` for RCs, `v` for final versions.
  * `*_GIT_BRANCH` - the source to use for each project. Should be a tag when doing the publishing.
  * `*_GIT_REPO` - usefull to test tags or small fixes on your forks, before pushing the changes to the main repos.
* no extra command line parameters

## nightly

Build all Scala IDE projects from the master branches. Used nightly to check that all masters build together.

* example config files: `nightly-4.0.x-juno-2.10.conf`
* relevant config parameters:
  * `*_GIT_BRANCH` - all should be on `master`
  * `PLUGINS` - list the plugins to build, all plugins may no work with all configurations.
* no extra command line parameters

## scala-pr-validator

(to document)

## scala-pr-rebuild

(to document)


