DAFGU Migration Status
======================

This is a small menu bar application that can change its icon into one of four states:

* kDMStatusUnknown (0) - Translucent gray
* kDMStatusOK (1)      - Happy green
* kDMStatusError (2)   - Angry red
* kDMStatusActive (3)  - Pulsating orange

If you click on it it'll also show a status message. We use it to display the status of the last backup.


Compiling
---------

The project is configured to build a universal app for 10.5+ with Xcode 3.2. If you change to a newer SDK you can also build it on Xcode 4, but then you'll lose support for 10.5 and PPC.


Usage
-----

The app opens a socket under /tmp and waits for messages in the form of a plist encoded NSDictionary, with the following keys:

* DAFGUMigrationStatus (NSInteger, 0-3)
* DAFGUMigrationMessage (NSString, max 100 chars)

Sample code to set the status can be found in <code>test/socketclient.py</code>:

    # ./test/socketclient.py 3 'Look at me go!'
    Sending message to /tmp/se.gu.it.dafgu_migration_status.4079eab9040e62e4


Version History
---------------

* 1.2
    * Changed IPC to unix domain sockets, as shared objects don't work across different bootstrap contexts.
    * Added smooth image scaling for 10.5.
* 1.1
    * Changed IPC to shared objects, as watching plists uses too much CPU.
    * Added animation for active status.
* 1.0
    * Initial release.


License
-------

    Copyright 2012 Per Olofsson, University of Gothenburg
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
