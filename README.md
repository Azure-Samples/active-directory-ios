#Microsoft Azure Active Directory Native Client for iOS (iPhone)


This sample shows how to build an iOS application that calls a web API that requires a Work Account for authentication. This sample uses the Active Directory authentication library for iOS to do the interactive OAuth 2.0 authorization code flow with public client.

**What is a Work Account?**

*A Work Account is an identity you use to get work done no matter if at your business or on a college campus. Anywhere you need to get access to your work life you'll use a Work Account. The Work Account can be tied to an Active Directory server running in your datacenter or live completely in the cloud like when you use Office365. A Work Account will be how your users know that they are accessing their important documents and data backed my Microsoft security.*


## Quick Start

Getting started with the sample is easy. It is configured to run out of the box with minimal setup. If you'd like a more detailed walkthrough including how to setup the REST API and register an Azure AD Directory follow the walk-through here.

### Step 1: Download the iOS B2C Native Client Sample code

* `$ git clone git@github.com:AzureADSamples/NativeClient-iOS.git`

### Step 2: Download Cocoapods (if you don't already have it)

CocoaPods is the dependency manager for Swift and Objective-C Cocoa projects. It has thousands of libraries and can help you scale your projects elegantly. To install on OS X 10.9 and greater simply run the following command in your terminal:

`$ sudo gem install cocoapods`

### Step 3: Build the sample and pull down ADAL for iOS automatically

Run the following command in your terminal:

`$ pod install`

This will download and build ADAL for iOS for you and configure your Microsoft Tasks B2C.xcodeproj to use the correct dependencies.

You should see the following output:

```
$ pod install
Analyzing dependencies

Pre-downloading: `ADALiOS` from `https://github.com/AzureAD/azure-activedirectory-library-for-objc.git`, branch `B2C-ADAL`
Downloading dependencies
Installing ADALiOS (1.2.2)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `Microsoft Tasks.xcworkspace` for this project from now on.
```
### Step 4: Run the application in Xcode

Launch XCode and load the `Microsoft Tasks.xcworkspace` file. The application will run in an emulator as soon as it is loaded.


#### Step 5. Determine what your Redirect URI will be for iOS

In order to securely launch your applications in certain SSO scenarios we require that you create a **Redirect URI** in a particular format. A Redirect URI is used to ensure that the tokens return to the correct application that asked for them.

The iOS format for a Redirect URI is:

```
<app-scheme>://<bundle-id>
```

- 	**aap-scheme** - This is registered in your XCode project. It is how other applications can call you. You can find this under Info.plist -> URL types -> URL Identifier. You should create one if you don't already have one or more configured.
- 	**bundle-id** - This is the Bundle Identifier found under "identity" un your project settings in XCode.

An example would be: ***mstodo://com.microsoft.windowsazure.activedirectory.samples.microsofttasks***

### Step 6: Configure the settings.plist file with your Web API information

You will need to configure your application to work with the Azure AD tenant you've created. Under "Supporting Files"you will find a settings.plist file. It contains the following information:

```XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>authority</key>
	<string>https://login.microsoftonline.com/common</string>
	<key>clientId</key>
	<string>xxxxxxx-xxxxxx-xxxxxxx-xxxxxxx</string>
	<key>resourceString</key>
	<string>https://localhost/todolistservice</string>
	<key>redirectUri</key>
	<string>mstodo://com.microsoft.windowsazure.activedirectory.samples.microsofttasks</string>
	<key>userId</key>
	<string>user@domain.com</string>
	<key>taskWebAPI</key>
	<string>https://localhost/api/todolist/</string>
</dict>
</plist>
```

Replace the information in the plist file with your Web API settings.

##### NOTE

The current defaults are set up to work with our [Azure Active Directory Sample REST API Service for Node.js](https://github.com/AzureADSamples/WebAPI-Nodejs). You will need to specify the clientID of your Web API, however. If you are running your own API, you will need to update the endpoints as required.
