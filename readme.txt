Thank you for your interest in the iKeyboard Server.

The The iKeyboard Server is service for i Keyboard customer keyboard of iOS 8 server.
The i Keyboard client run in iOS 8 can connect the iKeyboard Server communicate with, when the client connected to the server, that can send message from iKeyboard Server to the iKeyboard client, and also it is iKeyboard client can send message to the server.

The iKeyboard server only a service for the Client(Customer Keyboard) for internet. but the service also can setup with in any platform, like Windows/Linux/Mac OS, develop an application the use TCP/IP is can transfer message with the iOS 8 Customer keyboard(iKeyboard) client.
 
Many improvements can be made and not all patches and updates have been applied to this conversion.
If you would like the help, feel free to join the iKeyboard project and submit your improvements and bugfixes.
If you have questions, please send them to the iKeyboard newsgroup.

by Shadow.Zhou(Yuanping.Zhou)


Build Instructions
------------------

Building iKeyboard 0.01.000 code requires:

* Cocoa.framework
* AppKit.framework
* CoreData.framework
* Foundation.framework


Setup
-----

1. Please add all these frameworks into KeyboardServer project.
2. Define Keyboard project environment variable with Mac OS X 10.7 or above On Mac :
3. Setup build shell script.
   Define the distribution folder
   *DISTRO_FOLDER=KeyboardServerDebug
   Define the distribution zip file		
   *DISTRO_ZIP=KeyboardServer.zip
   Define the distribution app name
   *OUTPUT_APP=KeyboardServer.app
   Define the build 
   *xcodebuild -project $CURDIR/keyboardServer/KeyboardServer.xcodeproj -target KeyboardServer
4.#copy this simulator build for Emulator
cp -R $CURDIR/KeyboardServer/build/Release/${OUTPUT_APP} $CURDIR/${DISTRO_FOLDER}/
5.Run in Mac OSX
  *Double click the KeyboardServer.app   
Building Keyboard Debug
------------------

To build keyboard.debug, run ant:
$ cd SupperKeyboard/Mac/
$ sudo ./KeyboardServer.sh

Run……
Method1
$ cd SupperKeyboard/Mac/KeyboardServerDebug/
$ cd KeyboardServer.app/Contents/MacOS/
$ sudo KeyboardServer
Method2
*Enter into KeyboardServerDebug
*Double click KeyboardServer.app
*Running…..


Shadow Zhou(Zhou Yuanping)
ypshadow.zhou@gmail.com
15 Sep.2014