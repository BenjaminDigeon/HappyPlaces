//
//  UserManager.m
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 12/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager

#pragma mark Singleton Methods

+ (id) sharedInstance {
    static UserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Methods

- (BOOL) isLogin {
    if ([self isLoggedIn]) {
        return YES; // Already login
    } else if ([self isLoggedInAfterOpenAttempt]) {
        return YES; // Try to login with old session
    } else {
        return NO; // Not FB Login
    }
}

#pragma mark - Facebook Session

- (void) openFacebookSessionWithsuccess:(void (^)(FBSession *session))success failure:(void (^)(NSError *error))failure {
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      
        // If the session was opened successfully
        if (!error && state == FBSessionStateOpen){
          // Show the user the logged-in UI
          success(session);
        }

        if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
          // If the session is closed
          //TODO : handle faillure
            NSLog(@"Faillure login");
        }

        // Handle errors
        if (error) {
          [FBSession.activeSession closeAndClearTokenInformation];
          failure(error);
        }
    }];
}

#pragma mark - Facebook test session
#pragma mark - Inquiries

- (BOOL)isSessionStateEffectivelyLoggedIn:(FBSessionState)state {
    BOOL effectivelyLoggedIn;
    
    switch (state) {
        case FBSessionStateOpen:
            NSLog(@"Facebook session state: FBSessionStateOpen");
            effectivelyLoggedIn = YES;
            break;
        case FBSessionStateCreatedTokenLoaded:
            NSLog(@"Facebook session state: FBSessionStateCreatedTokenLoaded");
            effectivelyLoggedIn = YES;
            break;
        case FBSessionStateOpenTokenExtended:
            NSLog(@"Facebook session state: FBSessionStateOpenTokenExtended");
            effectivelyLoggedIn = YES;
            break;
        default:
            NSLog(@"Facebook session state: not of one of the open or openable types.");
            effectivelyLoggedIn = NO;
            break;
    }
    
    return effectivelyLoggedIn;
}

/**
 * Determines if the Facebook session has an authorized state. It might still need to be opened if it is a cached
 * token, but the purpose of this call is to determine if the user is authorized at least that they will not be
 * explicitly asked anything.
 */
- (BOOL) isLoggedIn {
    FBSession *activeSession = [FBSession activeSession];
    FBSessionState state = activeSession.state;
    BOOL isLoggedIn = activeSession && [self isSessionStateEffectivelyLoggedIn:state];
    
    NSLog(@"Facebook active session state: %d; logged in conclusion: %@", state, (isLoggedIn ? @"YES" : @"NO"));
    
    return isLoggedIn;
}

/**
 * Attempts to silently open the Facebook session if we have a valid token loaded (that perhaps needs a behind the scenes refresh).
 * After that attempt, we defer to the basic concept of the session being in one of the valid authorized states.
 */
- (BOOL) isLoggedInAfterOpenAttempt {
    NSLog(@"FBSession.activeSession: %@", FBSession.activeSession);
    
    // If we don't have a cached token, a call to open here would cause UX for login to
    // occur; we don't want that to happen unless the user clicks the login button over in Settings, and so
    // we check here to make sure we have a token before calling open
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"We have a cached token, so we're going to re-establish the login for the user.");
        // Even though we had a cached token, we need to login to make the session usable:
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            NSLog(@"Finished opening login session, with state: %d", status);
        }];
    }
    else {
        NSLog(@"Active session wasn't in state 'FBSessionStateCreatedTokenLoaded'. It has state: %d", FBSession.activeSession.state);
    }
    
    return [self isLoggedIn];
}
@end
