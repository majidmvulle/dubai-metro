//
//  JourneyRoutesCollectionVC.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/28/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "JourneyRoutesViewController.h"
#import "JourneyRoutesCollectionViewCell.h"
#import "MetroStation.h"
#import "Journey.h"
#import "JourneyRoutesHeader.h"
#import "JourneyRoutesFooter.h"
//#import "TrainTime.h"
#import "TrainTiming+Create.h"
#import "TrainBound+Create.h"
#import "TicketPrice+CreateFetch.h"
#define CELL_WIDTH 285.0f

@interface JourneyRoutesViewController () <UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *journeyRoutesCollectionView;
@property (nonatomic, strong) NSArray *journeyRoutes;
@property (nonatomic, strong) Journey *journey;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *calculatingRouteLabel;
@property (nonatomic, strong) NSTimer *aTimer;
@end

@implementation JourneyRoutesViewController

@synthesize journeyRoutes = _journeyRoutes;

- (IBAction)chooseRouteButtonTapped:(UIButton *)sender
{

    if([sender.superview isKindOfClass:[JourneyRoutesFooter class]]){
//        NSIndexPath *indexPath = ((JourneyRoutesFooter *)sender.superview).indexPath;
//        JourneyRoute *selectedRoute = [self journeyRouteAtIndexPath:indexPath];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.calculatingRouteLabel.font = [DMHelper dmFontWithSize:self.calculatingRouteLabel.font.pointSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.journeyRoutesCollectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.spinner startAnimating];

    self.aTimer = [NSTimer timerWithTimeInterval:TRAIN_TIME_UPDATE_INTERVAL
                                          target:self selector:@selector(updateAllTimings) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.aTimer forMode:NSDefaultRunLoopMode];

    [DMHelper trackScreenWithName:[NSString stringWithFormat:@"Journey Route:(%@ -> %@)",self.fromStation.stationName,
                                   self.toStation.stationName]];
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

- (NSArray *)journeyRoutes
{
    if(!_journeyRoutes) _journeyRoutes = [[NSArray alloc] init];

    return _journeyRoutes;
}

- (void)setJourneyRoutes:(NSArray *)journeyRoutes
{
    _journeyRoutes = journeyRoutes;

    [self.spinner stopAnimating];
    [self.calculatingRouteLabel removeFromSuperview];

    [self.journeyRoutesCollectionView reloadData];
    [self.journeyRoutesCollectionView.collectionViewLayout invalidateLayout];
//    [self.journeyRoutesCollectionView invalidateIntrinsicContentSize];
}


- (void)setFromStation:(MetroStation *)fromStation
{
    _fromStation = fromStation;

    if(_toStation) [self setup];
}

- (void)setToStation:(MetroStation *)toStation
{
    _toStation = toStation;

    if(_fromStation) [self setup];
}

- (void)setup
{
    if(self.fromStation && self.toStation){
        dispatch_queue_t aQueue = dispatch_queue_create("Find Journey Routes", NULL);

        dispatch_async(aQueue, ^{
                Journey *journey = [[Journey alloc] initFromStation:self.fromStation
                                                          toStation:self.toStation];
                self.journey = journey;

                NSArray *journeyRoutes = [journey findJourneyRoutes];

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.journeyRoutes = journeyRoutes;
                });

        });
    }
}

