//
//  MetroStationTableViewCell.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/12/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationTableViewCell.h"

@interface MetroStationTableViewCell()
@property (nonatomic, strong) UIView *defaultBackgroundView;
@end

@implementation MetroStationTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.stationNameLabel.font = [DMHelper dmFontWithSize:self.stationNameLabel.font.pointSize];
    self.stationLineLabel.font = [DMHelper dmFontWithSize:self.stationLineLabel.font.pointSize];
    self.stationZoneLabel.font = [DMHelper dmFontWithSize:self.stationZoneLabel.font.pointSize];
    self.stationOperationLabel.font = [DMHelper dmFontWithSize:self.stationOperationLabel.font.pointSize];
    self.proximityTopLabel.font = [DMHelper dmFontWithSize:self.proximityTopLabel.font.pointSize];
    self.proximityBottomLabel.font = [DMHelper dmFontWithSize:self.proximityBottomLabel.font.pointSize];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];

    if(!userInteractionEnabled){
        UIView *bg = [[UIView alloc] initWithFrame:self.frame];
        bg.backgroundColor = [UIColor colorWithRed:230.0/255.0
                                             green:230.0/255.0
                                              blue:230.0/255.0 alpha:0.8];
        if(!self.defaultBackgroundView)
            self.defaultBackgroundView = self.backgroundView; //keep it around

        self.backgroundView = bg;
    }else{
        self.backgroundView = self.defaultBackgroundView;
    }
}

@end