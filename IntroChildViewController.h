//
//  IntroChildViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroChildViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *featureTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *featureImageView;
@property (nonatomic, assign) NSUInteger index;
@end
