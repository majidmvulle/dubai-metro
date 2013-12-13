//
//  TrainTiming.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TrainBound;

@interface TrainTiming : NSManagedObject

@property (nonatomic, retain) NSNumber * afterEveningPeak;
@property (nonatomic, retain) NSNumber * beforeMorningPeak;
@property (nonatomic, retain) NSString * dayGroup;
@property (nonatomic, retain) NSNumber * eveningPeak;
@property (nonatomic, retain) NSDate * firstTrain;
@property (nonatomic, retain) NSDate * lastTrain;
@property (nonatomic, retain) NSNumber * morningPeak;
@property (nonatomic, retain) NSNumber * offPeak;
@property (nonatomic, retain) NSSet *trainBound;
@end

@interface TrainTiming (CoreDataGeneratedAccessors)

- (void)addTrainBoundObject:(TrainBound *)value;
- (void)removeTrainBoundObject:(TrainBound *)value;
- (void)addTrainBound:(NSSet *)values;
- (void)removeTrainBound:(NSSet *)values;

@end
