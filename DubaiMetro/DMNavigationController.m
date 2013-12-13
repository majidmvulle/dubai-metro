//
//  NavigationController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMNavigationController.h"
#import "DMBarButtonItem.h"


@interface DMNavigationController ()
@property (nonatomic, readwrite) CGFloat navHeight;
@end

@implementation DMNavigationController

#pragma mark - UIViewController methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    [DMHelper navigationControllerSetup:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navHeight = self.navigationBar.frame.size.height;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];

    UIImage *backImage = nil;

    if([DMHelper sharedInstance].isOS7AndAbove){
        backImage = [[UIImage imageNamed:@"btn-back.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    }else{
        backImage = [UIImage imageNamed:@"btn-back.png"];
    }

    DMBarButtonItem *backButtonItem = [[DMBarButtonItem alloc] initWithImage:backImage
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self action:@selector(dismiss)];

    [backButtonItem setup];
    viewController.navigationItem.leftBarButtonItem = backButtonItem;

}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
}

- (void)dismiss
{
    [self popViewControllerAnimated:YES];
}

@end