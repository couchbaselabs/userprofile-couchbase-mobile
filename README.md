## Overview
This repo hosts a bunch of sample iOS apps in swift that demonstrate various features of the Couchbase Mobile 2.0 stack. 
Each app is hosted in a separate branch.

### "master" branch
Hosts this README 

### "standalone" branch
[Link](https://github.com/couchbaselabs/userprofile-couchbase-mobile/tree/standalone)

This branch hosts app that demonstrates basic Database and Document operations using Couhbase Lite as a standalone , embedded database within your mobile app. In this mode, Couchbase Lite can be used as a replacement for SQLIte or Core Data

### "query" branch
[Link](https://github.com/couchbaselabs/userprofile-couchbase-mobile/tree/query)

This branch hosts app that demonstrates basic query and full-text-search operations using Couhbase Lite as a standalone , embedded database within your mobile app.  In this mode, Couchbase Lite can be used as a replacement for SQLIte or Core Data

### "sync" branch
[Link](https://github.com/couchbaselabs/userprofile-couchbase-mobile/tree/sync)

This branch hosts an app supports syncing of documents between Couchbase Lite database and remote Sync Gateway . 

### "background" branch
[Link](https://github.com/couchbaselabs/userprofile-couchbase-mobile/tree/backgroundfetch)

This branch hosts an app that supports the IOS background fetch mode. It does a one-shot replication with the remote Sync Gateway when woken up in the background 
