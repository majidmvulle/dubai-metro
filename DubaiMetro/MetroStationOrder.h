//
//  MetroStationOrder.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetroStation, MetroStationLine;

@interface MetroStationOrder : NSManagedObject

@property (nonatomic, retain) NSNumber * stationNumber;
@property (nonatomic, retain) MetroStation *station;
@property (nonatomic, retain) MetroStationLine *stationLine;

@end
