//
//  TrainTiming+Create.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainTiming+Create.h"
#import "TrainBound.h"

@implementation TrainTiming (Create)

+ (NSSet *)trainTimings:(NSSet *)timings forTrainBound:(TrainBound *)trainBound
{
    NSMutableSet *trainTimings = [NSMutableSet set];

    for(id timing in timings){

        if([timing isKindOfClass:[NSDictionary class]]){
            NSArray *timingKeys = [(NSDictionary *)timing allKeys];

            for(id timingKey in timingKeys){
                if([timingKey isKindOfClass:[NSString class]]){
                    NSString *dayGroup = timingKey;

                    if([timing[dayGroup] isKindOfClass:[NSDictionary class]]){
                        id firstTrain = timing[dayGroup][@"firstTrain"];
                        id lastTrain = timing[dayGroup][@"lastTrain"];

                        if([firstTrain isKindOfClass:[NSDate class]] && [lastTrain isKindOfClass:[NSDate class]]){
                            [trainTimings addObject:[TrainTiming trainTimingForTrainBound:trainBound
                                                                             withDayGroup:dayGroup
                                                                            forfirstTrain:firstTrain
                                                                             andLastTrain:lastTrain
                                                                   inManagedObjectContext:trainBound.managedObjectContext]];
                        }
                    }
                }
            }
        }
    }

    return trainTimings;
}

+ (TrainTiming *)trainTimingForTrainBound:(TrainBound *)trainBound
                             withDayGroup:(NSString *)dayGroup
                          forfirstTrain:(NSDate *)firstTrain
                        andLastTrain:(NSDate *)lastTrain
               inManagedObjectContext:(NSManagedObjectContext *)context
{
    TrainTiming *trainTiming = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TrainTiming"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dayGroup"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"dayGroup MATCHES[cd] %@ AND ANY trainBound = %@", dayGroup, trainBound];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        trainTiming = [NSEntityDescription insertNewObjectForEntityForName:@"TrainTiming" inManagedObjectContext:context];
        trainTiming.dayGroup = dayGroup;
        trainTiming.firstTrain = firstTrain;
        trainTiming.lastTrain = lastTrain;

    }else{
        trainTiming = [matches lastObject];
    }

    return trainTiming;
}

+ (TrainTiming *)fetchTrainTimingForTrainBound:(TrainBound *)trainBound andDayGroup:(NSString*)dayGroup
{
    TrainTiming *timing = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TrainTiming"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dayGroup"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"dayGroup MATCHES[cd] %@ AND ANY trainBound = %@", dayGroup, trainBound];

    NSError *error = nil;
    NSArray *matches = [trainBound.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1) || ![matches count]){
            //handle error
    }else{
        timing = [matches lastObject];
    }

    return timing;
}

@end