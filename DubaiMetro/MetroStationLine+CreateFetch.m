//
//  MetroStationLine+Create.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/9/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationLine+CreateFetch.h"

@implementation MetroStationLine (CreateFetch)

+ (MetroStationLine *)metroStationLineWithCode:(NSString *)stationLineCode
                                          name:(NSString *)stationLineName
                               andPolylinePath:(NSArray *)polylinePath
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    MetroStationLine *metroStationLine = nil;

    stationLineName = [stationLineName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationLine"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationLineName"
                                                            ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"stationLineCode MATCHES %@", stationLineCode];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        metroStationLine = [NSEntityDescription insertNewObjectForEntityForName:@"MetroStationLine" inManagedObjectContext:context];
        metroStationLine.stationLineName = [stationLineName description];
        metroStationLine.stationLineCode = [stationLineCode description];
        metroStationLine.polylinePath = [NSKeyedArchiver archivedDataWithRootObject:polylinePath];
    }else{
        metroStationLine = [matches lastObject];
    }

    return metroStationLine;
}

+ (MetroStationLine *)fetchMetroStationLineWithStationLineCode:(NSString *)stationLineCode
                     inManagedObjectContext:(NSManagedObjectContext *)context
{
    MetroStationLine *metroStationLine = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationLine"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationLineCode"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"stationLineCode MATCHES %@", stationLineCode];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1) || ![matches count]){
            //handle error
    }else{
        metroStationLine = [matches lastObject];
    }

    return metroStationLine;
}

+ (NSArray *)fetchAllMetroStationLinesinManagedObjectContext:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationLine"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationLineCode"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = nil;

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1) || ![matches count]){
            //handle error
    }

    return matches;
}

+ (NSArray *)metroStationsForLine:(MetroStationLine *)stationLine
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationLine"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationLineCode"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = nil;

    NSError *error = nil;
    NSArray *matches = [stationLine.managedObjectContext executeFetchRequest:request error:&error];



    if(!matches || ([matches count] > 1) || ![matches count]){
            //handle error
    }

    return matches;
}

@end