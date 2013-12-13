//
//  MapViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#pragma mark - GreenPolyline
@interface GreenPolyline : MKPolyline
@end

#pragma mark - RedPolyline
@interface RedPolyline : MKPolyline
@end

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end