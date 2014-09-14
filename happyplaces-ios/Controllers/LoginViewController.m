//
//  LoginViewController.m
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 13/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import "LoginViewController.h"

#import "UserManager.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginFacebook:(id)sender {
    [[UserManager sharedInstance] openFacebookSessionWithsuccess:^(FBSession *session) {
        //Login OK
        [self goToMainVC];
    } failure:^(NSError *error) {
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //TODO : Alert [ECAlertView showMessage:alertText withTitle:alertTitle];
        } else {
            //If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                //User cancelled FB login
                
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //TODO : Alert [ECAlertView showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //TODO : Aler [ECAlertView showMessage:alertText withTitle:alertTitle];
            }
        }
    }];
}

- (IBAction)noLogin:(id)sender {
    //App in no login
    [self goToMainVC];
}

#pragma mark - Navigation

- (void) goToMainVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.window.rootViewController = vc;
}

@end
