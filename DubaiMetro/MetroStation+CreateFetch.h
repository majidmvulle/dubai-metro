//
//  MetroStation+CreateEdit.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/14/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStation.h"

@class CLLocationManager;
@interface MetroStation (CreateFetch)
+ (MetroStation *)metroStationWithInfo:(NSDictionary *)metroStationDictionary
                inManagedObjectContext:(NSManagedObjectContext *)context;

    //returns nearest Metro Station
+ (MetroStation *)updateMetroStationProximitiesUsingLocationManager:(CLLocationManager *)locationManager
                                             inManagedObjectContext:(NSManagedObjectContext *)context;//blocks main thread
+ (MetroStation *)metroStationWithStationId:(NSString *)stationId
                     inManagedObjectContext:(NSManagedObjectContext *)context;
@end