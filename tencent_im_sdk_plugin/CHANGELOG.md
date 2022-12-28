## 5.0.4
* update native sdk

## 5.0.3
* [Incompatible update] Multimedia messages no longer return url by default, and need to be obtained through getMessageOnlineUrl
* [Partially incompatible update] Multimedia messages will not return localurl by default, and will only return after the message is successfully downloaded through downloadMessage
* Add onMessageDownloadProgressCallback to advanceMessageListener, which will be triggered when the multimedia message download progress is updated
* The disableBadgeNumber method is added on the ios side. After calling, the IMSDK is in the background of the application, and the application badge will not be set by default.
* Optimized the problem of channel instance coverage in multiple flutter engine scenarios
* The bottom dynamic library download logic is optimized on the PC side
* Upgrade the underlying SDK to 6.8

## 4.2.0
* Fix invite api miss offlinepushInfo


## 4.1.9
* Fix high version jdk conversion problem
* Support macOS and Windows
* Upgrade the underlying SDK
* Support message extension
* Support signaling editing
* Fixed several issues

## 4.1.3
* flutter for web 

## 4.1.1+2
* Upgrade native SDK to 6.6.x
* web signal support
* flutter for web support

## 4.1.0
* Upgrade native SDK
* Fix iOS search group member bug
* web sdk only supports the latest version

## 4.0.8-bugfix
* fix modifyMessage bug on Android

## 4.0.8
* Added an advanced interface for obtaining sessions, which supports pulling sessions by session type, tag, and grouping
* Support marked sessions, such as star, fold, hide, etc.
* Support setting session custom fields
* Support session grouping
* The SDK dependency flutter version is reduced to 2.0.0
* Support multiple flutter engines
* Offline push support to configure Android push sound
* Support subscriber online status change by user id
* Fix the bug that the group information cannot be found in the topic group
* Upgrade the native sdk version to 6.5

## 4.0.7
* ios newly added front-end and back-end api, cut back-end can set the unread to the corner mark
* Optimize group application processing logic

## 4.0.5
* Fix doBackgroup bug

## 4.0.5
* Fix upload token bug

## 4.0.4
* Support user online status query
* Get the list of historical messages and support pulling by message type
* Fix thread safety issues in special cases
* Support sending multi-element messages

## 4.0.3-bugfix
* fix InitSDKListener bug

## 4.0.2
* Local video url bug fix

## 4.0.1
* Added topic related interface
* Added message editing interface

## 4.0.0
* Upgrade the underlying SDK version to 6.2.x
* fix offlinePush info bug

## 3.9.3
* Upgrade the underlying SDK version to 6.2.x
* Fix the problem that the group ban group tips boolValue is lost
* Fixed the problem that the nameCard field was not parsed for session instances
* Added group read receipt related interface
* flutter for web perfect

## 3.9.2
* Upgrade the ios library version to 6.1.2155.1

## 3.9.1
* Upgrade the underlying library version to 6.1.2155

## 3.9.0
* Modify grouplistener

## 3.8.9
* Monitor registration problem fix

## 3.8.8
* Monitor registration problem fix

## 3.8.7
* Modify add friends enumeration
