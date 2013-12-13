//
//  TrainBound+Create.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainBound+Create.h"
#import "TrainTiming+Create.h"
#import "MetroStation.h"

@implementation TrainBound (Create)

+ (NSSet *)trainBounds:(NSSet *)boundStations fromStation:(MetroStation *)fromStation
{
    NSMutableSet *trainBounds = [NSMutableSet set];
    NSString *boundStationId = @"";

    for(id boundStation in boundStations){
        if([boundStation isKindOfClass:[NSDictionary class]]){
            id aKey = [[boundStation allKeys] lastObject];

            if([aKey isKindOfClass:[NSString class]]){
                boundStationId = (NSString *)aKey;
                TrainBound *trainBound = [self createTrainBoundToStationId:boundStationId fromStation:fromStation];
                [trainBound addBoundFromStationsObject:fromStation];

                if([boundStation isKindOfClass:[NSDictionary class]]){
                    NSArray *stationBoundKeys = [(NSDictionary *)boundStation allKeys];

                    NSMutableSet *timings = [NSMutableSet set];

                    for(id stationBoundKey in stationBoundKeys){
                        if([boundStation[stationBoundKey] isKindOfClass:[NSDictionary class]]){

                            NSArray *timingKeys = [(NSDictionary *)boundStation[stationBoundKey] allKeys];

                            for(id timingKey in timingKeys){
                                NSMutableDictionary *aDictionary = [NSMutableDictionary dictionary];

                                [aDictionary setObject:boundStation[stationBoundKey][timingKey] forKey:timingKey];
                                [timings addObject:aDictionary];

                            }
                        }
                    }
                    
                    trainBound.trainTiming = [TrainTiming trainTimings:timings forTrainBound:trainBound];
                }
                
                [trainBounds addObject:trainBound];
            }
        }
    }

    return trainBounds;
}

+ (TrainBound *)createTrainBoundToStationId:(NSString *)boundStationId fromStation:(MetroStation *)fromStation
{
    TrainBound *trainBound = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TrainBound"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"boundStationId"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"boundStationId MATCHES[cd] %@ AND %@ IN boundFromStations",
                         boundStationId, fromStation];

    NSError *error = nil;
    NSArray *matches = [fromStation.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        trainBound = [NSEntityDescription insertNewObjectForEntityForName:@"TrainBound"
                                                   inManagedObjectContext:fromStation.managedObjectContext];
        trainBound.boundStationId = boundStationId;

    }else{
        trainBound = [matches lastObject];
    }

    return trainBound;
}


+ (TrainBound *)fetchTrainBoundForBoundStationId:(NSString *)boundStationId withFromStation:(MetroStation *)fromStation
{
    TrainBound *trainBound = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TrainBound"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"boundStationId"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"boundStationId MATCHES[cd] %@ AND ANY boundFromStations.stationId MATCHES[cd] %@",
                         boundStationId, fromStation.stationId];

    NSError *error = nil;
    NSArray *matches = [fromStation.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        trainBound = [NSEntityDescription insertNewObjectForEntityForName:@"TrainBound"
                                                   inManagedObjectContext:fromStation.managedObjectContext];
        trainBound.boundStationId = boundStationId;

    }else{
        trainBound = [matches lastObject];
    }
    
    return trainBound;
}

@end