//
//  CoreLocationManagerVC.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/10/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMLocationManager.h"

@interface DMLocationManager()
@property (nonatomic, strong, readwrite) NSNumber *calculatedSpeed;
@end

@implementation DMLocationManager

#define DISTANCE_FILTER 10
#define DISTANCE_FILTER_DIRECTING 2
#define HEADING_FILTER 1

@synthesize dmLocationDelegate;

+ (DMLocationManager *)sharedInstance
{
    __strong static DMLocationManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];

    });

    return _sharedInstance;
}

- (CLLocationManager *)locationManager
{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)startStandardChangeUpdates
{
    if(![self isAuthorized]) return;

    self.locationManager.distanceFilter = DISTANCE_FILTER;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

    [self.locationManager startUpdatingLocation];
}

- (void)startStandardChangeUpdatesWithHeading
{
    if(![self isAuthorized]) return;
    
        //Start location services to get the true heading
    self.locationManager.distanceFilter = DISTANCE_FILTER_DIRECTING;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [self.locationManager startUpdatingLocation];

        //Start heading updates
    if([CLLocationManager headingAvailable]){
        self.locationManager.headingFilter = HEADING_FILTER;
        [self.locationManager startUpdatingHeading];
    }
}

- (void)startSignificantChangeUpdates
{
    if(![self isAuthorized]) return;

    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopChangeUpdates
{
    if(![self isAuthorized]) return;
    
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

- (void)stopSignificantChangeUpdates
{
    if(![self isAuthorized]) return;
    
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (BOOL)registerRegionWithCircularOverlay:(DMCircularOverlay)overlay andIdentifier:(NSString*)identifier
{
        // Do not create regions if support is unavailable or disabled
    if(![CLLocationManager regionMonitoringAvailable])
        return NO;

        //Check the authorization status
    if(![self isAuthorized])
        return NO;

        //Clear out any old regions to avoid buildup.
    if([self.locationManager.monitoredRegions count] > 0){
        for(id region in self.locationManager.monitoredRegions){
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
    
        // If the overlay's radius is too large, registration fails automatically,
        // so clamp the radius to the max value.
    CLLocationDegrees radius = overlay.radius;

    if(radius > self.locationManager.maximumRegionMonitoringDistance){
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }

        //Create the region to be monitored
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:overlay.coordinate radius:radius identifier:identifier];
    [self.locationManager startMonitoringForRegion:region];
    
    return YES;
}

- (BOOL)isAuthorized
{
    if(([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) &&
       ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined))
        return NO;

    return YES;
}

- (void)requestNewLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManager Delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
        // If it's a relatively recent event, turn off updates to save power
    CLLocation *newLocation = [locations lastObject];

    NSDate *eventDate = newLocation.timestamp;

    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    NSUInteger newLocationIndex = [locations indexOfObject:newLocation];
    CLLocation *previousLocation = nil;



    if([locations count] > 1){ //there is a previous location
        previousLocation = locations[(newLocationIndex - 1)];

        if(previousLocation){
            CLLocationDistance distanceChange = [newLocation distanceFromLocation:previousLocation];

            NSTimeInterval sinceLastUpdate = [newLocation.timestamp timeIntervalSinceDate:previousLocation.timestamp];

            self.calculatedSpeed = [NSNumber numberWithDouble:(distanceChange / sinceLastUpdate)];

        }
    }




    if (abs(howRecent) < HOW_RECENT_INTERVAL) {
            // If the event is recent, do something with it.
        if(dmLocationDelegate) [dmLocationDelegate currentLocationChangedTo:newLocation];
    }



}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if(newHeading.headingAccuracy < 0)
        return;

    NSDate *eventDate = newHeading.timestamp;

    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

        // If the event is recent, do something with it.
    if (abs(howRecent) < HOW_RECENT_INTERVAL) {
            //Use the true heading if it is valid
        CLLocationDirection theHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading);

        if(dmLocationDelegate){

                if([dmLocationDelegate respondsToSelector:@selector(currentHeadingChangedTo:)]){
                    [dmLocationDelegate currentHeadingChangedTo:theHeading];
                }

        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
#ifdef DM_DEBUG
    NSLog(@"Location Manager Failed Error: %@", error);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(dmLocationDelegate){
        if([dmLocationDelegate respondsToSelector:@selector(authorizationStatusChangedTo:)]){
            [dmLocationDelegate authorizationStatusChangedTo:status];
        }
    }
}

@end