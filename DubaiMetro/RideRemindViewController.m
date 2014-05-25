//
//  RideRemindViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/14/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import "RideRemindViewController.h"
#import "AllMetroStationsMapViewController.h"
#import "MetroStation+CreateFetch.h"
#import "RideRemindDashboardViewController.h"
#import "DMBarButtonItem.h"
#import "Settings.h"

#import "DMLocationManager.h"

@interface RideRemindViewController ()<UIAlertViewDelegate, DMLocationManagerDelegate>
@property (nonatomic, strong) RideRemindDashboardViewController *rrDashboardVC;
@property (nonatomic, strong) DMLocationManager *dmLocationManager;
@property (nonatomic, strong) MetroStation *previousMetroStation;
@end

@implementation RideRemindViewController
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSTimer *locationPingTimer = [NSTimer timerWithTimeInterval:2.0 target:self.dmLocationManager
                                                       selector:@selector(requestNewLocation)
                                                       userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:locationPingTimer forMode:NSRunLoopCommonModes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLocationManager];

    DMBarButtonItem *barButtonItem = [[DMBarButtonItem alloc] initWithTitle:@"STOP"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(dismiss)];
    [barButtonItem setup];

    self.navigationItem.leftBarButtonItem = nil; //remove it (some issue)
    self.navigationItem.leftBarButtonItem = barButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [DMHelper trackScreenWithName:@"Ride Remind"];

    self.dmLocationManager.dmLocationDelegate = self;
    [self.dmLocationManager startStandardChangeUpdatesWithHeading];
        //Fix this issue of not reloading Map
    [self.metroStationsMapvc reload];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.dmLocationManager stopChangeUpdates];

    self.dmLocationManager.dmLocationDelegate = nil;
}


- (void)dismiss
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                        message:@"If you stop, all your journey progress will be lost!"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes - STOP", nil];

    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes - STOP"]){
        [self dismissViewControllerAnimated:YES completion:^{

        }];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMetroStationProximities
{
    if(self.managedObjectContext){

        if(self.dmLocationManager.isAuthorized){
            self.nearestMetroStation = [MetroStation updateMetroStationProximitiesUsingLocationManager:self.dmLocationManager
                                                                                inManagedObjectContext:self.managedObjectContext];

            NSLog(@"Nearest: %@", self.nearestMetroStation.stationName);
        }

        else
            self.rrDashboardVC.status = kLocationOff;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([segue.identifier isEqualToString:@"Embed Map View"]){
        if([segue.destinationViewController isKindOfClass:[AllMetroStationsMapViewController class]]){
            AllMetroStationsMapViewController *amsmvc = (AllMetroStationsMapViewController *)segue.destinationViewController;
            amsmvc.managedObjectContext = self.journeyRoute.fromStation.managedObjectContext;
            self.metroStationsMapvc = amsmvc;
        }
    }else if([segue.identifier isEqualToString:@"Embed Dashboard"]){
        if([segue.destinationViewController isKindOfClass:[RideRemindDashboardViewController class]]){
            RideRemindDashboardViewController *rrdvc = (RideRemindDashboardViewController *)segue.destinationViewController;
            self.rrDashboardVC = rrdvc;

        }
    }
}

#pragma mark - Setup methods
- (void)setupLocationManager
{
    self.dmLocationManager = [DMLocationManager sharedInstance];
    self.dmLocationManager.dmLocationDelegate = self;

    [self.dmLocationManager startStandardChangeUpdatesWithHeading];
}

- (void)setJourneyRoute:(JourneyRoute *)journeyRoute
{
    _journeyRoute = journeyRoute;
    self.managedObjectContext = journeyRoute.fromStation.managedObjectContext;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    self.metroStationsMapvc.managedObjectContext = _managedObjectContext;
    self.nearestMetroStation = [MetroStation updateMetroStationProximitiesUsingLocationManager:self.dmLocationManager
                                                                        inManagedObjectContext:_managedObjectContext];
}

#pragma mark - DMLocationManager Delegate methods
- (void)currentLocationChangedTo:(CLLocation *)newLocation
{
    [self updateMetroStationProximities];

    NSLog(@"New Location: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    float speed = [newLocation speed];

    NSLog(@"GPS Speed: %f", speed);
    NSLog(@"Calculated Speed: %f", [self.dmLocationManager.calculatedSpeed floatValue]);

        //@todo
    speed = [self.dmLocationManager.calculatedSpeed floatValue];

    if([Settings sharedInstance].isMeasurementImperial){
            //mps to mph
        speed = speed * 2.23694;
        self.rrDashboardVC.speedUnitLabel.text = @"mph";
    }else{
            //mps to kph
        speed = speed * 3.6;
        self.rrDashboardVC.speedUnitLabel.text = @"km/h";
    }

    self.rrDashboardVC.speedLabel.text = (speed < 0 ? @"0" : [NSString stringWithFormat:@"%d",(int)roundf(speed)]);

    NSString *stationName = self.nearestMetroStation.stationName;

//    unichar newLine = '\n';

    if(self.nearestMetroStation && [DMHelper isAtStation:[self.nearestMetroStation.stationProximity floatValue]]){
        self.rrDashboardVC.statusLabel.attributedText = [[NSAttributedString alloc] initWithString:[@"At Station" stringByAppendingString:[NSString stringWithFormat:@"\n%@", stationName]]];
        self.previousMetroStation = self.nearestMetroStation;
    }else if([self.previousMetroStation isEqual:self.nearestMetroStation]){
        self.rrDashboardVC.statusLabel.attributedText = [[NSAttributedString alloc] initWithString:[@"Departing" stringByAppendingString:[NSString stringWithFormat:@"\n%@", stationName]]];
    }else{
        self.rrDashboardVC.statusLabel.attributedText = [[NSAttributedString alloc] initWithString:[@"Next Station" stringByAppendingString:[NSString stringWithFormat:@"\n%@", stationName]]];
    }


}
- (void)authorizationStatusChangedTo:(CLAuthorizationStatus)status
{
    if(status){
        [self reloadMap];
        [self updateMetroStationProximities];

    }else{
        self.rrDashboardVC.status = kLocationOff;
    }
}


@end
