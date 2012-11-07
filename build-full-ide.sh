#!/bin/bash -e

# Build IDE and all it's dependencies

ECLIPSE=/Applications/Programming/eclipse-indigo/eclipse

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
TYPESAFE_KEYSTORE=typesafe-keystore

if [[ -z $VERSION_TAG ]]; then
	VERSION_TAG=local
fi

REPO_SUFFIX=210x
LOCAL_REPO=`pwd`/m2repo

base_dir=`pwd`

# What files can have uncommitted changes?
IGNORED_FILES_REGEX='plugin-signing\|\.classpath'

function validate_java()
{
	(java -version 2>&1 | grep \"1.6.*\")
	if [[ $? -ne 0 ]]; then
		echo -e "Invalid Java version detected. Only java 1.6 is supported due to changes in jarsigner in 1.7\n"
		java -version
		exit 1
	fi
}

#
# Check that there are no uncommitted changes in $1
# 
function validate()
{
  (
  	cd $1
	git diff --name-only | grep -v ${IGNORED_FILES_REGEX} > /dev/null
  )
  RET=$?
  if [[ $RET -eq 0 ]]; then
  	echo -e "\nYou have uncommitted changes in $1:\n"
  	(cd $1 && git diff --name-status | grep -v ${IGNORED_FILES_REGEX})
  	echo -e "\nAborting mission."
  	exit 1
  fi 
}

function print_step()
{
	cat <<EOF

==================================================================
                     Building $1
==================================================================

EOF
}

set_version()
{
    mvn -f pom.xml -N versions:set -DnewVersion=$1
    mvn -f pom.xml -N versions:update-child-modules
}

function describe()
{
	(cd $1 && git describe --all)
}

############## Diagnostics ###################

case $SCALA_VERSION in
	2.10.0-SNAPSHOT )
		maven_toolchain_profile=sbt-2.10
		scala_profile_ide=scala-2.10.x
		REPO_SUFFIX=210x
		;;

	2.10.0-M* )
		maven_toolchain_profile=sbt-2.10
		scala_profile_ide="scala-2.10.x"
		REPO_SUFFIX=210x
		;;

	2.10.0-RC* )
		maven_toolchain_profile=sbt-2.10
		scala_profile_ide="scala-2.10.x"
		REPO_SUFFIX=210x
		;;


	2.9* )
		maven_toolchain_profile=sbt-2.9
		scala_profile_ide=scala-2.9.x
		REPO_SUFFIX=29x
		;;

	*)
		echo "Unknown scala version ${SCALA_VERSION}"
		exit 1
esac

SOURCE=${base_dir}/p2-repo
PLUGINS=${SOURCE}/plugins
REPO_NAME=scala-eclipse-toolchain-osgi-${REPO_SUFFIX}
REPO=file:${SOURCE}/${REPO_NAME}

echo -e "Build configuration:"
echo -e "-----------------------\n"
echo -e "Sbt: \t\t\t${sbt}"
echo -e "Scala version: \t\t${SCALA_VERSION}"
echo -e "Version tag: \t\t${VERSION_TAG}"
echo -e "P2 repo: \t\t${SOURCE}"
echo -e "Toolchain repo: \t${REPO}"

echo -e "Scala IDE:  \t\t`describe dragos-scala-ide`"
echo -e "Scalariform:\t\t`describe scalariform`"
echo -e "Scala-refactoring:\t`describe scala-refactoring`"
echo -e "-----------------------\n"

############## Helpers #######################

function build_sbinary()
{
	# build sbinary
	print_step "sbinary"

	cd ${SBINARY_DIR}

	# maven style for the toolchain build
	$sbt "reboot full" clean "show scala-instance" "set every crossScalaVersions := Seq(\"${SCALA_VERSION}\")" \
	 'set every publishMavenStyle := true' \
	 'set every resolvers := Seq("Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots")' \
	 'set every publishTo := Some(Resolver.file("Local Maven",  new File(Path.userHome.absolutePath+"/.m2/repository")))' \
	 'set every crossPaths := true' \
	 +core/publish \
	 +core/publish-local # ivy style for xsbt


	cd ${base_dir}
}

function build_xsbt()
{
	# build sbt
	print_step "xsbt"

	cd ${SBT_DIR}
	$sbt "reboot full" clean \
	"set every crossScalaVersions := Seq(\"${SCALA_VERSION}\")" \
	'set every publishMavenStyle := true' \
	'set every resolvers := Seq("Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots")' \
	'set artifact in (compileInterfaceSub, packageBin) := Artifact("compiler-interface")' \
    'set every publishTo := Some(Resolver.file("Local Maven",  new File(Path.userHome.absolutePath+"/.m2/repository")))' \
	'set every crossPaths := true' \
	+classpath/publish +logging/publish +io/publish +control/publish +classfile/publish \
	+process/publish +relation/publish +interface/publish +persist/publish +api/publish \
	 +compiler-integration/publish +incremental-compiler/publish +compile/publish +compiler-interface/publish

	cd ${base_dir}
}

