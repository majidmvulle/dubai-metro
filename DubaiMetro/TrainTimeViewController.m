//
//  TrainTimingViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/25/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainTimeViewController.h"
#import "TrainTimeCellHeader.h"
#import "MetroStation.h"
#import "MetroStationLine.h"
#import "TrainTime.h"
#import "TrainTimeCollectionViewCell.h"
#import "Settings.h"

@interface TrainTimeViewController ()<UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *trainTimeCollectionView;
@property (nonatomic, strong) TrainTime *trainTime;
@property (nonatomic, strong) NSTimer *aTimer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation TrainTimeViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [[self.metroStation.stationName uppercaseString] stringByAppendingString:@" Train Timings"];
    
    if(!self.trainTime.boundStations && self.metroStation) [self setupTrainTime];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.aTimer = [NSTimer timerWithTimeInterval:TRAIN_TIME_UPDATE_INTERVAL
                                          target:self selector:@selector(updateAllTimings)
                                        userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.aTimer forMode:NSDefaultRunLoopMode];

    [DMHelper trackScreenWithName:[NSString stringWithFormat:@"Train Timings: %@", self.metroStation.stationName]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.aTimer invalidate];
    self.aTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMetroStation:(MetroStation *)metroStation
{
    _metroStation = metroStation;
    if(!self.trainTime.boundStations) [self setupTrainTime];

}

- (void)setupTrainTime
{
    dispatch_queue_t aQueue = dispatch_queue_create("Set up Train Time", NULL);

    dispatch_async(aQueue, ^{
       __block TrainTime *trainTime = nil;

        [self.metroStation.managedObjectContext performBlockAndWait:^{
         trainTime = [[TrainTime alloc] initWithMetroStation:self.metroStation];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.trainTime = trainTime;
        });

    });
}


- (void)setTrainTime:(TrainTime *)trainTime
{
    _trainTime = trainTime;

    if(trainTime){
        [self.spinner stopAnimating];

        [self.trainTimeCollectionView reloadData];
    }
}

- (void)updateAllTimings
{
    for (id cell in [self.trainTimeCollectionView visibleCells]){
        [self updateNextTrainTimeForCell:cell indexPath:[self.trainTimeCollectionView indexPathForCell:cell]];
    }
}

- (void)updateNextTrainTimeForCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath
{

    if([cell isKindOfClass:[TrainTimeCollectionViewCell class]]){
        MetroStation *boundStation = [self.trainTime boundStationAtIndexPath:indexPath];
        TrainTiming *aTiming = [self.trainTime trainTimingForBoundStation:boundStation andDayGroup:self.trainTime.dayGroup];

        NSString *firstTrainTimeText = @"";
        NSString *lastTrainTimeText = @"";

        if([Settings sharedInstance].isTimeTwelveHour){
            firstTrainTimeText = [[TrainTime twelveHourTimeFormatter] stringFromDate:aTiming.firstTrain];
            lastTrainTimeText = [[TrainTime twelveHourTimeFormatter] stringFromDate:aTiming.lastTrain];

        }else{
            firstTrainTimeText =  [[TrainTime twentyFourHourTimeFormatter] stringFromDate:aTiming.firstTrain];
            lastTrainTimeText = [[TrainTime twentyFourHourTimeFormatter] stringFromDate:aTiming.lastTrain];
        }

        ((TrainTimeCollectionViewCell *)cell).dayLabel.text = ([self.trainTime.dayGroup isEqualToString:[TrainTime currentDayGroup]] ? [TrainTime today] : [TrainTime yesterday]);
        ((TrainTimeCollectionViewCell *)cell).firstTrainLabel.text = [@"First Train: " stringByAppendingString:firstTrainTimeText];
        ((TrainTimeCollectionViewCell *)cell).lastTrainLabel.text = [@"Last Train: " stringByAppendingString:lastTrainTimeText];

        NSString *minuteText = @"";
        NSString *minuteSuffixText = @"";

        NSArray *nextTrain = [self.trainTime nextTrainBoundStation:boundStation];

        if([[nextTrain firstObject] isKindOfClass:[NSString class]]) minuteText = [nextTrain firstObject];
        if([[nextTrain lastObject] isKindOfClass:[NSString class]]) minuteSuffixText = [nextTrain lastObject];

        ((TrainTimeCollectionViewCell *)cell).nextTrainLabel.text = minuteText;
        ((TrainTimeCollectionViewCell *)cell).nextTrainSuffixLabel.text = minuteSuffixText;
    }
}

#pragma mark - Collection View methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.trainTime.boundStations count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.trainTime.boundStations[section] count];
}


    //Cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.view.subviews containsObject:self.spinner]){
            //sometimes the spinner stays around
        [self.spinner removeFromSuperview];
    }

    MetroStation *boundStation = [self.trainTime boundStationAtIndexPath:indexPath];
    TrainTiming *todayTiming = [self.trainTime trainTimingForBoundStationAt:indexPath
                                                                andDayGroup:self.trainTime.dayGroup];

    TrainTimeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimingCell" forIndexPath:indexPath];

    cell.boundStationLabel.text = [boundStation.stationName uppercaseString];

    NSString *firstTrainTimeText = @"";
    NSString *lastTrainTimeText = @"";

    if([Settings sharedInstance].isTimeTwelveHour){
        firstTrainTimeText = [[TrainTime twelveHourTimeFormatter] stringFromDate:todayTiming.firstTrain];
        lastTrainTimeText = [[TrainTime twelveHourTimeFormatter] stringFromDate:todayTiming.lastTrain];

    }else{
        firstTrainTimeText =  [[TrainTime twentyFourHourTimeFormatter] stringFromDate:todayTiming.firstTrain];
        lastTrainTimeText = [[TrainTime twentyFourHourTimeFormatter] stringFromDate:todayTiming.lastTrain];
    }

    cell.dayLabel.text = ([self.trainTime.dayGroup isEqualToString:[TrainTime currentDayGroup]] ? [TrainTime today] : [TrainTime yesterday]);
    cell.firstTrainLabel.text =[@"First Train: " stringByAppendingString:firstTrainTimeText];
    cell.lastTrainLabel.text = [@"Last Train: " stringByAppendingString:lastTrainTimeText];

    [self updateNextTrainTimeForCell:cell indexPath:indexPath];
    [self updateCell:cell animated:NO];

    return  cell;
}

    //Header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{

    if([kind isKindOfClass:[UICollectionElementKindSectionHeader class]]){
        TrainTimeCellHeader *aView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:@"SectionHeader"
                                                                              forIndexPath:indexPath];
        MetroStation *aStation = (MetroStation *)[self.trainTime.boundStations[indexPath.section] lastObject];
        MetroStationLine *aStationLine = [aStation.stationLines anyObject];
        aView.sectionTitle.text = [[aStationLine.stationLineName uppercaseString] stringByAppendingString:@" Line"];
        return aView;
    }

    return nil;
}

- (void)updateCell:(UICollectionViewCell *)cell animated:(BOOL)animate
{
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end