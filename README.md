# Uber build script for Scala IDE

Build script for [Scala IDE][scala-ide] (it also builds all its dependencies), the
[Worksheet][worksheet] plugin and the Typesafe IDE product.

# Usage

The script requires you to export a number of variables to correctly work (I'd highly
recommend to skim through the script before running it, if this is the first time you
are using it). If you open the script, at the top you will see a list of variables
declarations with a short description of the intended usage. Many of the variables needs
to be correctly initialized for the script to be working correctly. Failing to provide a
value will result in an error during the script execution.

At a high-level, variables are split into four groups:

* Executables that are required to correctly run the script.
* Values required to sign the script (optionals).
* GitHub repositories and branch/tag names for all projects that need to be built by the script.
* Scala version to use to build the projects (and to bundle in the Scala IDE).

For instance, the following command builds a signed Scala IDE build of M3 with Scala
2.10.0 for Eclipse 3.7 (Indigo), a signed worksheet based on the freshly built Scala IDE,
and a Typesafe IDE (v2.1-M3) product based on the built Scala IDE and Worksheet:

	./build-full-ide.sh ECLIPSE_PLATFORM=indigo VERSION_TAG=m3 SBT_GIT_REPO=git://github.com/scala-ide/xsbt.git SCALA_VERSION=2.10.0 SCALARIFORM_GIT_REPO=git://github.com/scala-ide/scalariform.git SCALA_REFACTORING_GIT_REPO=https://github.com/scala-ide/scala-refactoring SCALA_IDE_BRANCH=2.1.0-m3 SCALARIFORM_BRANCH=scala-ide-2.1.0-m3 SCALA_REFACTORING_BRANCH=RELEASE-0.6.0 SBT_BRANCH=scala-ide-2.1.0-m3 SBINARY_BRANCH=scala-ide-2.1.0-m3 WORKSHEET_BRANCH=0.1.3 SIGN_BUILD=true BUILD_PLUGINS=true TYPESAFE_IDE_VERSION_TAG=2.1-M3 KEYSTORE_GIT_REPO=<provive-git-url-to-keystore> KEYSTORE_PASS=<provide-keystore-password>

While, for building the exact same distribution, but for Eclipse 4.2 (Juno), the above
command would only need to be slightly changed, as follow:

	./build-full-ide.sh ECLIPSE_PLATFORM=juno VERSION_TAG=m3 SBT_GIT_REPO=git://github.com/scala-ide/xsbt.git SCALA_VERSION=2.10.0 SCALARIFORM_GIT_REPO=git://github.com/scala-ide/scalariform.git SCALA_REFACTORING_GIT_REPO=https://github.com/scala-ide/scala-refactoring SCALA_IDE_BRANCH=2.1.0-m3-juno SCALARIFORM_BRANCH=scala-ide-2.1.0-m3 SCALA_REFACTORING_BRANCH=RELEASE-0.6.0 SBT_BRANCH=scala-ide-2.1.0-m3 SBINARY_BRANCH=scala-ide-2.1.0-m3 WORKSHEET_BRANCH=0.1.3 SIGN_BUILD=true BUILD_PLUGINS=true TYPESAFE_IDE_VERSION_TAG=2.1-M3 KEYSTORE_GIT_REPO=<provive-git-url-to-keystore> KEYSTORE_PASS=<provide-keystore-password>

Finally, to produce a nightly (unsigned) build of the Scala IDE with Scala 2.10.1-SNAPSHOT
alone, for Eclipse 3.7 (Indigo), run the following:

	./build-full-ide.sh ECLIPSE_PLATFORM=indigo VERSION_TAG=nightly SBT_GIT_REPO=git://github.com/scala-ide/xsbt.git SCALA_VERSION=2.10.1-SNAPSHOT SCALARIFORM_GIT_REPO=git://github.com/scala-ide/scalariform.git SCALA_REFACTORING_GIT_REPO=https://github.com/scala-ide/scala-refactoring SCALA_IDE_BRANCH=master SCALARIFORM_BRANCH=scala-ide-2.1.0-m3 SCALA_REFACTORING_BRANCH=RELEASE-0.6.0 SBT_BRANCH=scala-ide-2.1.0-m3 SBINARY_BRANCH=scala-ide-2.1.0-m3

## Assumptions

There are actually very few assumptions, and the script will usually provide specific
errors if you forget to set a required variable. Probably, the only real assumption worth
mentioning is that the different projects have to be built in a specific order, and this
order is implicitly defined in the script itself.

## Warning Note

When you launch the script, **all checked out repositories will be cleaned out and
synched with the remote before building their content**. Implying that all local changes
are lost, forever.

[scala-ide]: https://github.com/scala-ide/scala-ide/
[worksheet]: https://github.com/scala-ide/scala-worksheet/