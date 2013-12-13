//
//  TrainTimingCollectionViewCell.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/25/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainTimeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *boundStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextTrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextTrainSuffixLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstTrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@end