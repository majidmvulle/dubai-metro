//
//  TrainTimingCollectionViewCell.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/25/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainTimeCollectionViewCell.h"

@implementation TrainTimeCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.boundStationLabel.font = [DMHelper dmFontWithSize:self.boundStationLabel.font.pointSize];
    self.nextTrainLabel.font = [DMHelper dmFontWithSize:self.nextTrainLabel.font.pointSize];
    self.nextTrainSuffixLabel.font = [DMHelper dmFontWithSize:self.nextTrainSuffixLabel.font.pointSize];
    self.firstTrainLabel.font = [DMHelper dmFontWithSize:self.firstTrainLabel.font.pointSize];
    self.lastTrainLabel.font = [DMHelper dmFontWithSize:self.lastTrainLabel.font.pointSize];
    self.dayLabel.font = [DMHelper dmFontWithSize:self.dayLabel.font.pointSize];


}

@end