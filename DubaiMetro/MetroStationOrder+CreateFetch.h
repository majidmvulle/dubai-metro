//
//  MetroStationOrder+CreateFetch.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationOrder.h"

@interface MetroStationOrder (CreateFetch)
+ (MetroStationOrder *)createStationNumber:(NSNumber *)stationNumber
                                   station:(MetroStation *)station
                               stationLine:(MetroStationLine *)stationLine;
+ (MetroStationOrder *)fetchStationOrder:(MetroStation *)station stationLine:(MetroStationLine *)stationLine;
@end