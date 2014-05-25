//
//  CoreLocationManagerVC.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/10/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol DMLocationManagerDelegate <NSObject>

@optional
- (void)currentHeadingChangedTo:(CLLocationDirection)newHeading;

@required
- (void)currentLocationChangedTo:(CLLocation *)newLocation;
- (void)authorizationStatusChangedTo:(CLAuthorizationStatus)status;

@end

typedef struct {CLLocationCoordinate2D coordinate; CLLocationDistance radius;} DMCircularOverlay;

@interface DMLocationManager : CLLocationManager <CLLocationManagerDelegate>
@property (nonatomic, assign) id <DMLocationManagerDelegate>dmLocationDelegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) NSNumber *calculatedSpeed;
+ (DMLocationManager *)sharedInstance;
- (void)startStandardChangeUpdates;
- (void)startStandardChangeUpdatesWithHeading;
- (void)startSignificantChangeUpdates;
- (void)stopChangeUpdates;
- (void)stopSignificantChangeUpdates;
- (BOOL)registerRegionWithCircularOverlay:(DMCircularOverlay)overlay andIdentifier:(NSString*)identifier;
- (BOOL)isAuthorized;
- (void)requestNewLocation;
@end