//
//  MetroStationType.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetroStation;

@interface MetroStationType : NSManagedObject

@property (nonatomic, retain) NSString * stationTypeName;
@property (nonatomic, retain) NSSet *stations;
@end

@interface MetroStationType (CoreDataGeneratedAccessors)

- (void)addStationsObject:(MetroStation *)value;
- (void)removeStationsObject:(MetroStation *)value;
- (void)addStations:(NSSet *)values;
- (void)removeStations:(NSSet *)values;

@end
