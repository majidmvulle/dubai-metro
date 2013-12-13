//
//  MenuViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKRevealController.h"

@interface MenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) PKRevealController *revealController;
@property (nonatomic, weak) UITableViewController *embeddedTableViewController;
@end