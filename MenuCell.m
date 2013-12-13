//
//  MenuCell.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell()
@property (nonatomic, strong) NSString *selectedStateImageName;
@property (nonatomic, strong) NSString *nonSelectedStateImageName;
@end
@implementation MenuCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.textLabel.font = [DMHelper dmFontWithSize:self.textLabel.font.pointSize];
}

- (NSString *)selectedStateImageName
{
    if(!_selectedStateImageName){
        NSString *reuseId = self.reuseIdentifier;

        if(reuseId){
            _selectedStateImageName = [[@"menu-" stringByAppendingString:reuseId] stringByAppendingString:@"-white.png"];
        }
    }
    
    return _selectedStateImageName;
}

- (NSString *)nonSelectedStateImageName
{
    if(!_nonSelectedStateImageName){
        NSString *reuseId = self.reuseIdentifier;
        if(reuseId){
            _nonSelectedStateImageName = [[@"menu-" stringByAppendingString:reuseId] stringByAppendingString:@"-gray.png"];
        }
    }

    return _nonSelectedStateImageName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if(selected) {
        self.backgroundColor = MENU_TABLE_CELL_SELECTED_COLOR;
        self.textLabel.textColor = [UIColor whiteColor];
        self.imageView.image = [UIImage imageNamed:self.selectedStateImageName];
    } else {
        self.backgroundColor = MENU_TABLE_CELL_COLOR;
        self.textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        self.imageView.image = [UIImage imageNamed:self.nonSelectedStateImageName];
    }
}

@end