//
//  TrainBound+Create.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainBound.h"

@interface TrainBound (Create)
+ (NSSet *)trainBounds:(NSSet *)boundStations fromStation:(MetroStation *)fromStation;
+ (TrainBound *)fetchTrainBoundForBoundStationId:(NSString *)boundStationId withFromStation:(MetroStation *)fromStation;
@end