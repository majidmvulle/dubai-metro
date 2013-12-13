//
//  MetroStationMapViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/19/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationMapViewController.h"

@interface MetroStationMapViewController ()
@property (nonatomic) BOOL needUpdateRegion;
@end

@implementation MetroStationMapViewController

#pragma mark - UIViewController methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for(MKAnnotationView *view in views){
        view.rightCalloutAccessoryView = nil;
    }
}

- (void)updateRegion
{
    self.needUpdateRegion = NO;
    CGRect boundingRect;
    BOOL started = NO;

    for(id<MKAnnotation> annotation in self.mapView.annotations){

        CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);
        if(!started){
            started = YES;
            boundingRect = annotationRect;
        }else{
            boundingRect = CGRectUnion(boundingRect, annotationRect);
        }

    }

    if(started){
        boundingRect = CGRectInset(boundingRect, -0.001, -0.001);

        if((boundingRect.size.width < 10) && (boundingRect.size.height < 10)){
            MKCoordinateRegion region;

            region.center.latitude = boundingRect.origin.x + boundingRect.size.width / 2;
            region.center.longitude = boundingRect.origin.y + boundingRect.size.height / 2;
            region.span.latitudeDelta = boundingRect.size.width;
            region.span.longitudeDelta = boundingRect.size.height;

            [self.mapView setRegion:region animated:YES];
        }
    }
}

@end