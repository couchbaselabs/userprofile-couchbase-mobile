#!/usr/bin/env bash

PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

pushd $PARENT_PATH

rm -rf iOS
rm -rf macOS
rm -rf tvOS
curl http://latestbuilds.service.couchbase.com/builds/latestbuilds/couchbase-lite-ios/3.0.0/345/couchbase-lite-swift_xc_enterprise_3.0.0-345.zip > cbl.zip
unzip -n cbl.zip
rm -rf cbl.zip
rm -rf cbl

popd

