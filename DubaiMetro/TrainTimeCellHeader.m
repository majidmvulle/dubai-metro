//
//  HeaderReusableView.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/25/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "TrainTimeCellHeader.h"

@implementation TrainTimeCellHeader
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.sectionTitle.font = [DMHelper dmFontWithSize:self.sectionTitle.font.pointSize];
}
@end