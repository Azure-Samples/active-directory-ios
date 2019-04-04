--- 
Services: active-directory
platforms: iOS
author: brandwe
level: 100
client: iOS Mobile App
service: Microsoft Graph
endpoint: AAD V1
---
# ADAL Swift Microsoft Graph API Sample 


| [Getting Started](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-devquickstarts-ios)| [Library](https://github.com/AzureAD/azure-activedirectory-library-for-objc) | [API Reference](http://cocoadocs.org/docsets/ADAL/2.5.1/) | [Support](README.md#community-help-and-support)
| --- | --- | --- | --- |


The ADAL Objective C library gives your app the ability to begin using the
[Microsoft Azure Cloud](https://cloud.microsoft.com) by supporting [Microsoft Azure Active Directory accounts](https://azure.microsoft.com/en-us/services/active-directory/) using industry standard OAuth2 and OpenID Connect. This sample demonstrates all the normal lifecycles your application should experience, including:

* Get a token for the Microsoft Graph
* Refresh a token
* Call the Microsoft Graph
* Sign out the user

## Scenario

This app can be used for all Azure AD accounts. It demonstrates how a developer can build apps to connect with enterprise users and access their Azure + O365 data via the Microsoft Graph.  During the auth flow, end users will be required to sign in and consent to the permissions of the application, and in some cases may require an admin to consent to the app.  The majority of the logic in this sample shows how to auth an end user and make a basic call to the Microsoft Graph.

![Topology](./images/iosintro.png)

## Steps to Run

### Register & Configure your app

You will need to have a native client application registered with Microsoft using the 
[Azure portal](https://portal.azure.com). 

1. Getting to app registration
    - Navigate to the [Azure portal](https://aad.portal.azure.com).  
    - Click on ***Azure Active Directory*** > ***App Registrations***. 

2. Create the app
    - Click ***New application registration***.  
    - Enter an app name in the ***Name*** field. 
    - In ***Application type***, select `Native`. 
    - In ***Redirect URI***, enter `urn:ietf:wg:oauth:2.0:oob`.  

3. Configure Microsoft Graph
    - Select ***Settings*** > ***Required Permissions***.
    - Click ***Add***, inside ***Select an API*** select ***Microsoft Graph***. 
    - Select the permission `Sign in and read user profile` > Hit `Select` to save. 
        - This permission maps to the `User.Read` scope. 

4. Congrats! Your app is successfully configured. In the next section, you'll need:
    - `Application ID`
    - `Redirect URI`

### Get the code

* `$ git clone git@github.com:Azure-Samples/active-directory-ios.git`

1. Download Cocoapods (if you don't already have it)

CocoaPods is the dependency manager for Swift and Objective-C Cocoa projects. It has thousands of libraries and can help you scale your projects elegantly. To install on OS X 10.9 and greater simply run the following command in your terminal:

`$ sudo gem install cocoapods`

1. Build the sample and pull down ADAL for iOS automatically

Run the following command in your terminal:

`$ pod install`

This will download and build ADAL for iOS for you and configure your Microsoft Tasks.xcodeproj to use the correct dependencies.

### Step 4: Run the application in Xcode

This will download and build ADAL for iOS for you and configure your QuickStart.xcodeproj to use the correct dependencies.

You should see the following output:

```
$ pod install
Analyzing dependencies
Downloading dependencies
Installing ADAL (2.5.2)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `QuickStart.xcworkspace` for this project from now on.
Sending stats
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
```

1.  Run the application in Xcode

Launch XCode and load the `QuickStart.xcworkspace` file. The application will run in an emulator as soon as it is loaded.


1. Configure the `ViewController.swift` file with your app information

You will need to configure your application to work with the Azure AD tenant you've created.

-	In the QuickStart project, open the file `ViewController.swift`.  Replace the values of the elements in the section to reflect the values you input into the Azure Portal.  Your code will reference these values whenever it uses ADAL.
    -	The `kClientID` is the clientId of your application you copied from the portal.
    -	The `kRedirectUri` is the redirect url you registered in the portal.


## Important Info

1. Checkout the [ADAL Objective C Wiki](https://github.com/AzureAD/azure-activedirectory-library-for-objc/wiki) for more info on the library mechanics and how to configure new scenarios and capabilities. 
2. In Native scenarios, the app will use an embedded Webview and will not leave the app. The `Redirect URI` can be arbitrary. 
3. Find any problems or have requests? Feel free to create an issue or post on Stackoverflow with 
tag `azure-active-directory`. 

## Feedback, Community Help, and Support

We use [Stack Overflow](http://stackoverflow.com/questions/tagged/adal) with the community to 
provide support. We highly recommend you ask your questions on Stack Overflow first and browse 
existing issues to see if someone has asked your question before. 

If you find and bug or have a feature request, please raise the issue 
on [GitHub Issues](../../issues). 

To provide a recommendation, visit 
our [User Voice page](https://feedback.azure.com/forums/169401-azure-active-directory).

## Contribute

We enthusiastically welcome contributions and feedback. You can clone the repo and start 
contributing now. Read our [Contribution Guide](CONTRIBUTING.md) for more information.

This project has adopted the 
[Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). 
For more information see 
the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact 
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Security Library

This library controls how users sign-in and access services. We recommend you always take the 
latest version of our library in your app when possible. We 
use [semantic versioning](http://semver.org) so you can control the risk associated with updating 
your app. As an example, always downloading the latest minor version number (e.g. x.*y*.x) ensures 
you get the latest security and feature enhanements but our API surface remains the same. You 
can always see the latest version and release notes under the Releases tab of GitHub.

## Security Reporting

If you find a security issue with our libraries or services please report it 
to [secure@microsoft.com](mailto:secure@microsoft.com) with as much detail as possible. Your 
submission may be eligible for a bounty through the [Microsoft Bounty](http://aka.ms/bugbounty) 
program. Please do not post security issues to GitHub Issues or any other public site. We will 
contact you shortly upon receiving the information. We encourage you to get notifications of when 
security incidents occur by 
visiting [this page](https://technet.microsoft.com/en-us/security/dd252948) and subscribing 
to Security Advisory Alerts.
