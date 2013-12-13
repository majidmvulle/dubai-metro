//
//  MenuCell.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell
@property (nonatomic, getter = isCurrentlyActive) BOOL currentlyActive;
@end