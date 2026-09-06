#!/bin/sh
# Maven Wrapper script (POSIX shell)
# Downloads the Maven version specified in .mvn/wrapper/maven-wrapper.properties
# into ~/.m2/wrapper/dists and runs it, so you don't need Maven installed locally.
set -e

WRAPPER_DIR="$(cd "$(dirname "$0")" && pwd)"
PROPS_FILE="$WRAPPER_DIR/.mvn/wrapper/maven-wrapper.properties"

DIST_URL=$(grep '^distributionUrl=' "$PROPS_FILE" | cut -d'=' -f2-)
DIST_NAME=$(basename "$DIST_URL" .zip)
CACHE_DIR="$HOME/.m2/wrapper/dists/$DIST_NAME"
MAVEN_HOME="$CACHE_DIR/apache-maven"

if [ ! -x "$MAVEN_HOME/bin/mvn" ]; then
  echo "Maven distribution not found locally, downloading: $DIST_URL"
  mkdir -p "$CACHE_DIR"
  TMP_ZIP="$CACHE_DIR/maven-dist.zip"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$TMP_ZIP" "$DIST_URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$TMP_ZIP" "$DIST_URL"
  else
    echo "ERROR: need curl or wget to download Maven." >&2
    exit 1
  fi
  mkdir -p "$MAVEN_HOME"
  unzip -q "$TMP_ZIP" -d "$CACHE_DIR"
  EXTRACTED_DIR=$(find "$CACHE_DIR" -maxdepth 1 -type d -name "apache-maven-*")
  rm -rf "$MAVEN_HOME"
  mv "$EXTRACTED_DIR" "$MAVEN_HOME"
  rm -f "$TMP_ZIP"
fi

exec "$MAVEN_HOME/bin/mvn" "$@"
