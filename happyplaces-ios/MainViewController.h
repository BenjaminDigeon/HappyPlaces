//
//  MainViewController.h
//  happyplaces-ios
//
//  Created by Benjamin Digeon on 12/09/2014.
//  Copyright (c) 2014 happyplaces. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "HeatMap.h"
#import "HeatMapView.h"

@interface MainViewController : UIViewController <MKMapViewDelegate, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

