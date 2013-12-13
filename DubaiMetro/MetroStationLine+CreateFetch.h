//
//  MetroStationLine+Create.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/9/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationLine.h"

@interface MetroStationLine (CreateFetch)
+ (MetroStationLine *)metroStationLineWithCode:(NSString *)stationLineCode name:(NSString *)stationLineName
                               andPolylinePath:(NSArray *)polylinePath
                        inManagedObjectContext:(NSManagedObjectContext *)context;
+ (MetroStationLine *)fetchMetroStationLineWithStationLineCode:(NSString *)stationLineCode
                     inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchAllMetroStationLinesinManagedObjectContext:(NSManagedObjectContext *)context;
@end