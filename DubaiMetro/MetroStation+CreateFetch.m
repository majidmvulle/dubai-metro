//
//  MetroStation+CreateEdit.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/14/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStation+CreateFetch.h"
#import "MetroStationLine+CreateFetch.h"
#import "MetroStationType+Create.h"
#import "TrainBound+Create.h"
#import "MetroStationOrder+CreateFetch.h"
#import "DMLocationManager.h"

@implementation MetroStation (CreateFetch)

+ (MetroStation *)metroStationWithInfo:(NSDictionary *)metroStationDictionary
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    MetroStation *metroStation = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStation"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationName"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"stationId MATCHES[cd] %@", metroStationDictionary[@"stationId"]];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ //no record found

        metroStation = [NSEntityDescription insertNewObjectForEntityForName:@"MetroStation" inManagedObjectContext:context];
        metroStation.stationId = [metroStationDictionary[@"stationId"] description];
        metroStation.stationName = [metroStationDictionary[@"stationName"] description];
        metroStation.stationParking = [metroStationDictionary[@"stationParking"] description];
        metroStation.stationLatitude = metroStationDictionary[@"stationLatitude"];
        metroStation.stationLongitude = metroStationDictionary[@"stationLongitude"] ;
        metroStation.stationAttractions = [metroStationDictionary[@"stationAttractions"] description];
        metroStation.isStationOperational = metroStationDictionary[@"isStationOperational"];
        metroStation.stationZone = metroStationDictionary[@"stationZone"];

        NSDictionary *stationTowards = metroStationDictionary[@"stationTowards"];

        if([stationTowards count] > 0){

            NSArray *stationTowardsKeys = [stationTowards allKeys];

            NSMutableSet *boundStations = [NSMutableSet set];

            for(id stationTowardsKey in stationTowardsKeys){
                NSMutableDictionary *aDictionary = [NSMutableDictionary dictionary];

                [aDictionary setObject:stationTowards[stationTowardsKey] forKey:stationTowardsKey];
                [boundStations addObject:aDictionary];
            }
            
            metroStation.boundToStations = [TrainBound trainBounds:boundStations fromStation:metroStation];
        }

            //Station Lines
        id stationLines = metroStationDictionary[@"stationLine"];

        if([stationLines isKindOfClass:[NSDictionary class]]){
            NSMutableSet *aMutableSet = [NSMutableSet set];
            for(id stationLineCode in stationLines){
                if([stationLineCode isKindOfClass:[NSString class]]){
                    MetroStationLine *stationLine = [MetroStationLine fetchMetroStationLineWithStationLineCode:stationLineCode inManagedObjectContext:context];

                    if(stationLine){
                        [aMutableSet addObject:stationLine];
                        [MetroStationOrder createStationNumber:stationLines[stationLineCode]
                                                        station:metroStation stationLine:stationLine];
                    }
                }
            }
            metroStation.stationLines = aMutableSet;
        }

            //Station Type
        id stationType = metroStationDictionary[@"stationType"];

        if([stationType isKindOfClass:[NSArray class]]){
            NSMutableSet *aMutableSet = [NSMutableSet set];

            for(id stationTypeName in stationType){
                if([stationTypeName isKindOfClass:[NSString class]]){
                    [aMutableSet addObject:[MetroStationType metroStationTypeWithName:stationTypeName
                                                                     forMetroStations:[NSSet setWithObject:metroStation]
                                                               inManagedObjectContext:context]];
                }
            }

            metroStation.stationTypes = aMutableSet;
        }
        
    }else{
        metroStation = [matches lastObject];
    }
    
    return metroStation;
}

+ (MetroStation *)updateMetroStationProximitiesUsingLocationManager:(CLLocationManager *)locationManager
                                   inManagedObjectContext:(NSManagedObjectContext *)context
{
    MetroStation *station = nil;

    if([locationManager isKindOfClass:[DMLocationManager class]]){
        if(((DMLocationManager *)locationManager).isAuthorized){

            CLLocation *locationManagerLocation = locationManager.location;

                //Think about running on another thread but synchronizing with the main Thread
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStation"];
            request.predicate = nil;

            NSError *error = nil;
            NSArray *matches = [context executeFetchRequest:request error:&error];

                //if all is well
            if(matches && [matches count] && !error){
                NSMutableArray *metroStations = [NSMutableArray array];

                for(MetroStation *metroStation in matches){
                    CLLocation *location = [[CLLocation alloc]
                                            initWithLatitude:[metroStation.stationLatitude doubleValue]
                                            longitude:[metroStation.stationLongitude doubleValue]];

                    CLLocationDistance distance = [locationManagerLocation distanceFromLocation:location];

                    metroStation.stationProximity = [NSNumber numberWithDouble:distance];

                    [metroStations addObject:metroStation];
                }

                NSArray *sortedStations = [metroStations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
                        //smallest to largest
                    return [((MetroStation *)obj1).stationProximity compare:((MetroStation *)obj2).stationProximity];
                }];

                if([((MetroStation *)[sortedStations firstObject]).stationProximity floatValue] <= NEAREST_STATION_THRESHOLD)
                    station = [sortedStations firstObject];
                
            }else{
#ifdef DM_DEBUG
                NSLog(@"Update Station Proximities, Error: %@", error);
#endif
                    //handle error
            }
        }
    }

    return station;
}

+ (MetroStation *)nearestMetroStationinManagedObjectContext:(NSManagedObjectContext *)context
{
    MetroStation *metroStation = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStation"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationProximity" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"stationProximity <= %f", NEAREST_STATION_THRESHOLD];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ![matches count]){
            //handle error
    }else{
        //We flipped the results, since we said ascending:NO above
        metroStation = [matches lastObject];
    }

    return metroStation;
}

+ (MetroStation *)metroStationWithStationId:(NSString *)stationId
                     inManagedObjectContext:(NSManagedObjectContext *)context
{
    MetroStation *metroStation = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStation"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationName"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"stationId MATCHES[cd] %@", stationId];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
#ifdef DM_DEBUG
        NSLog(@"Metro Station CD Error: %@", error);
#endif
    }else{
        metroStation = [matches lastObject];
    }

    return metroStation;
}

@end