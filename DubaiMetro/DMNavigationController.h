//
//  NavigationController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKRevealController.h"
#import "MenuTVC.h"

@interface DMNavigationController : UINavigationController
@property (nonatomic, strong) PKRevealController *revealController;
@property (nonatomic, strong) MenuTVC *menuTVC;
@end
