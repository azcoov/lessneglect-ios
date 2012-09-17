[LessNeglect](www.lessneglect.com) Objective-c Client
===
Send messages and events from your iOS app to LessNeglect!

Integration
---

1.  Add a Reference to the LessNeglect library in your Project (either directly to the source, or via the LessNeglect Library)  
    1.  Add the LessNeglect library files to your project: File -> Add Files to " "  
    2.  Find and select the folder that contains the LessNeglect  
    3.  Make sure that "Copy items into destination folder (if needed)" is checked  
    4.  Set Folders to "Create groups for any added folders"  
    5.  Select all targets that you want to add the SDK to  

2.  Verify that libLessNeglect-ios.a has been added to the Link Binary With Libraries Build Phase for the targets you want to use the Library with.  

3.  In your Application Delegate:  
    1. Import TestFlight: #import "lessneglect_ios.h"  
    2. Get your Project Code and API Secret your LessNeglect settings page
    3. Add your Project Code and API Secret constants  

```objective-c
  #define kProjectCode @"your_project_code"
  #define kAPISecret @"your_api_secret"
```

4.  Log events as they happen using the client:

```objective-c
- (void)registerNewUser {
    LessNeglectConnection *con = [LessNeglectConnection connectionWithCode:kAuthCode key:kAuthKey];
    
    //create a person object
    Person *person = [[Person alloc] init];
    person.email = @"test+6@tekfolio.me";
    
    //create an event object
    Event *event = [[Event alloc] init];
    event.name = @"registered";
    event.note = @"customer signed up from xyz campaign";
    event.person = person;
    
    [con createActionEvent:event success:^(NSDictionary *response) {
        //parse the json response and do something with it if you want
    } error:^(NSError *error) {
        //handle the error if you'd like
    }];
}
```