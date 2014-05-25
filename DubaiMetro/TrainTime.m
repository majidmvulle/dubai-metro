//
//  TrainTime.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/28/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainTime.h"
#import "MetroStation+CreateFetch.h"
#import "TrainBound+Create.h"
#import "TrainTiming+Create.h"
#import "PeakTime+Create.h"
#import "MetroStation+CreateFetch.h"

@interface TrainTime()
@property (nonatomic, weak) MetroStation *metroStation;
@property (nonatomic, strong, readwrite) NSArray *boundStations;
@property (nonatomic, strong, readwrite) NSString *dayGroup;
@end

@implementation TrainTime

- (id)initWithMetroStation:(MetroStation *)station
{
    self = [self init];

    if (self){
        self.metroStation = station;
        [self setup];
    }

    return self;
}

- (void)setup
{

        //Day Group
    _dayGroup = [TrainTime currentDayGroup];

    float nowTime = [TrainTime timeFromDate:[NSDate date]];

    for(id boundStations in self.boundStations){
        if([boundStations isKindOfClass:[NSArray class]]){
            for(id station in boundStations){
                if([station isKindOfClass:[MetroStation class]]){
                    MetroStation *boundStation = station;

                    TrainTiming *todayTiming = [self trainTimingForBoundStation:boundStation andDayGroup:[TrainTime currentDayGroup]];
                    TrainTiming *yesterdayTiming = [self trainTimingForBoundStation:boundStation andDayGroup:[TrainTime previousDayGroup]];

                    float todayFirstTrain = [TrainTime timeFromDate:todayTiming.firstTrain];
                    float yesterdayLastTrain = [TrainTime timeFromDate:yesterdayTiming.lastTrain];
                    yesterdayLastTrain  -= 24*3600; //Remove a day

                    if(nowTime < todayFirstTrain){
                        if(nowTime < yesterdayLastTrain){
                            _dayGroup = [TrainTime previousDayGroup];
                            break;
                        }
                    }
                }
            }
        }
    }

        //Bound Stations
    NSMutableArray *boundStations = [NSMutableArray array];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"boundStationId"
                                                                     ascending:YES
                                                                      selector:@selector(localizedCaseInsensitiveCompare:)];

    for(TrainBound *trainBound in [self.metroStation.boundToStations sortedArrayUsingDescriptors:@[sortDescriptor]]){

        MetroStation *station = [MetroStation metroStationWithStationId:trainBound.boundStationId
                                                 inManagedObjectContext:self.metroStation.managedObjectContext];

        if(station){
            if(![boundStations count]){
                [boundStations addObject:[NSMutableArray arrayWithObject:station]];
            }else{

                NSMutableArray *indicesInBoundStations = [NSMutableArray array];

                for(NSArray *boundGroup in boundStations){
                    for(MetroStation *boundGroupStation in boundGroup){
                        if([boundGroupStation.stationLines isEqualToSet:station.stationLines]){
                            [indicesInBoundStations addObject:[NSNumber numberWithInteger:[boundStations indexOfObject:boundGroup]]];
                        }
                    }
                }

                if([indicesInBoundStations count]){
                    for(NSNumber *indexNumber in indicesInBoundStations){
                        int theIndex = [indexNumber intValue];
                        [boundStations[theIndex] addObject:station];
                    }

                }else{
                    [boundStations addObject:[NSMutableArray arrayWithObject:station]];
                }
            }
        }
    }

    _boundStations = boundStations;
    
}


- (MetroStation *)boundStationAtIndexPath:(NSIndexPath *)indexPath
{
    return (MetroStation *)self.boundStations[indexPath.section][indexPath.item];
}

- (TrainTiming *)trainTimingForBoundStation:(MetroStation *)boundStation andDayGroup:(NSString *)dayGroup
{
    TrainBound *trainBound = [TrainBound fetchTrainBoundForBoundStationId:boundStation.stationId
                                                          withFromStation:self.metroStation];

    return [TrainTiming fetchTrainTimingForTrainBound:trainBound andDayGroup:dayGroup];
}

- (TrainTiming *)trainTimingForBoundStationAt:(NSIndexPath *)indexPath andDayGroup:(NSString *)dayGroup
{
    MetroStation *boundStation = [self boundStationAtIndexPath:indexPath];

    return [self trainTimingForBoundStation:boundStation andDayGroup:dayGroup];
}

