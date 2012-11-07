# Uber build script for Scala IDE

Build script for Scala IDE and all its dependencies. It produces an update site with signed plugins.

# Usage

Set `VERSION_TAG` and `SCALA_VERSION` before running this script. For instance, the following command builds an IDE build of M2 with Scala 2.10.0-RC2:

    VERSION_TAG=m2 SCALA_VERSION=2.10.0-RC2 build-full-ide.sh 

## Assumptions

* all dependencies are checked out and available on the file system
  * [sbinary](https://github.com/scala-ide/sbinary)
  * [xsbt](https://github.com/harrah/xsbt)
  * [scalariform](https://github.com/scala-ide/scalariform)
  * [scala-refactoring](https://github.com/scala-ide/scala-refactoring)
  * [scala-ide](https://github.com/scala-ide/scala-ide)
  * typesafe-keystore (if you have the certificate for signing)
* `plugin-signing.sh` has the correct path to an Eclipse installation

## Features

* Builds **whatever the user has checked out** for each dependency
* Checks and aborts if there are *uncommitted* changes in any checkout
* Validates the Java version (currently only Java 1.6 is supported, 1.7 uses an different algorithm for signing that is incompatible with Eclipse)
* Signs the plugins at the end. You need to have some certificate available


# Configuration

Before running it for the first time, make sure you go through the variables at the top of the file:

	#!/bin/bash -e

	# Build IDE and all it's dependencies

	ECLIPSE=/Applications/Programming/eclipse-indigo/eclipse
	#SCALA_VERSION=2.10.0-SNAPSHOT

	# Password to the keystore
	KEYSTORE_PASS=

	# Command to run SBT
	sbt="xsbt"

	## Where does each module reside on the filesystem, relative to the current directory?

	SCALAIDE_DIR=dragos-scala-ide
	SCALARIFORM_DIR=scalariform
	SCALA_REFACTORING_DIR=scala-refactoring
	SBINARY_DIR=sbinary
	SBT_DIR=xsbt
	TYPESAFE_KEYSTORE=${base_dir}/typesafe-keystore
