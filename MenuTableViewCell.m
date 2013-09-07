//
//  MenuTableViewCell.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/4/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state

    if(selected) {
        self.backgroundColor = MENU_TABLE_CELL_SELECTED_COLOR;
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = MENU_TABLE_CELL_COLOR;
        self.textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    }
}

@end
