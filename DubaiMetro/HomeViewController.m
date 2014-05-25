//
//  DubaiMetroViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 8/27/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "HomeViewController.h"
#import "IntroViewController.h"
#import "DefaultNavigationController.h"

#import "DMDashboardViewController.h"
#import "MetroStationCDTVC.h"
#import "JourneyTableViewController.h"
#import "DMLocationManager.h"

    //Core Data
#import "CoreDataHelper.h"
#import "MetroStation+CreateFetch.h"
#import "MetroStationLine+CreateFetch.h"
#import "TrainBound+Create.h"
#import "TrainTiming+Create.h"
#import "PeakTime+Create.h"
#import "TicketPrice+CreateFetch.h"

@interface HomeViewController ()<DMLocationManagerDelegate>
@property (nonatomic, strong) DMDashboardViewController *dashboardVC;

@property (nonatomic) BOOL isDirectingToLocation;
@property (nonatomic, strong) UIManagedDocument *managedDocument;
@property (nonatomic, strong) DMLocationManager *dmLocationManager;

//@property (weak, nonatomic) IBOutlet UIView *dashboardContainer;
//@property (weak, nonatomic) IBOutlet UIView *mapViewContainer;
@end

@implementation HomeViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize nearestMetroStation = _nearestMetroStation;

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dashboardVC.status = kInitializing;
    if(!self.managedObjectContext) [self useDocument];
    [self.dashboardVC.viewTrainTimingsButton addTarget:self action:@selector(viewTrainTimings)
                                      forControlEvents:UIControlEventTouchDown];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLocationManager];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.dmLocationManager.dmLocationDelegate = self;
    [self.dmLocationManager startStandardChangeUpdatesWithHeading];
    [DMHelper trackScreenWithName:@"Dashboards"];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.dmLocationManager stopChangeUpdates];

    self.dmLocationManager.dmLocationDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Embed Map View"]){
        if([segue.destinationViewController isKindOfClass:[AllMetroStationsMapViewController class]]){
            AllMetroStationsMapViewController *amsmvc = (AllMetroStationsMapViewController *)segue.destinationViewController;
            amsmvc.managedObjectContext = self.managedObjectContext;
            self.metroStationsMapvc = amsmvc;
        }
    }else if([segue.identifier isEqualToString:@"Embed Dashboard"]){
        if([segue.destinationViewController isKindOfClass:[DMDashboardViewController class]]){
            DMDashboardViewController *dashboardVC = (DMDashboardViewController *)segue.destinationViewController;

            if(![self.dmLocationManager isAuthorized]){
                dashboardVC.status = kLocationOff;
            }else{
                if(self.isDirectingToLocation){
                    dashboardVC.status = kDirectingToMetroStation;
                }else{
                    dashboardVC.status = kAtMetroStation;
                }
            }

            self.dashboardVC = dashboardVC;
        }
    }else if([segue.identifier isEqualToString:@"setManagedObjectContext:"]){
        if([segue.destinationViewController isKindOfClass:[MetroStationCDTVC class]]){
            MetroStationCDTVC *mcdtvc = (MetroStationCDTVC *)segue.destinationViewController;
            mcdtvc.managedObjectContext = self.managedObjectContext;
            if(sender == self.dashboardVC.startJourneyButton){
                mcdtvc.startingJourney = YES;
            }
        }

    }else if([segue.identifier isEqualToString:@"setupStartJourney"]){
        if([segue.destinationViewController isKindOfClass:[UINavigationController class]]){
            if([((UINavigationController *)segue.destinationViewController).topViewController isKindOfClass:[JourneyTableViewController class]]){
                JourneyTableViewController *jtvc = (JourneyTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
                jtvc.managedObjectContext = self.managedObjectContext;
                jtvc.isStartingJourney = YES;
            }
        }

    }else if([segue.identifier isEqualToString:@"viewMetroStationDetails"]){
        if([sender isKindOfClass:[MetroStation class]]){
            if([segue.destinationViewController respondsToSelector:@selector(setMetroStation:)]){
                [segue.destinationViewController performSelector:@selector(setMetroStation:) withObject:sender];
            }

        }
    }else if([segue.identifier isEqualToString:@"viewMetroStationTrainTimings"]){
        if([sender isKindOfClass:[UIButton class]]){
            if(self.nearestMetroStation){
                if([segue.destinationViewController respondsToSelector:@selector(setMetroStation:)]){
                    [segue.destinationViewController performSelector:@selector(setMetroStation:)
                                                          withObject:self.nearestMetroStation];
                }
            }
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
- (void)setNearestMetroStation:(MetroStation *)nearestMetroStation
{
    _nearestMetroStation = nearestMetroStation;

    if(nearestMetroStation){
        self.dashboardVC.stationName = _nearestMetroStation.stationName;
        self.dashboardVC.stationProximity = _nearestMetroStation.stationProximity;

        if([DMHelper isAtStation:[self.dashboardVC.stationProximity floatValue]]){
            self.isDirectingToLocation = NO;
            self.dashboardVC.status = kAtMetroStation;
        }else{
            if(!self.isDirectingToLocation) self.isDirectingToLocation = YES;
        }
    }else{
        self.dashboardVC.status = kUnknown;
    }
}

- (void)setIsDirectingToLocation:(BOOL)isDirectingToLocation
{
    _isDirectingToLocation = isDirectingToLocation;
    if(_isDirectingToLocation) self.dashboardVC.status = kDirectingToMetroStation;
}

- (void)setupMetroStation:(id)sender
{
    [self performSegueWithIdentifier:@"viewMetroStationDetails" sender:sender];
}

- (void)viewTrainTimings
{
    [self performSegueWithIdentifier:@"viewMetroStationTrainTimings" sender:self.dashboardVC.viewTrainTimingsButton];
}

- (void)startJourney
{
    [self performSegueWithIdentifier:@"setupStartJourney" sender:self.dashboardVC.startJourneyButton];
}

#pragma mark - Core Data stuff
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    self.metroStationsMapvc.managedObjectContext = managedObjectContext;

    if([self.navigationController respondsToSelector:@selector(setManagedObjectContext:)]){
        [self.navigationController performSelector:@selector(setManagedObjectContext:) withObject:managedObjectContext];
    }

    self.nearestMetroStation = [MetroStation updateMetroStationProximitiesUsingLocationManager:self.dmLocationManager
                                                                        inManagedObjectContext:self.managedObjectContext];
    
}

- (void)populateMetroStations
{

    if([self.navigationController isKindOfClass:[DefaultNavigationController class]]){
        [(DefaultNavigationController *)self.navigationController wantsToUpdate];
    }

    dispatch_queue_t populateQ = dispatch_queue_create("Populate Metros From Plist", NULL);

    dispatch_async(populateQ, ^{

        NSDictionary *metroStationsPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                                       pathForResource:@"MetroStations"
                                                                                       ofType:@"plist"]];

        [self.managedObjectContext performBlock:^{

                //Add Stations
            [self populateMetroStationsBlock:metroStationsPlist];

                //Add Peak Time
            id peakTime = [metroStationsPlist objectForKey:@"peakTime"];
            [self populatePeakTimes:peakTime];

                //Add Ticket Prices
            id ticketPrices = [metroStationsPlist objectForKey:@"ticketPrices"];

            if([ticketPrices isKindOfClass:[NSDictionary class]]){
                [TicketPrice ticketPriceWithInfo:ticketPrices inManagedObjectContext:self.managedObjectContext];
            }

        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateMetroStationProximities];
            [self reloadMap];

            if([self.navigationController isKindOfClass:[DefaultNavigationController class]]){
                ((DefaultNavigationController *)self.navigationController).firstTimeSetupComplete = YES;
            }
        });
    });
}

