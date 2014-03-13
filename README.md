#Windows Azure Active Directory Native Client for iOS (iPhone/iPad)


This sample shows how to build an iOS application that calls a web API that requires Azure AD for authentication. This sample uses the Active Directory authentication library for iOS to do the OAuth 2.0 authorization code flow with public client.

## Quick Start

Getting started with the sample is easy. It is configured to run out of the box with minimal setup. 

### Step 1: Register a Windows Azure AD Tenant

To use this sample you will need a Windows Azure Active Directory Tenant. If you're not sure what a tenant is or how you would get one, read [What is a Windows Azure AD tenant](http://technet.microsoft.com/library/jj573650.aspx)? or [Sign up for Windows Azure as an organization](http://www.windowsazure.com/en-us/manage/services/identity/organizational-account/). These docs should get you started on your way to using Windows Azure AD.

### Step 2: Register your Web API with your Windows Azure AD Tenant

After you get your Windows Azure AD tenant, add this sample app to your tenant so you can use it to protect your API endpoints. If you need help with this step, see: [Register the REST API Service Windows Azure Active Directory](https://github.com/WindowsAzureAD/Azure-AD-TODO-Server-Sample-For-Node/wiki/Setup-Windows-Azure-AD)

### Step 3: Download and run either the .Net or Node.js REST API TODO Sample Server

This sample is written specifically to work against our existing sample for building a single tenant ToDo REST API for Windows Azure Active Directory. This is a pre-requisite for the Quick Start.

For information on how to set this up, visit our existing samples here:

* [Windows Azure Active Directory Sample REST API Service for Node.js](https://github.com/WindowsAzureADSamples/WebAPISingleOrg-Nodejs-Dev)
* [Windows Azure Active Directory Sample Web API Single Sign-On for .Net](https://github.com/WindowsAzureADSamples/WebAppExistingCallWebAPISingleOrg-DotNet-Dev)

### Step 3: Download the iOS Native Client Sample code

* `$ git clone git@github.com:WindowsAzureADSamples/NativeClientCallWebAPISingleOrg-iOS-Dev.git`
 
### Step 4: Configure the settings.plist file with your Web API information

Under "Supporting Files"you will find a settings.plist file. It contains the following information:

```XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>authority</key>
	<string>https://login.windows.net/common/oauth2/token</string>
	<key>clientId</key>
	<string>xxxxxxx-xxxxxx-xxxxxxx-xxxxxxx</string>
	<key>resourceString</key>
	<string>https://localhost/todolistservice</string>
	<key>redirectUri</key>
	<string>http://demo_todolist_app</string>
	<key>userId</key>
	<string>user@domain.com</string>
	<key>taskWebAPI</key>
	<string>https://localhost/api/todolist/</string>
</dict>
</plist>
```

Replace the information in the plist file with your Web API settings. 

##### NOTE

The current defaults are set up to work with our [Windows Azure Active Directory Sample REST API Service for Node.js](https://github.com/WindowsAzureADSamples/WebAPISingleOrg-Nodejs-Dev). You will need to specify the clientID of your Web API, however. If you are running your own API, you will need to update the endpoints as required.

### Step 6: Build and Run the application

You should be able to connect to the REST API endpoint and be prompted with the credentials from your Windows Azure Active Directory account.