#pragma mark - Collection View methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.journeyRoutes count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [self.journeyRoutes[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        //TODO: Continue here
        //Determine Cell size by looking at the data
        //count the number of vetical labels you will require
        //use collectionView:layout:sizeForItemAtIndexPath to set the cell size to accommodate the data

    if([self.view.subviews containsObject:self.spinner]){
            //sometimes the spinner stays around
        [self.spinner removeFromSuperview];
    }

    JourneyRoutesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RouteCell" forIndexPath:indexPath];

    JourneyRoute *journeyRoute = [self journeyRouteAtIndexPath:indexPath];

    cell.fromStationLabel.attributedText = [self applyLabelAtrributesForTitle:journeyRoute.fromStation.stationName subtitle:nil fontSize:14.0 strokeWidth:-4.0];
    cell.fromTowardsLabel.attributedText = [self applyLabelAtrributesForTitle:[@"towards " stringByAppendingString:journeyRoute.towardsStation.stationName]
                                                                     subtitle:nil fontSize:14.0 strokeWidth:0];

    cell.toStationLabel.attributedText = [self applyLabelAtrributesForTitle:journeyRoute.toStation.stationName subtitle:nil fontSize:14.0 strokeWidth:-4.0];

    cell.priceLabel.text = [NSString stringWithFormat:@"AED %.02f", self.journey.ticketPrice];

    NSString *zoneString = ((journeyRoute.fromStation.stationZone == journeyRoute.toStation.stationZone) ?
                            [NSString stringWithFormat:@"%d", [journeyRoute.fromStation.stationZone intValue]] :
                            [NSString stringWithFormat:@"%d TO %d", [journeyRoute.fromStation.stationZone intValue], [journeyRoute.toStation.stationZone intValue]]);

    cell.zoneLabel.attributedText = [self applyLabelAtrributesForTitle:zoneString subtitle:nil fontSize:14.0 strokeWidth:-4.0];


    [self addInterchanges:cell journeyRoute:journeyRoute];
    [self updateNextTrainTimeForCell:cell indexPath:indexPath];
    [self updateCell:cell animated:NO];

    return  cell;
}

- (void)addInterchanges:(JourneyRoutesCollectionViewCell *)cell journeyRoute:(JourneyRoute *)journeyRoute
{
    NSMutableArray *addedViews = [NSMutableArray array];

    for(JourneyInterchange *journeyInterchange in journeyRoute.interchanges){

            //Do interchange Label
        UILabel *interchangeLabel = [[UILabel alloc] init];
        interchangeLabel.attributedText = [self applyLabelAtrributesForTitle:@"Interchange" subtitle:nil fontSize:14.0 strokeWidth:0];
        interchangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        interchangeLabel.backgroundColor = [UIColor clearColor];
        [interchangeLabel sizeToFit];
        [cell addSubview:interchangeLabel];

        UIView *previousLabel = [addedViews count] ? [addedViews lastObject] : cell.fromTowardsLabel;

            //Leading
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:interchangeLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previousLabel
                                                         attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];

            //Vertical
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousLabel]-[interchangeLabel]"
                                                                     options:0 metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(previousLabel, interchangeLabel)]];


        //Do interchange Description Label
        UILabel *interchangeDescriptionLabel = [[UILabel alloc] init];
        interchangeDescriptionLabel.attributedText = [self applyLabelAtrributesForTitle:journeyInterchange.interchangeStation.stationName
                                                                               subtitle:[@"towards " stringByAppendingString:journeyInterchange.towardsStation.stationName]
                                                                               fontSize:14.0 strokeWidth:-4.0];

        interchangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        interchangeDescriptionLabel.backgroundColor = [UIColor clearColor];
        interchangeDescriptionLabel.numberOfLines = 2;
        interchangeDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;

        [cell addSubview:interchangeDescriptionLabel];

            //Leading
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:interchangeDescriptionLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:interchangeLabel
                                                         attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];

            //Vertical
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[interchangeLabel]-[interchangeDescriptionLabel]"
                                                                     options:0 metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(interchangeLabel, interchangeDescriptionLabel)]];

            //Width
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:interchangeDescriptionLabel
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:cell.toStationLabel
                                                         attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];


        [addedViews addObject:interchangeLabel];
        [addedViews addObject:interchangeDescriptionLabel];
    }

}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
        //interchange label height = 14.0
        //separation height = 8.0
        //interchange description:
            //height = 28.0
            //width = 158.0

        //58.0: will explain later
    CGFloat multiplier = 68.0f;

    CGFloat cellHeight =  200.0f;
    if([[DMHelper sharedInstance] isOS7AndAbove]){
        cellHeight = 180.0f;
        multiplier = 58.0f;
    }

    int numberOfInterchanges = [((JourneyRoute *)[self journeyRouteAtIndexPath:indexPath]).interchanges count];

    CGFloat height = cellHeight + (numberOfInterchanges * multiplier);

    CGSize theSize = CGSizeMake(CELL_WIDTH, height);

    return theSize;
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *aReusableView = nil;

        //Route number - Header
        //Start Journey button - Footer
    if([self.journeyRoutes count]){
        JourneyRoute *journeyRoute = [self journeyRouteAtIndexPath:indexPath];

        if([kind isEqualToString:UICollectionElementKindSectionHeader]){

            JourneyRoutesHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"RouteHeader"
                                                                                   forIndexPath:indexPath];
            NSString *stops = ((journeyRoute.numberOfStationsToTravel == 1) ? @"Stop" : @"Stops");
            NSString *interchanges = (([journeyRoute.interchanges count] == 1) ? @"Interchange" : @"Interchanges");

            headerView.routeSummaryLabel.attributedText = [self applyLabelAtrributesForTitle:[NSString stringWithFormat:@"Route %d", (indexPath.section + 1)]
                                                                               subtitle:[NSString stringWithFormat:@"%d %@ %d %@",
                                                                                         journeyRoute.numberOfStationsToTravel, stops,
                                                                                         [journeyRoute.interchanges count], interchanges]
                                                                               fontSize:15.0 strokeWidth:-4.0f];

            aReusableView = headerView;

        }else if([kind isEqualToString:UICollectionElementKindSectionFooter]){
           /* JourneyRoutesFooter *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"RouteFooter"
                                                                                   forIndexPath:indexPath];
            footerView.indexPath = indexPath;
            aReusableView = footerView; */
            aReusableView = nil;
        }
    }
    
    return aReusableView;
}

