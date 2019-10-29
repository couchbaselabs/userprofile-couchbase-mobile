#!/usr/bin/env bash

cd Frameworks
rm -rf iOS
rm -rf macOS
rm -rf tvOS
curl http://packages.couchbase.com/releases/couchbase-lite-ios/2.6.1/couchbase-lite-swift_enterprise_2.6.1.zip > cbl.zip
unzip -n cbl.zip
rm -rf cbl.zip
rm -rf cbl

