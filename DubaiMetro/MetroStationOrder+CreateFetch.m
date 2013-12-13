//
//  MetroStationOrder+CreateFetch.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationOrder+CreateFetch.h"
#import "MetroStation.h"

@implementation MetroStationOrder (CreateFetch)

+ (MetroStationOrder *)createStationNumber:(NSNumber *)stationNumber
                                    station:(MetroStation *)station
                                stationLine:(MetroStationLine *)stationLine
{
    MetroStationOrder *metroStationOrder = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationOrder"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationNumber" ascending:YES]];

    request.predicate = [NSPredicate predicateWithFormat:@"station == %@ AND stationLine == %@", station, stationLine];

    NSError *error = nil;
    NSArray *matches = [station.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        metroStationOrder = [NSEntityDescription insertNewObjectForEntityForName:@"MetroStationOrder"
                                                          inManagedObjectContext:station.managedObjectContext];
        metroStationOrder.station = station;
        metroStationOrder.stationLine = stationLine;
        metroStationOrder.stationNumber = stationNumber;

    }else{
        metroStationOrder = [matches lastObject];
    }

    return metroStationOrder;
}

+ (MetroStationOrder *)fetchStationOrder:(MetroStation *)station stationLine:(MetroStationLine *)stationLine
{
    MetroStationOrder *metroStationOrder = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationOrder"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationNumber" ascending:YES]];

    request.predicate = [NSPredicate predicateWithFormat:@"station == %@ AND stationLine == %@", station, stationLine];

    NSError *error = nil;
    NSArray *matches = [station.managedObjectContext executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1) || ![matches count]){
            //handle error
    }else{
        metroStationOrder = [matches lastObject];
    }
    
    return metroStationOrder;
}
@end