- (JourneyRoute *)journeyRouteAtIndexPath:(NSIndexPath *)indexPath
{
    return self.journeyRoutes[indexPath.section][indexPath.item];
}

- (NSMutableAttributedString *)applyLabelAtrributesForTitle:(NSString *)mainTitle
                                                   subtitle:(NSString *)subTitle
                                                   fontSize:(float)fontSize
                                                strokeWidth:(float)strokeWidth
{
    NSMutableAttributedString *attributedString = nil;
    if(subTitle){
        attributedString = [[NSMutableAttributedString alloc] initWithString:[[mainTitle stringByAppendingString:@"\n"]
                                                                              stringByAppendingString:subTitle]];

    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:mainTitle];
    }

    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    NSRange mainTitleRange = NSMakeRange(0, mainTitle.length);

    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_COURIER size:fontSize] range:attributedStringRange];

    if(strokeWidth != 0)
    [attributedString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:strokeWidth] range:mainTitleRange];

    [attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:1.0] range:attributedStringRange];
    return attributedString;
}


- (void)updateAllTimings
{
    for (id cell in [self.journeyRoutesCollectionView visibleCells]){
        [self updateNextTrainTimeForCell:cell indexPath:[self.journeyRoutesCollectionView indexPathForCell:cell]];
    }
}

- (void)updateNextTrainTimeForCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[JourneyRoutesCollectionViewCell class]]){
        JourneyRoute *journeyRoute = (JourneyRoute *)[self journeyRouteAtIndexPath:indexPath];

        MetroStation *boundStation = journeyRoute.towardsStation;

        NSString *minuteText = @"";
        NSString *minuteSuffixText = @"";

        NSArray *nextTrain = [journeyRoute.trainTime nextTrainBoundStation:boundStation];

        if([[nextTrain firstObject] isKindOfClass:[NSString class]]) minuteText = [nextTrain firstObject];
        if([[nextTrain lastObject] isKindOfClass:[NSString class]]) minuteSuffixText = [nextTrain lastObject];


        NSMutableAttributedString *nextTrainAttributedString = [self applyLabelAtrributesForTitle:minuteText
                                                                                         subtitle:minuteSuffixText
                                                                                         fontSize:14.0 strokeWidth:-4.0f];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;

        [nextTrainAttributedString addAttribute:NSParagraphStyleAttributeName
                                          value:paragraphStyle
                                          range:NSMakeRange(0, nextTrainAttributedString.length)];

        ((JourneyRoutesCollectionViewCell *)cell).nextTrainMinutesLabel.attributedText = nextTrainAttributedString;
    }
}

- (void)updateCell:(UICollectionViewCell *)cell animated:(BOOL)animate
{
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end