- (float)nextTrain:(TrainTiming *)timing metroStationLine:(MetroStationLine *)stationLine dayGroup:(NSString *)dayGroup
{
    PeakTime *peakTime = [PeakTime fetchPeakTimeFor:stationLine andDayGroup:dayGroup];

    float firstTrain = [TrainTime timeFromDate:timing.firstTrain];
    float currentTime = [TrainTime timeFromDate:[NSDate date]];

    float morningPeakFrom = [TrainTime timeFromDate:peakTime.morningPeakFrom];
    float morningPeakTo = [TrainTime timeFromDate:peakTime.morningPeakTo];
    float eveningPeakFrom = [TrainTime timeFromDate:peakTime.eveningPeakFrom];
    float eveningPeakTo = [TrainTime timeFromDate:peakTime.eveningPeakTo];

    float morningPeakInterval = [timing.morningPeak floatValue]; //in seconds

    float beforeMorningPeak = morningPeakFrom - 1; //seconds
    float beforeMorningPeakInterval = [timing.beforeMorningPeak floatValue];

    float eveningPeakInterval = [timing.eveningPeak floatValue]; //in seconds

    float afterEveningPeak = eveningPeakTo + 1; //seconds
    float afterEveningPeakInterval = [timing.afterEveningPeak floatValue];

    float offPeakInterval = [timing.offPeak floatValue]; //in seconds

    float nextTrain = 0;

    if(firstTrain > currentTime && ![dayGroup isEqualToString:[TrainTime currentDayGroup]]){
        firstTrain -= (24*3600); //Remove a day
    }

    for(nextTrain = firstTrain; nextTrain <= currentTime;){

        if(currentTime >= eveningPeakFrom &&
           currentTime <= eveningPeakTo){ //in evening peak
            nextTrain += eveningPeakInterval;

        }else if(currentTime >= morningPeakFrom &&
                 currentTime <= morningPeakTo){ //in morning peak
            nextTrain += morningPeakInterval;

        }else if(currentTime <= beforeMorningPeak){
            nextTrain += beforeMorningPeakInterval;

        }else if(currentTime >= afterEveningPeak){
            nextTrain += afterEveningPeakInterval;

        }else{ //off peak
            nextTrain += offPeakInterval;
        }
    }

    return nextTrain;
}

- (NSArray *)nextTrainBoundStation:(MetroStation *)boundStation
{
    TrainTiming *todayTiming = [self trainTimingForBoundStation:boundStation andDayGroup:[TrainTime currentDayGroup]];

    TrainTiming *yesterdayTiming = [self trainTimingForBoundStation:boundStation andDayGroup:[TrainTime previousDayGroup]];

    MetroStationLine *stationLine = [boundStation.stationLines anyObject];

    float currentTime = [TrainTime timeFromDate:[NSDate date]];

    TrainTiming *aTiming = [self trainTimingForBoundStation:boundStation andDayGroup:self.dayGroup];
    float nextTrainTime = [self nextTrain:aTiming metroStationLine:stationLine dayGroup:self.dayGroup];

    NSString *minuteText = @"";
    NSString *minuteSuffixText = @"";

    float firstTrainTime = ([TrainTime timeFromDate:todayTiming.firstTrain] - FIRST_TRAIN_TIME);
    float lastTrainTime = [TrainTime timeFromDate:todayTiming.lastTrain];

    if(lastTrainTime <= firstTrainTime){
        lastTrainTime += 24*3600; //Add a day
    }

    if([self.dayGroup isEqualToString:[TrainTime currentDayGroup]]){

        if(currentTime <  firstTrainTime || currentTime > lastTrainTime || nextTrainTime > lastTrainTime){
            minuteText = @"-";
        }else{
            minuteText = nil;
        }
    }else{
        float previousDayLastTrainTime = [TrainTime timeFromDate:yesterdayTiming.lastTrain];

        previousDayLastTrainTime  -= 24*3600; //Remove a day

        if(currentTime > previousDayLastTrainTime || nextTrainTime > previousDayLastTrainTime){
            minuteText = @"-";
        }else{
            minuteText = nil;
        }
    }

    if(!minuteText){
        int minutesToNextTrain = (int)((nextTrainTime - currentTime)/60);

        if(minutesToNextTrain <= 0){
            minuteText = @"";
        }else{
            minuteText = [NSString stringWithFormat:@"%d", minutesToNextTrain];

            if(minutesToNextTrain == 1){
                minuteSuffixText = @"minute";
            }else{
                minuteSuffixText = @"minutes";
            }
        }
    }

    return @[minuteText, minuteSuffixText];
}


+ (float)timeFromDate:(NSDate *)theDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theDate];

    NSInteger hour = [components hour];
    NSInteger minute = [components minute];

    NSString *timeString = [NSString stringWithFormat:@"%d:%d", (int)hour, (int)minute];

    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GST"]];

    return [timeFormatter dateFromString:timeString].timeIntervalSinceReferenceDate;
}

+ (NSDateFormatter *)twentyFourHourTimeFormatter
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GST"]];

    return timeFormatter;
}

+ (NSDateFormatter *)twelveHourTimeFormatter
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [timeFormatter setDateFormat:@"hh:mm a"];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GST"]];

    return timeFormatter;
}

+ (NSString *)dayGroup:(NSString *)day
{
    NSString *dayGroup = @"";

    if([day isEqualToString:@"Thursday"] ||
       [day isEqualToString:@"Friday"] ||
       [day isEqualToString:@"Saturday"]){
        dayGroup = [day lowercaseString];
    }else{
        dayGroup = @"sundayToWednesday";
    }

    return dayGroup;
}

+ (NSString *)currentDayGroup
{
    return [TrainTime dayGroup:[TrainTime today]];
}

+ (NSString *)previousDayGroup
{
    return [TrainTime dayGroup:[TrainTime yesterday]];
}

+ (NSString *)today
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat: @"EEEE"];

    return [formatter stringFromDate: today];
}

+ (NSString *)yesterday
{
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat: @"EEEE"];

    return [formatter stringFromDate: yesterday];
}

+ (NSString *)todayFullShortDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat: @"dd-MMM-YYYY"];

    return [[formatter stringFromDate: today] uppercaseString];
}

@end