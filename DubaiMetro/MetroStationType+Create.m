//
//  MetroStationType+Create.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/9/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationType+Create.h"


@implementation MetroStationType (Create)

+ (MetroStationType *)metroStationTypeWithName:(NSString *)metroStationTypeName
                              forMetroStations:(NSSet *)metroStations
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    MetroStationType *metroStationType = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStationType"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationTypeName"
                                                            ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"stationTypeName MATCHES[cd] %@", metroStationTypeName];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if(!matches || ([matches count] > 1)){
            //handle error
    }else if(![matches count]){ // no record found
        metroStationType = [NSEntityDescription insertNewObjectForEntityForName:@"MetroStationType" inManagedObjectContext:context];
        metroStationType.stationTypeName = [metroStationTypeName description];
    }else{
        metroStationType = [matches lastObject];
    }

    return metroStationType;
}

@end