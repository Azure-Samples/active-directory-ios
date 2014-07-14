#Microsft Azure Active Directory Native Client for iOS (iPhone/iPad)


This sample shows how to build an iOS application that calls a web API that requires a Work Account for authentication. This sample uses the Active Directory authentication library for iOS to do the interactive OAuth 2.0 authorization code flow with public client.

**What is a Work Account?**

*A Work Account is an identity you use to get work done no matter if at your business or on a college campus. Anywhere you need to get access to your work life you'll use a Work Account. The Work Account can be tied to an Active Directory server running in your datacenter or live completely in the cloud like when you use Office365. A Work Account will be how your users know that they are accessing their important documents and data backed my Microsoft security.*


## Quick Start

Getting started with the sample is easy. It is configured to run out of the box with minimal setup. 

### Step 1: Register a Microsoft Azure AD Tenant

To use this sample you will need a Microsoft Azure Active Directory Tenant. If you're not sure what a tenant is or how you would get one, read [What is a Windows Azure AD tenant](http://technet.microsoft.com/library/jj573650.aspx)? or [Sign up for Windows Azure as an organization](http://www.windowsazure.com/en-us/manage/services/identity/organizational-account/). These docs should get you started on your way to using Windows Azure AD.


### Step 2: Download and run either the .Net or Node.js REST API TODO Sample Server

This sample is written specifically to work against our existing sample for building a single tenant ToDo REST API for Microsoft Azure Active Directory. This is a pre-requisite for the Quick Start.

For information on how to set this up, visit our existing samples here:

* [Microsoft Azure Active Directory Sample REST API Service for Node.js](https://github.com/AzureADSamples/WebAPI-Nodejs)
* [Microsoft Azure Active Directory Sample Web API Single Sign-On for .Net](https://github.com/AzureADSamples/NativeClient-DotNet)

### Step 3: Register your Web API with your Microsoft Azure AD Tenant

**What am I doing?**   

*Microsoft Active Directory supports adding two types of applications. Web APIs that offer services to users and applications (either on the web or an applicaiton running on a device) that access those Web APIs. In this step you are registering the Web API you are running locally for testing this sample. Normally this Web API would be a REST service that is offering functionaltiy you want an app to access. Microsoft Azure Active Directory can protect any endpoint!* 

*Here we are assuming you are registering the TODO REST API referenced above, but this works for any Web API you'd want Azure Active Directory to protect.*

Steps to register a Web API with Microsoft Azure AD

1. Sign in to the [Azure management portal](https://manage.windowsazure.com).
2. Click on Active Directory in the left hand nav.
3. Click the directory tenant where you wish to register the sample application.
4. Click the Applications tab.
5. In the drawer, click Add.
6. Click "Add an application my organization is developing".
7. Enter a friendly name for the application, for example "TodoListService", select "Web Application and/or Web API", and click next.
8. For the sign-on URL, enter the base URL for the sample, which is by default `https://localhost:8080`.
9. For the App ID URI, enter `https://<your_tenant_name>/TodoListService`, replacing `<your_tenant_name>` with the name of your Azure AD tenant.  Click OK to complete the registration.
10. While still in the Azure portal, click the Configure tab of your application.
11. **Find the Client ID value and copy it aside**, you will need this later when configuring your application.
12. Using the Manage Manifest button in the drawer, download the manifest file for the application.
13. Add a permission to the application by replacing the appPermissions section with the block of JSON below.  You will need to create a new GUID and replace the example permissionId GUID.
14. Using the Manage Manfiest button, upload the updated manifest file.  Save the configuration of the app.

```JSON
"appPermissions": [
{
	"claimValue": "user_impersonation",
	"description": "Allow full access to the To Do List service on behalf of the signed-in user",
	"directAccessGrantTypes": [],
	"displayName": "Have full access to the To Do List service",
	"impersonationAccessGrantTypes": [
		{
			"impersonated": "User",
		    "impersonator": "Application"
		}
	],
	"isDisabled": false,
	"origin": "Application",
	"permissionId": "b69ee3c9-c40d-4f2a-ac80-961cd1534e40",
	"resourceScopeType": "Personal",
	"userConsentDescription": "Allow full access to the To Do service on your behalf",
	"userConsentDisplayName": "Have full access to the To Do service"
	}
],
```

### Step 4: Register the sample iOS Native Client application

Registering your web application is the first step. Next, you'll need to tell Azure Active Directory about your application as well. This allows your application to communicate with the just registered Web API

**What am I doing?**  

*As stated above, Microsoft Azure Active Directory supports adding two types of applications. Web APIs that offer services to users and applications (either on the web or an applicaiton running on a device) that access those Web APIs. In this step you are registering the application in this sample. You must do that in order for this application to be able to request to access the Web API you just registered. Azure Active Directory will refuse to even allow your application to ask for sign-in unless it's registered! That's part of the security of the model.* 

*Here we are assuming you are registering this sample application referenced above, but this works for any app you are developing.*

**Why am I putting both an application and a Web API in one tenant?**

*As you might have guessed, you could build an app that accesses an external API that is registered in Azure Active Directory from another tenant. If you do that, your customers will be prompted to consent to the use of the API in the application. The nice part is, Active Directory Authentication Library for iOS takes care of this consent for you! As we get in to more advanced features, you'll see this is an important part of the work needed to access the suite of Microsoft APIs from Azure and Office as well as any other service provider. For now, because you registered both your Web API and application under the same tenant you won't see any prompts for consent. This is usually the case if you are developing an application just for your own company to use.*

1. Sign in to the [Azure management portal](https://manage.windowsazure.com).
2. Click on Active Directory in the left hand nav.
3. Click the directory tenant where you wish to register the sample application.
4. Click the Applications tab.
5. In the drawer, click Add.
6. Click "Add an application my organization is developing".
7. Enter a friendly name for the application, for example "TodoListClient-DotNet", select "Native Client Application", and click next.
8. For the Redirect URI, enter `http://TodoListClient`.  Click finish.
9. Click the Configure tab of the application.
10. Find the Client ID value and copy it aside, you will need this later when configuring your application.
11. In "Permissions to Other Applications", select the TodoListService, and request the delegated permission "Have full access to the To Do List service".  Save the configuration.


### Step 5: Download the iOS Native Client Sample code

* `$ git clone git@github.com:AzureADSamples/NativeClient-iOS.git`

### Step 6: Download ADAL for iOS and add it to your XCode Workspace

#### Download the ADAL for iOS 

* `git clone git@github.com:MSOpenTech/azure-activedirectory-library-for-ios.git`

#### Import the library in to your Workspace

In XCode, right mouse click on your project directory and select "Add files to iOS Sample"...

When you are prompted, select the directory where you cloned ADAL for iOS

#### Add the libADALiOS.a to your Linked Frameworks and libraries

Click the add button under "Linked Frameworks and Libraries" and add the library file from the imported frameworks.

Build the project to make sure everything compiles correctly.

 
### Step 7: Configure the settings.plist file with your Web API information

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

The current defaults are set up to work with our [Windows Azure Active Directory Sample REST API Service for Node.js](https://github.com/AzureADSamples/WebAPI-Nodejs). You will need to specify the clientID of your Web API, however. If you are running your own API, you will need to update the endpoints as required.

### Step 8: Build and Run the application

You should be able to connect to the REST API endpoint and be prompted with the credentials from your Windows Azure Active Directory account.