- (void)populateMetroStationsBlock:(NSDictionary *)metroStationsPlist
{
    id stations = [metroStationsPlist objectForKey:@"stations"];
    id stationLines = [metroStationsPlist objectForKey:@"lines"];
    id towardsInterval = [metroStationsPlist objectForKey:@"towardsInterval"];

        //Station Lines
    if([stationLines isKindOfClass:[NSDictionary class]]){
        NSArray *stationLineCodes = [stationLines allKeys];

        for(id stationLineCode in stationLineCodes){
            if([stationLines[stationLineCode] isKindOfClass:[NSDictionary class]]){
                if([stationLines[stationLineCode][@"lineName"] isKindOfClass:[NSString class]] &&
                   [stationLines[stationLineCode][@"polylinePath"] isKindOfClass:[NSString class]]){

                    NSMutableArray *polylinePathAsArray = [NSMutableArray array];

                    NSString *polylinePath = stationLines[stationLineCode][@"polylinePath"];

                    NSArray *polylineCoordinates = [polylinePath componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

                    for(NSString *polylineCoordinate in polylineCoordinates){

                        NSArray *LatLon = [polylineCoordinate componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];

                        if([LatLon count] == 2){

                            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];

                            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                            [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:LOCALE_US]];

                            NSString *aLatitude = [(NSString*)LatLon[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSString *aLongitude = [(NSString*)LatLon[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                            [polylinePathAsArray addObject:[NSDictionary dictionaryWithObjects:@[[numberFormatter numberFromString:aLatitude],
                                                                                                 [numberFormatter numberFromString:aLongitude]]
                                                                                       forKeys:@[LINE_LATITUDE, LINE_LONGITUDE]]];
                        }
                    }

                    [MetroStationLine metroStationLineWithCode:stationLineCode
                                                          name:stationLines[stationLineCode][@"lineName"]
                                               andPolylinePath:polylinePathAsArray inManagedObjectContext:self.managedObjectContext];

                }
            }
        }
    }

        //Stations
    if([stations isKindOfClass:[NSArray class]]){
        for(id stationInfo in stations){
            if([stationInfo isKindOfClass:[NSDictionary class]]){
                MetroStation *metroStation = [MetroStation metroStationWithInfo:stationInfo
                                                         inManagedObjectContext:self.managedObjectContext];

                if([towardsInterval isKindOfClass:[NSDictionary class]]){
                    for(id stationId in towardsInterval){
                        if([towardsInterval[stationId] isKindOfClass:[NSDictionary class]]){

                            if([stationId isKindOfClass:[NSString class]]){
                                TrainBound *trainBound = [TrainBound fetchTrainBoundForBoundStationId:(NSString *)stationId
                                                                                      withFromStation:metroStation];
                                for(id dayGroup in towardsInterval[stationId]){
                                    if([dayGroup isKindOfClass:[NSString class]]){
                                        TrainTiming *timing = [TrainTiming fetchTrainTimingForTrainBound:trainBound
                                                                                             andDayGroup:(NSString *)dayGroup];
                                        if([towardsInterval[stationId][dayGroup] isKindOfClass:[NSDictionary class]]){
                                            timing.morningPeak = towardsInterval[stationId][dayGroup][@"morningPeak"];
                                            timing.eveningPeak = towardsInterval[stationId][dayGroup][@"eveningPeak"];
                                            timing.offPeak = towardsInterval[stationId][dayGroup][@"offPeak"];
                                            timing.beforeMorningPeak = towardsInterval[stationId][dayGroup][@"beforeMorningPeak"];
                                            timing.afterEveningPeak = towardsInterval[stationId][dayGroup][@"afterEveningPeak"];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)populatePeakTimes:(id)peakTimes
{
    if([peakTimes isKindOfClass:[NSDictionary class]]){
        NSArray *ptStationLineCodes = [peakTimes allKeys];

        for(id ptStationLineCode in ptStationLineCodes){
            if([ptStationLineCode isKindOfClass:[NSString class]]){
#ifdef DM_DEBUG
                NSLog(@"Station Line Code: %@", ptStationLineCode);
#endif
                MetroStationLine *stationLine = [MetroStationLine fetchMetroStationLineWithStationLineCode:ptStationLineCode
                                                                                    inManagedObjectContext:self.managedObjectContext];
#ifdef DM_DEBUG
                NSLog(@"Station line: %@", stationLine.stationLineName);
#endif

                if(stationLine){
                    if([peakTimes[ptStationLineCode] isKindOfClass:[NSDictionary class]]){
                        NSArray *dayGroups = [peakTimes[ptStationLineCode] allKeys];

                        for(id dayGroup in dayGroups){
                            if([dayGroup isKindOfClass:[NSString class]]){
                                NSString *aKeyPath = [NSString stringWithFormat:@"%@.%@.", ptStationLineCode, dayGroup];

                                [PeakTime createPeakTimeWithMorningPeakFrom:[peakTimes valueForKeyPath:[aKeyPath stringByAppendingString:@"morningPeakFrom"]]
                                                              morningPeakTo:[peakTimes valueForKeyPath:[aKeyPath stringByAppendingString:@"morningPeakTo"]]
                                                            eveningPeakFrom:[peakTimes valueForKeyPath:[aKeyPath stringByAppendingString:@"eveningPeakFrom"]]
                                                              eveningPeakTo:[peakTimes valueForKeyPath:[aKeyPath stringByAppendingString:@"eveningPeakTo"]]
                                                                   dayGroup:dayGroup andStationLine:stationLine];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)useDocument
{
    CoreDataHelper *coreDataHelper = [CoreDataHelper sharedManagedDocument];
    coreDataHelper.managedDocumentFileName = DM_MANAGED_DOCUMENT;

    self.managedDocument = coreDataHelper.managedDocument;

    if (![coreDataHelper.fileManager fileExistsAtPath:[coreDataHelper.managedDocument.fileURL path]]){
        [coreDataHelper.managedDocument saveToURL:coreDataHelper.managedDocument.fileURL
                                 forSaveOperation:UIDocumentSaveForCreating
                                completionHandler:^(BOOL success) {
                                    if (success) {
                                        self.managedObjectContext = self.managedDocument.managedObjectContext;

                                        [self populateMetroStations];
                                    }
                                }];
    } else if (self.managedDocument.documentState == UIDocumentStateClosed) {
        [self.managedDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.managedDocument.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = self.managedDocument.managedObjectContext;
    }
}

- (BOOL)coreDataHasEntriesForEntityName:(NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    [request setFetchLimit:1];

    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (!matches){
        #ifdef DM_DEBUG
        NSLog(@"DMVC Error");
        #endif
    }
    else if(![matches count]) return NO;

    return YES;
}

- (void)updateMetroStationProximities
{
    if(self.managedObjectContext && self.shouldUpdateProximity){

        if(self.dmLocationManager.isAuthorized)
            self.nearestMetroStation = [MetroStation updateMetroStationProximitiesUsingLocationManager:self.dmLocationManager
                                                                                inManagedObjectContext:self.managedObjectContext];
        else
            self.dashboardVC.status = kLocationOff;
    }
}


#pragma mark - DMLocationManager Delegate
- (void)currentLocationChangedTo:(CLLocation *)newLocation
{
    self.currentLocation = newLocation;
    [self updateMetroStationProximities];
}

- (void)currentHeadingChangedTo:(CLLocationDirection)newHeading
{
    if(self.isDirectingToLocation && self.dashboardVC.statusView.isRotatable){

        CGFloat angle = [DMHelper radiansToDegrees:(-newHeading / 180.0) * M_PI];
        CGFloat fltAngle = [DMHelper angleBetweenLocation:self.currentLocation
                                              andLocation:[[CLLocation alloc] initWithLatitude:[self.nearestMetroStation.stationLatitude floatValue]
                                                                                     longitude:[self.nearestMetroStation.stationLongitude floatValue]]];
        [self.dashboardVC rotateLayer:self.dashboardVC.statusView.layer by:[DMHelper degreesToRadians:(angle + fltAngle)]];
    }
}

- (void)authorizationStatusChangedTo:(CLAuthorizationStatus)status
{
    if(status){
        [self reloadMap];
        [self updateMetroStationProximities];

    }else{
        self.dashboardVC.status = kLocationOff;
    }
}

#pragma mark DMLocationManagerDelegate methods


@end