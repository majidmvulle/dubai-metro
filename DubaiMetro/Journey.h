//
//  Journey.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/18/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetroStation.h"
#import "TrainTime.h"

#pragma mark - JourneyInterchange declaration
@interface JourneyInterchange : NSObject
@property (nonatomic, strong) MetroStation *interchangeStation;
@property (nonatomic, strong) MetroStation *towardsStation;
@end

#pragma mark - JourneyRoute declaration
@interface JourneyRoute : NSObject
@property (nonatomic) int numberOfStationsToTravel;
@property (nonatomic, strong) MetroStation *fromStation;
@property (nonatomic, strong) MetroStation *toStation;
@property (nonatomic, strong) MetroStation *towardsStation;
@property (nonatomic, strong) NSMutableArray *interchanges; //of JourneyInterchange
@property (nonatomic, strong) NSMutableSet *stationZoneNumbers; //of Zone numbers
@property (nonatomic, strong) TrainTime *trainTime;
@end

#pragma mark - Journey declaration
@interface Journey : NSObject
- (id)initFromStation:(MetroStation *)fromStation toStation:(MetroStation *)toStation;
- (NSArray *)findJourneyRoutes; //blocks
@property (nonatomic, readonly) float ticketPrice;
@end