//
//  FoursquareManager.h
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 13/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CLLocation.h>

@interface FoursquareManager : NSObject

/** @name Singleton Methods */

/**
 *  Return the shared instance of the user manager
 *
 *  @return The shared manager instance.
 */
+ (id) sharedInstance;


/**
 *  Get foursquare places
 *
 *  @param coordinate center coordinate for search
 *  @param radius in meter the radius (max 20km)
 *  @param section (foursquare section type)
 *  @param success success callback with the places
 *  @param failure faillure callback with error
 */
- (void) getFoursquarePlacesNearOf:(CLLocationCoordinate2D)coordinate withRadius:(NSNumber*) radius WithSection:(NSString*) section success:(void (^)(NSArray *places))success failure:(void (^)(NSError *error))failure;

@end
