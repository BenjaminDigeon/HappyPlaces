//
//  MainViewController.m
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 12/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import "MainViewController.h"
#import "PlacesAnnotation.h"

#import <CHCSVParser/CHCSVParser.h>
#import <FacebookSDK/FacebookSDK.h>

#import "FoursquareManager.h"

#define NB_ANNOTATE 5

NSString* FOURSQUARE_SECTION_DRINKS = @"drinks";
NSString* FOURSQUARE_SECTION_FOOD = @"food";
NSString* FOURSQUARE_SECTION_SIGHTS = @"sights";

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) NSString* selectedSection;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) HeatMap *hm;
@property (strong, nonatomic) NSMutableArray *placesWithAnnot;
@property (nonatomic) BOOL locationUpdated;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:226/255.0f green:134/255.0f blue:35/255.0f alpha:1.0f]];
    
    self.mapView.delegate = self;
    self.mapView.rotateEnabled = NO;
    
    //Init with HeatMap
    self.hm = [[HeatMap alloc] init];
    
    self.locationUpdated = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    
    //If iOS8 optain authorization for location
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    //Show user position
    self.mapView.showsUserLocation = YES;
    
    self.tabBar.delegate = self;
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    
    self.selectedSection = FOURSQUARE_SECTION_DRINKS;
    
    //Load data from foursquare
    [self loadFoursquareData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setMapView:nil];
}

#pragma mark -
#pragma mark Actions

- (IBAction)reloadData:(id)sender {
    [self loadFoursquareData];
}

#pragma mark -
#pragma mark Heat Map Overlay reload

- (void) reloadHeatMapWithData:(NSDictionary*)data {
    [self.hm setData:data];
    [self.mapView addOverlay:self.hm];
    //[self.mapView setVisibleMapRect:[self.hm boundingMapRect] animated:YES];
    
    //Place the points to annotate
    [self.mapView removeAnnotations:self.mapView.annotations];
    for(NSDictionary* place in self.placesWithAnnot) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[place objectForKey:@"lat"] doubleValue],
                                                                  [[place objectForKey:@"lng"] doubleValue]);
        NSString* checkins = [NSString stringWithFormat:@"%@ check-ins",[(NSNumber*)[place objectForKey:@"checkin"] stringValue]];
        
        PlacesAnnotation *annot = [[PlacesAnnotation alloc] initWithCoordinates:coord
                                                                      placeName:[place objectForKey:@"name"]
                                                                  placeSubtitle:checkins
                                                                placeIdentifier:[place objectForKey:@"id"]];
        [self.mapView addAnnotation:annot];
    }
}

#pragma mark -
#pragma mark Foursquare Heatmap Parser

- (NSDictionary *)heatMapDataFromFoursquare:(NSArray*)data {
    NSMutableDictionary *toRet = [[NSMutableDictionary alloc] initWithCapacity:[data count]];
    
    self.placesWithAnnot = [[NSMutableArray alloc] init];
    int i = 0;
    for (NSDictionary *line in data) {
        
        MKMapPoint point = MKMapPointForCoordinate(
                                                   CLLocationCoordinate2DMake([[line objectForKey:@"lat"] doubleValue],
                                                                              [[line objectForKey:@"lng"] doubleValue]));
        
        NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
        [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
        //TODO : Add point value from checkin
        //[toRet setObject:[line objectForKey:@"checkin"] forKey:pointValue];
        
        //Store the places to annotate
        if (i < NB_ANNOTATE) {
            [self.placesWithAnnot addObject:line];
        }
        i++;
    }
    
    return toRet;
}

#pragma mark -
#pragma mark Loading data from Foursquare

- (void) loadFoursquareData {
    CLLocationCoordinate2D coord = [self getCenterCoordinate];
    NSNumber* radius = [NSNumber numberWithDouble:[self getRadius]]; //Radius in meters
    
    //Only load if radius < 20km
    if(radius.intValue < 20000) {
        [[FoursquareManager sharedInstance] getFoursquarePlacesNearOf:coord withRadius:radius WithSection:self.selectedSection success:^(NSArray *places) {
            [self reloadHeatMapWithData:[self heatMapDataFromFoursquare:places]];
        } failure:^(NSError *error) {
            //TODO : Alert
        }];
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    return [[HeatMapView alloc] initWithOverlay:overlay];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    //Not custom for user location
    if (annotation == mapView.userLocation) return nil;
    
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinLocation"];
    
    newAnnotation.canShowCallout = YES;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [button setImage:[UIImage imageNamed:@"iconFlecheOrange"] forState:UIControlStateNormal];
    newAnnotation.rightCalloutAccessoryView = button;
    
    return newAnnotation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    PlacesAnnotation * annot = (PlacesAnnotation*)[view annotation];
    NSString* venusUrl = [NSString stringWithFormat:@"http://foursquare.com/v/%@",annot.identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:venusUrl]];
}

#pragma mark -
#pragma mark Post Facebook

// Show the feed dialog
- (IBAction) postFacebook:(id)sender {
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:nil
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
      if (error) {
          // An error occurred, we need to handle the error
          // See: https://developers.facebook.com/docs/ios/errors
          NSLog(@"Error publishing story: %@", error.description);
      } else {
          if (result == FBWebDialogResultDialogNotCompleted) {
              // User canceled.
              NSLog(@"User cancelled.");
          } else {
              // Handle the publish feed callback
              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
              
              if (![urlParams valueForKey:@"post_id"]) {
                  // User canceled.
                  NSLog(@"User cancelled.");
                  
              } else {
                  // User clicked the Share button
                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                  NSLog(@"result %@", result);
              }
          }
      }
  }];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark -
#pragma mark TabBar Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 0:
            self.selectedSection = FOURSQUARE_SECTION_DRINKS;
            break;
        case 1:
            self.selectedSection = FOURSQUARE_SECTION_FOOD;
            break;
        case 2:
            self.selectedSection = FOURSQUARE_SECTION_SIGHTS;
            break;
        default:
            break;
    }
    //Reload map
    [self loadFoursquareData];
}

#pragma mark -
#pragma mark Calculate radius

- (CLLocationCoordinate2D)getCenterCoordinate {
    CLLocationCoordinate2D centerCoor = [self.mapView centerCoordinate];
    return centerCoor;
}

- (CLLocationCoordinate2D)getTopCenterCoordinate {
    CLLocationCoordinate2D topCenterCoor = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width / 2.0f, 0) toCoordinateFromView:self.mapView];
    return topCenterCoor;
}

- (CLLocationDistance)getRadius {
    CLLocationCoordinate2D centerCoor = [self getCenterCoordinate];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoor.latitude longitude:centerCoor.longitude];
    
    CLLocationCoordinate2D topCenterCoor = [self getTopCenterCoordinate];
    CLLocation *topCenterLocation = [[CLLocation alloc] initWithLatitude:topCenterCoor.latitude longitude:topCenterCoor.longitude];
    
    CLLocationDistance radius = [centerLocation distanceFromLocation:topCenterLocation];
    
    return radius;
}

#pragma mark -
#pragma mark Move map to the user

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    if (!self.locationUpdated) {
        self.locationUpdated = YES;
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
        CLLocationCoordinate2D location;
        location.latitude = aUserLocation.coordinate.latitude;
        location.longitude = aUserLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [aMapView setRegion:region animated:YES];
    }
}

@end
