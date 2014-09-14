//
//  PlacesAnnotation.m
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 13/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import "PlacesAnnotation.h"

@implementation PlacesAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize identifier;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName placeSubtitle:(NSString *)placeSubtitle placeIdentifier:(NSString *)placeIdentifier {
    self = [super init];
    if (self) {
        coordinate = location;
        title = placeName;
        subtitle = placeSubtitle;
        identifier = placeIdentifier;
    }
    
    return self;
}

@end
