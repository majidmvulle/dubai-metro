//
//  Settings.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/15/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "Settings.h"
#import "GAI.h"

#define ALL_SETTINGS_KEY @"All_Settings"
#define SETTINGS_KEY @"Settings"
#define SETTINGS_MEASUREMENT @"Measurement"
#define SETTINGS_TIME @"Time"
#define SETTINGS_TRACKING @"Tracking"
#define SETTINGS_MAP_TYPE @"MapType"
#define SETTINGS_FIRST_LAUNCH @"FirstLaunch"

@implementation Settings

+ (Settings *)sharedInstance
{

    static dispatch_once_t settingsDispatcher = 0;
    __strong static Settings *_sharedInstance = nil;

    dispatch_once(&settingsDispatcher, ^{
        _sharedInstance = [[self alloc] init];

        NSDictionary *allSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_SETTINGS_KEY];

        if(allSettings){
            _sharedInstance.measurementImperial = [allSettings[SETTINGS_KEY][SETTINGS_MEASUREMENT] boolValue];
            _sharedInstance.timeTwelveHour = [allSettings[SETTINGS_KEY][SETTINGS_TIME] boolValue];
            _sharedInstance.shouldTrackUsage = [allSettings[SETTINGS_KEY][SETTINGS_TRACKING] boolValue];
            _sharedInstance.mapType = [allSettings[SETTINGS_KEY][SETTINGS_MAP_TYPE] integerValue];
            _sharedInstance.firstLaunch = [allSettings[SETTINGS_KEY][SETTINGS_FIRST_LAUNCH] boolValue];
        }

        [_sharedInstance synchronize];

    });

    return _sharedInstance;
    
}

- (void)synchronize
{
    NSMutableDictionary *mutableUserDefaults = [[[NSUserDefaults standardUserDefaults]
                                                 dictionaryForKey:ALL_SETTINGS_KEY] mutableCopy];
    if(!mutableUserDefaults){
        mutableUserDefaults = [[NSMutableDictionary alloc] init];

            //Set default measurement
        self.measurementImperial = ![[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem]  boolValue];
        self.timeTwelveHour = ![self isDefaultTimeTwentyFourHourFormat];
        self.shouldTrackUsage = YES; //Tracking allowed
        self.mapType = 0; //MKMapTypeStandard
        self.firstLaunch = YES;
    }

    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:self.isMeasurementImperial],
                                                               [NSNumber numberWithBool:self.isTimeTwelveHour],
                                                               [NSNumber numberWithBool:self.shouldTrackUsage],
                                                               [NSNumber numberWithInteger:self.mapType],
                                                               [NSNumber numberWithBool:self.firstLaunch]]
                                                     forKeys:@[SETTINGS_MEASUREMENT,
                                                               SETTINGS_TIME,
                                                               SETTINGS_TRACKING,
                                                               SETTINGS_MAP_TYPE,
                                                               SETTINGS_FIRST_LAUNCH]];

    [mutableUserDefaults setObject:dict forKey:SETTINGS_KEY];

    [[NSUserDefaults standardUserDefaults] setObject:mutableUserDefaults forKey:ALL_SETTINGS_KEY];

    if([[NSUserDefaults standardUserDefaults] synchronize]){
#ifdef DM_DEBUG
        NSLog(@"Synchronized Settings");
#endif
            //GAI Optout: YES, means should NOT be tracked
            //GAI Optout: NO, means should be tracked

            //DM Settings: YES, means should be tracked
            //DM Settings: NO, means should NOT be tracked
        if([GAI sharedInstance].optOut == self.shouldTrackUsage){
            [GAI sharedInstance].optOut = !self.shouldTrackUsage;
        }
    }else{
#ifdef DM_DEBUG
        NSLog(@"NOT Synchronized Settings");
#endif
    }

}

- (BOOL)isDefaultTimeTwentyFourHourFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];

    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;

    return is24Hour;
}

@end