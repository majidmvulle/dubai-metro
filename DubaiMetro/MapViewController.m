//
//  MapViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MapViewController.h"
#import "MetroStation.h"
#import "HomeViewController.h"
#import "MetroStationLine.h"

#pragma mark - GreenPolyline
@implementation GreenPolyline
@end

#pragma mark - RedPolyline
@implementation RedPolyline
@end

#pragma mark - MapViewController
@interface MapViewController ()
@end

@implementation MapViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self updateRegion];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
#ifdef DM_DEBUG
    NSLog(@"Map View memory warning");
#endif
        // Dispose of any resources that can be recreated.
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

        //if I am onscreen
    if(self.view.window) [self reload];
}

- (void)reload{}; //abstract

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]){
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        if([view.annotation respondsToSelector:@selector(thumbnail)]){
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if(annotation == self.mapView.userLocation){
        return nil;
    }else{
        static NSString *reuseID = @"MapViewController";
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];

        if(!view){
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
            view.canShowCallout = YES;

            ((MKPinAnnotationView *)view).animatesDrop = YES;

            if([mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]){
                view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
                if([DMHelper sharedInstance].isOS7AndAbove){
                    view.rightCalloutAccessoryView.tintColor = BACKGROUND_COLOR;
                    view.tintColor = BACKGROUND_COLOR;
                }
            }

            view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)]; //create a square (magic numbers, not good)
        }

        if([annotation isKindOfClass:[MetroStation class]] && [view isKindOfClass:[MKPinAnnotationView class]]){
            MetroStation *station = (MetroStation *)annotation;
            if(station){
                if([station.stationLines count] > 1) ((MKPinAnnotationView *)view).pinColor = MKPinAnnotationColorPurple;
                else{
                    if([((MetroStationLine *)[station.stationLines anyObject]).stationLineCode isEqualToString:LINE_GREEN_CODE]){
                        ((MKPinAnnotationView *)view).pinColor = MKPinAnnotationColorGreen;
                    }else if([((MetroStationLine *)[station.stationLines anyObject]).stationLineCode isEqualToString:LINE_RED_CODE]){
                        ((MKPinAnnotationView *)view).pinColor = MKPinAnnotationColorRed;
                    }
                }
            }
        }

        return view;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([self.parentViewController isKindOfClass:[HomeViewController class]]){
        @try {
            if([view.annotation isKindOfClass:[MetroStation class]]){
                MetroStation *station = view.annotation;
                [(HomeViewController *)self.parentViewController setupMetroStation:station];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Couldn't segue: %@", exception);
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        lineView.lineWidth = 5;

        if([overlay isKindOfClass:[GreenPolyline class]]) lineView.strokeColor = [UIColor greenColor];
        if([overlay isKindOfClass:[RedPolyline class]]) lineView.strokeColor = [UIColor redColor];

        return lineView;
    }
    
    return nil;
}

@end