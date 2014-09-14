//
//  UserManager.h
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 12/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

@interface UserManager : NSObject

/** @name Singleton Methods */

/**
 * Return the shared instance of the user manager
 *
 * @return The shared manager instance.
 */
+ (id) sharedInstance;

/** @name Accessors */

/**
 *  Return true if user isLogin
 *
 *  @return true if user login
 */
- (BOOL) isLogin;

/** @name Remote calls */

/**
 *  Open a Facebook session
 *
 *  @param success success callback with the opened session
 *  @param failure faillure callback with error
 */
- (void) openFacebookSessionWithsuccess:(void (^)(FBSession *session))success failure:(void (^)(NSError *error))failure;

@end