function build_toolchain()
{
	# build toolchain
	print_step "build-toolchain"

	MAVEN_ARGS="-P ${scala_profile_ide} clean install"
	rm -rf ${SOURCE}/*

	cd ${SCALAIDE_DIR}
	mvn -Dscala.version=${SCALA_VERSION} ${MAVEN_ARGS}

	cd org.scala-ide.build-toolchain
	mvn -Dscala.version=${SCALA_VERSION} ${MAVEN_ARGS}

	cd ../org.scala-ide.toolchain.update-site
	mvn -Dscala.version=${SCALA_VERSION} ${MAVEN_ARGS}

	# make toolchain repo

	rm -Rf ${SOURCE}/plugins
	mkdir -p ${PLUGINS}

	cp org.scala-ide.scala.update-site/target/site/plugins/*.jar ${PLUGINS}
	
	print_step "p2 toolchain repo"

	$ECLIPSE \
	-debug \
	-consolelog \
	-nosplash \
	-verbose \
	-application org.eclipse.equinox.p2.publisher.FeaturesAndBundlesPublisher \
	-metadataRepository ${REPO} \
	-artifactRepository ${REPO} \
	-source ${SOURCE} \
	-compress \
	-publishArtifacts

	cd ${base_dir}
}

function build_refactoring()
{
	# build scala-refactoring
	print_step "scala-refactoring"

	cd ${SCALA_REFACTORING_DIR}
	GIT_HASH="`git log -1 --pretty=format:"%h"`"
	${MAVEN} -Dscala.version=${SCALA_VERSION} -P ${scala_profile_ide} -Drepo.scala-ide="file:/${SOURCE}" -Dmaven.test.skip=true -Dgit.hash=${GIT_HASH} clean package

	cd $base_dir

	# make scala-refactoring repo

	REPO_NAME=scala-refactoring-${REPO_SUFFIX}
	REPO=file:${SOURCE}/${REPO_NAME}

	rm -Rf ${SOURCE}/plugins
	cp -R scala-refactoring/org.scala-refactoring.update-site/target/site/plugins ${SOURCE}/

	$ECLIPSE \
	-debug \
	-consolelog \
	-nosplash \
	-verbose \
	-application org.eclipse.equinox.p2.publisher.FeaturesAndBundlesPublisher \
	-metadataRepository ${REPO} \
	-artifactRepository ${REPO} \
	-source ${SOURCE} \
	-compress \
	-publishArtifacts

	cd ${base_dir}
}

function build_scalariform()
{
	# build scalariform
	print_step "scalariform"
	cd ${SCALARIFORM_DIR}

	GIT_HASH="`git log -1 --pretty=format:"%h"`"
	
	${MAVEN} -Dscala.version=${SCALA_VERSION} -P ${scala_profile_ide} -Drepo.scala-ide="file:/${SOURCE}" -Dgit.hash=${GIT_HASH} clean package

	rm -rf ${SOURCE}/scalariform-${REPO_SUFFIX}
	mkdir ${SOURCE}/scalariform-${REPO_SUFFIX}
	cp -r scalariform.update/target/site/* ${SOURCE}/scalariform-${REPO_SUFFIX}/

	cd ${base_dir}
}

function build_ide()
{
	print_step "Building the IDE"
	cd ${SCALAIDE_DIR}

	./build-all.sh -P ${scala_profile_ide} -Dscala.version=${SCALA_VERSION} -Drepo.scala-ide.root="file:${SOURCE}" -Dversion.tag=${VERSION_TAG} clean install
	cd ${base_dir}
}

function sign_plugins()
{
	print_step "Signing"
	cd ${SCALAIDE_DIR}/org.scala-ide.sdt.update-site
	./plugin-signing.sh ${base_dir}/${TYPESAFE_KEYSTORE}/typesafe.keystore typesafe ${KEYSTORE_PASS} ${KEYSTORE_PASS}
	cd ${base_dir}
}

############## Build #########################

export MAVEN_OPTS="-Xmx1500m"

validate_java
validate ${SBINARY_DIR}
validate ${SBT_DIR}
validate ${SCALARIFORM_DIR}
validate ${SCALA_REFACTORING_DIR}
validate ${SCALAIDE_DIR}

build_sbinary
build_xsbt
build_toolchain
build_refactoring
build_scalariform
build_ide
sign_plugins
