//
//  TrainTiming+Create.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainTiming.h"

@interface TrainTiming (Create)
+ (NSSet *)trainTimings:(NSSet *)timings forTrainBound:(TrainBound *)trainBound;
+ (TrainTiming *)fetchTrainTimingForTrainBound:(TrainBound *)trainBound andDayGroup:(NSString*)dayGroup;
@end