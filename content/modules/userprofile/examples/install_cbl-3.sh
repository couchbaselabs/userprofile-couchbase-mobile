#!/usr/bin/env bash

cd Frameworks
rm -rf iOS
rm -rf macOS
rm -rf tvOS
curl http://latestbuilds.service.couchbase.com/builds/latestbuilds/couchbase-lite-ios/3.0.0/210/couchbase-lite-swift_enterprise_3.0.0-210.zip > cbl.zip
unzip -n cbl.zip
rm -rf cbl.zip
rm -rf cbl
