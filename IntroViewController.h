//
//  IntroViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroChildViewController.h"

@interface IntroViewController : UIViewController<UIPageViewControllerDataSource>
@property (nonatomic, strong) UIPageViewController *pageController;
@end
