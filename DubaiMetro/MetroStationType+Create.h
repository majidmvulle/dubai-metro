//
//  MetroStationType+Create.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/9/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationType.h"

@interface MetroStationType (Create)
+ (MetroStationType *)metroStationTypeWithName:(NSString *)metroStationTypeName forMetroStations:(NSSet *)metroStations
                        inManagedObjectContext:(NSManagedObjectContext *)context;
@end