//
//  MapViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MapViewController.h"


@interface MapViewController () <GMSMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, weak) GMSMapView *gmsMapView;
@end

@implementation MapViewController

- (void)setMapViewFrame:(CGRect)mapViewFrame
{
    _mapViewFrame = mapViewFrame;

    NSLog(@"Frame: %@", NSStringFromCGRect(mapViewFrame));

    [self setupGoogleMap];

}

- (void)setupGoogleMap
{
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.

        //Dubai: Lt: 25.271139, Lg: 55.307485
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:25.271139
                                                            longitude:55.307485
                                                                 zoom:6];
    self.gmsMapView = [GMSMapView mapWithFrame:self.mapViewFrame camera:camera];
    self.gmsMapView.myLocationEnabled = YES;
    self.gmsMapView.delegate = self;
    self.view = self.gmsMapView;

        // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(25.271139, 55.307485);


    marker.title = @"Dubai";
    marker.snippet = @"UAE";
    marker.map = self.gmsMapView;
    
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"You tapped at: %f, %f", coordinate.latitude, coordinate.longitude);
}

- (void)viewDidLoad
{

    [super viewDidLoad];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
