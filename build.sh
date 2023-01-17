#!/bin/bash

set -e

SVN_URL="svn://svn.code.sf.net/p/floreantpos/code/trunk"

INSTALL_PACKAGES=("maven" "openjdk-8-jdk" "openjdk-8-doc" "openjdk-8-jre" "subversion")
REMOVE_PACKAGES=("openjdk-11-jre-headless")

WORKDIR="/workdir"
SOURCE_DIR="$WORKDIR/floreantpos_source"
BUILD_DIR="$WORKDIR/floreantpos_builds"

echo "Updating apt cache"
apt update

for i in "${INSTALL_PACKAGES[@]}"
do
  apt -y install $i
done

for i in "${REMOVE_PACKAGES[@]}"
do
  apt -y purge $i
done

mkdir -p "$SOURCE_DIR"
if [ ! -d "$SOURCE_DIR"/.svn ]; then
  echo "Subversion repo does not exist. Cloning..."
  svn checkout "$SVN_URL" "$SOURCE_DIR"
else
  echo "Subversion repo exists. Updating"
  svn up "$SOURCE_DIR"
fi

echo "Starting build..."
cd $SOURCE_DIR
mvn clean install -Dmaven.buildNumber.skip -f"pom.xml"
mvn package -Dmaven.buildNumber.skip -f"pom.xml"
cd $WORKDIR

echo "Build finished. Copying..."
mkdir -p $BUILD_DIR
BUILD_NAME=build-`date +"%m-%d-%Y-%T"`.zip
cp $SOURCE_DIR/target/floreantpos-*.zip $BUILD_DIR/$BUILD_NAME
echo "Done. Build is at $BUILD_DIR/$BUILD_NAME"
