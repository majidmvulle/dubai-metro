//
//  DefaultNavigationController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/7/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMNavigationController.h"
#import "PKRevealController.h"
#import "MenuViewController.h"
@interface DefaultNavigationController : DMNavigationController
@property (nonatomic, strong) PKRevealController *revealController;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, getter = isFirstTimeSetupComplete) BOOL firstTimeSetupComplete;
- (void)showMenu;
@end