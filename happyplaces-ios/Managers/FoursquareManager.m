//
//  FoursquareManager.m
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 13/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import "FoursquareManager.h"

#import <AFNetworking/AFNetworking.h>

@implementation FoursquareManager

NSString *FOURSQUARE_CLIENT_ID = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
NSString *FOURSQUARE_CLIENT_SECRET = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
NSString *FOURSQUARE_VERSION = @"20140806";
NSString *FOURSQUARE_LIMIT = @"50";

#pragma mark Singleton Methods

+ (id) sharedInstance {
    static FoursquareManager *sharedInstance = nil;
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

- (void) getFoursquarePlacesNearOf:(CLLocationCoordinate2D)coordinate withRadius:(NSNumber*) radius WithSection:(NSString*) section success:(void (^)(NSArray *places))success failure:(void (^)(NSError *error))failure {
    //Call to Foursquare
    NSString *path = @"https://api.foursquare.com/v2/venues/explore";
    NSString *locationString = [NSString stringWithFormat:@"%f,%f",coordinate.latitude,coordinate.longitude];
    NSNumber* real_radius = [NSNumber numberWithInteger:radius.integerValue]; //Convert radius with no decimal part

    NSDictionary *parameters = [[NSDictionary alloc] initWithObjects:@[FOURSQUARE_CLIENT_ID,
                                                                    FOURSQUARE_CLIENT_SECRET,
                                                                    FOURSQUARE_VERSION,
                                                                    FOURSQUARE_LIMIT,
                                                                    section,
                                                                    locationString,
                                                                    real_radius]
                                                          forKeys:@[@"client_id",@"client_secret",@"v",@"limit",@"section",@"ll",@"radius"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray* data = [[NSMutableArray alloc] init];
        NSDictionary* response = responseObject;
        NSNumber *code = [[response objectForKey:@"meta"] objectForKey:@"code"];
        
        if ([code  isEqual: @200]) {
            //OK
            NSArray* recomendedPlaces = [[[[response objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"];
            for (NSDictionary *place in recomendedPlaces) {
                NSString *ident = [[place objectForKey:@"venue"] objectForKey:@"id"];
                NSString *name = [[place objectForKey:@"venue"] objectForKey:@"name"];
                NSNumber* lat = [[[place objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lat"];
                NSNumber* lng = [[[place objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lng"];
                NSNumber* checkin = [[[place objectForKey:@"venue"] objectForKey:@"stats"] objectForKey:@"checkinsCount"];
                NSDictionary* placeDict = [NSDictionary dictionaryWithObjects:@[ident,
                                                                                name,
                                                                                lat,
                                                                                lng,
                                                                                checkin]
                                                                      forKeys:@[@"id",@"name",@"lat",@"lng",@"checkin"]];
                [data addObject:placeDict];
            }
        }
        success(data);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}

@end
