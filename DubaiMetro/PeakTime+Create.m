//
//  PeakTime+Create.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/29/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "PeakTime+Create.h"
#import "MetroStationLine.h"

@implementation PeakTime (Create)

+ (PeakTime *)createPeakTimeWithMorningPeakFrom:(NSDate *)morningPeakFrom
                                  morningPeakTo:(NSDate *)morningPeakTo
                                eveningPeakFrom:(NSDate *)eveningPeakFrom
                                  eveningPeakTo:(NSDate *)eveningPeakTo
                                       dayGroup:(NSString *)dayGroup
                                 andStationLine:(MetroStationLine *)stationLine
{
    PeakTime *peakTime = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PeakTime"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dayGroup"
                                                              ascending:YES]];

    request.predicate = [NSPredicate predicateWithFormat:@"stationLine = %@ AND dayGroup MATCHES[cd] %@", stationLine, dayGroup];
    NSError *error = nil;
    NSArray *matches = [stationLine.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        peakTime = [NSEntityDescription insertNewObjectForEntityForName:@"PeakTime"
                                                 inManagedObjectContext:stationLine.managedObjectContext];
        peakTime.morningPeakFrom = morningPeakFrom;
        peakTime.morningPeakTo = morningPeakTo;
        peakTime.eveningPeakFrom = eveningPeakFrom;
        peakTime.eveningPeakTo = eveningPeakTo;
        peakTime.stationLine = stationLine;
        peakTime.dayGroup = dayGroup;


    }else{
        peakTime = [matches lastObject];
    }

    return peakTime;
}

+ (PeakTime *)fetchPeakTimeFor:(MetroStationLine *)stationLine andDayGroup:(NSString *)dayGroup
{
    PeakTime *peakTime = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PeakTime"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"morningPeakFrom"
                                                              ascending:YES]];

    request.predicate = [NSPredicate predicateWithFormat:@"stationLine = %@ AND dayGroup MATCHES[cd] %@", stationLine, dayGroup];
    NSError *error = nil;
    NSArray *matches = [stationLine.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1) || ![matches count]){
            //handle error

        if(error){
#ifdef DM_DEBUG
            NSLog(@"PeakTime error: %@", error);
#endif
        }


    }else{
        peakTime = [matches lastObject];
    }

    return peakTime;
}

@end