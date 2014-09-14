//
//  PlacesAnnotation.h
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 13/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlacesAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, strong) NSString* identifier;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
                 placeSubtitle:(NSString *)placeSubtitle
              placeIdentifier:(NSString *)placeIdentifier;

@end
