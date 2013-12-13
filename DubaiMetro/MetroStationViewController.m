//
//  MetroStationViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/15/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationViewController.h"
#import "MetroStation+MKAnnotation.h"
#import "MetroStation+CreateFetch.h"
#import "MapViewController.h"
#import "MetroStationType.h"
#import "MetroStationLine.h"
#import "DMLocationManager.h"
#import "MetroStationMapViewController.h"

@interface MetroStationViewController () <DMLocationManagerDelegate>
@property (nonatomic, strong) DMLocationManager *dmLocationManager;
@property (weak, nonatomic) IBOutlet UILabel *lines;
@property (weak, nonatomic) IBOutlet UILabel *zone;
@property (weak, nonatomic) IBOutlet UILabel *types;
@property (weak, nonatomic) IBOutlet UILabel *parking;
@property (weak, nonatomic) IBOutlet UILabel *attractions;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *proximity;
@property (nonatomic, strong) MetroStationMapViewController *mapvc;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation MetroStationViewController

#pragma mark - UIViewController Delegate Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapvc.mapView addAnnotation:self.metroStation];
    [self setupFonts];
    [self setupMetroStation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

        //Bug in iOS 6:
    /*  After returning from a modally/push presented UIViewController to a scene containing a UIScrollView, the UIScrollView takes whatever point it's currently scrolled to and starts behaving as though that is its origin. That means that if you'd scrolled down your scroll view before modally/pushly presenting another View Controller, you can't scroll back up upon returning to the scene with the scroll view*/
    if(![DMHelper sharedInstance].isOS7AndAbove)
        self.scrollView.contentOffset = CGPointMake(0,0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupLocationManager];
    [DMHelper trackScreenWithName:[NSString stringWithFormat:@"Metro Station Details: %@", self.metroStation.stationName]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self cleanup];
}

- (void)setMetroStation:(MetroStation *)metroStation
{
    _metroStation = metroStation;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Embed Map View"]){
        if([segue.destinationViewController isKindOfClass:[MetroStationMapViewController class]]){
            self.mapvc = segue.destinationViewController;
        }
    }else if([segue.identifier isEqualToString:@"setMetroStation:"]){
        if([segue.destinationViewController respondsToSelector:@selector(setMetroStation:)]){
            [segue.destinationViewController performSelector:@selector(setMetroStation:) withObject:self.metroStation];
        }
    }
}

- (void)setupLocationManager
{
    self.dmLocationManager = [DMLocationManager sharedInstance];
    self.dmLocationManager.dmLocationDelegate = self;

    [self.dmLocationManager startStandardChangeUpdates];

}

- (void)cleanup
{
    [self.dmLocationManager stopChangeUpdates];
    self.dmLocationManager.dmLocationDelegate = nil;
    self.dmLocationManager = nil;
}


- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    _currentLocation = currentLocation;
    [MetroStation updateMetroStationProximitiesUsingLocationManager:self.dmLocationManager
                                             inManagedObjectContext:self.metroStation.managedObjectContext];
    self.proximity.text = [self getProximityText];
}

- (void)setupMetroStation
{
    NSString *name =  [self.metroStation.stationName capitalizedString];

    self.title = name;

    NSMutableArray *lines = [NSMutableArray array];

    [[self.metroStation.stationLines allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [lines addObject:((MetroStationLine *)obj).stationLineName];
    }];

    NSMutableArray *types = [NSMutableArray array];

    [[self.metroStation.stationTypes allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [types addObject:((MetroStationType *)obj).stationTypeName];
    }];


    unichar newLine = '\n';

    self.lines.text =[NSString stringWithFormat:@"%@", [[lines componentsJoinedByString:@", "] uppercaseString]];
    self.zone.text =[NSString stringWithFormat:@"%d", [self.metroStation.stationZone intValue]];
    self.types.text =[NSString stringWithFormat:@"%@", [types componentsJoinedByString:[NSString stringWithCharacters:&newLine length:1]]];
    self.parking.text = [NSString stringWithFormat:@"%@", [self.metroStation.stationParking length] ?
                         [self.metroStation.stationParking stringByReplacingOccurrencesOfString:@", "
                                                                                     withString:[NSString stringWithCharacters:&newLine
                                                                                                                        length:1]] : @"NOT AVAILABLE"];

    self.attractions.text = [NSString stringWithFormat:@"%@", [self.metroStation.stationAttractions length] ?
                             [self.metroStation.stationAttractions stringByReplacingOccurrencesOfString:@", "
                                                                                             withString:[NSString stringWithCharacters:&newLine
                                                                                                                                length:1]]: @"NONE"];

    self.status.text = [NSString stringWithFormat:@"%@", [self.metroStation.isStationOperational intValue] ? DM_STATION_ACTIVE : DM_STATION_NOT_ACTIVE];

    self.proximity.text = [self getProximityText];
}

- (void)setupFonts
{
    for(id subview in self.view.subviews){
        if([subview isKindOfClass:[UILabel class]]){
            ((UILabel *)subview).font = [DMHelper dmFontWithSize:((UILabel *)subview).font.pointSize];
        }else if([subview isKindOfClass:[UIButton class]]){
            ((UIButton *)subview).titleLabel.font = [DMHelper dmFontWithSize:((UIButton *)subview).titleLabel.font.pointSize];
        }else if([subview isKindOfClass:[UITextView class]]){
            ((UITextView *)subview).font = [DMHelper dmFontWithSize:((UITextView *)subview).font.pointSize];
        }
    }

    /*
    for(id subview in self.scrollView.subviews){
        if([subview isKindOfClass:[UILabel class]]){
            ((UILabel *)subview).font = [DMHelper dmFontWithSize:((UILabel *)subview).font.pointSize];
        }else if([subview isKindOfClass:[UIButton class]]){
            ((UIButton *)subview).titleLabel.font = [DMHelper dmFontWithSize:((UIButton *)subview).titleLabel.font.pointSize];
        }else if([subview isKindOfClass:[UITextView class]]){
            ((UITextView *)subview).font = [DMHelper dmFontWithSize:((UITextView *)subview).font.pointSize];
        }
    }
     */
}

- (NSString *)getProximityText
{
    DistanceSuffix distanceSuffix;
    distanceSuffix.isShortSuffix = NO;
    distanceSuffix.isLongSuffix = YES;

    if([DMHelper isAtStation:[self.metroStation.stationProximity floatValue]]) return AT_STATION_TEXT;
    
    return [NSString stringWithFormat:@"%@ %@", [[DMHelper sharedInstance]
                                                 formatDistance:self.metroStation.stationProximity
                                                 withSuffix:distanceSuffix], @"Away"];
}

#pragma mark DMLocatioManagerDelegate Methods

- (void)currentLocationChangedTo:(CLLocation *)newLocation
{
    self.currentLocation = newLocation;
}

- (void)authorizationStatusChangedTo:(CLAuthorizationStatus)status
{

}

@end
