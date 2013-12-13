//
//  JourneyRoutesFooter.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/30/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JourneyRoutesFooter : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIButton *chooseRouteButton;
@property (strong, nonatomic) NSIndexPath *indexPath;
@end
