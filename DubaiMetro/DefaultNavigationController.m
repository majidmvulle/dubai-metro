//
//  DefaultNavigationController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/7/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DefaultNavigationController.h"
#import "DMBarButtonItem.h"
#import "IntroViewController.h"
#import "DMViewController.h"
#import "LoadingViewController.h"

@interface DefaultNavigationController()
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@end

@implementation DefaultNavigationController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
    [self setupPKRevealController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[[UIApplication sharedApplication] delegate] window].rootViewController = self.revealController;

    if([Settings sharedInstance].isFirstLaunch){
        [Settings sharedInstance].firstLaunch = NO;
        [[Settings sharedInstance] synchronize];

        [self showLoading];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];

    if([viewControllers count]){
        UIViewController *rootViewController = [viewControllers firstObject];
        [self addMenuButton:rootViewController];

        if([rootViewController isKindOfClass:[DMViewController class]]){
            [self addHelpButton:rootViewController];
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];

    if([viewControllers count]){
        UIViewController *rootViewController = [viewControllers firstObject];
        [self addMenuButton:rootViewController];

        if([rootViewController isKindOfClass:[DMViewController class]]){
            [self addHelpButton:rootViewController];
        }
    }
}

- (void)setFirstTimeSetupComplete:(BOOL)firstTimeSetupComplete
{
    _firstTimeSetupComplete = firstTimeSetupComplete;

    if(_firstTimeSetupComplete){
        if([self.viewControllers containsObject:self.loadingViewController]){
            [self.loadingViewController.view removeFromSuperview];
            [self.loadingViewController removeFromParentViewController];
            [self showWalkThrough:NO];
        }
    }
}

- (void)addMenuButton:(UIViewController *)rootViewController
{
    DMBarButtonItem *barButtonItem = [[DMBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(showMenu)];
    [barButtonItem setup];

    rootViewController.navigationItem.leftBarButtonItem = nil; //remove it (JourneyRoutes issue)
    rootViewController.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)addHelpButton:(UIViewController *)rootViewController
{
    DMBarButtonItem *barButtonItem = [[DMBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-help.png"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(showWalkThroughAnimating)];
    [barButtonItem setup];

    rootViewController.navigationItem.rightBarButtonItem = barButtonItem;
}


- (void)showMenu
{
    [self.revealController showViewController:self.menuViewController];
}

- (void)showLoading
{
    LoadingViewController *loadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    [self addChildViewController:loadingVC];
    [self.view addSubview:loadingVC.view];
    [self makeViewEqual:loadingVC.view];
    [loadingVC didMoveToParentViewController:self];

    self.loadingViewController = loadingVC;

}

- (void)showWalkThroughAnimating
{
    [self showWalkThrough:YES];

}
- (void)showWalkThrough:(BOOL)animate
{

    IntroViewController *introVC = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];

    [self addChildViewController: introVC];

    if(animate)
        introVC.view.alpha = 0.0;

    [self.view addSubview:introVC.view];
    [self makeViewEqual:introVC.view];

    [introVC didMoveToParentViewController:self];

    if(animate){
    [UIView animateWithDuration:0.3
                     animations:^{introVC.view.alpha = 1.0;}
                     completion:nil];
    }
    
}

- (void)makeViewEqual:(UIView *)view
{
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX
                                                            relatedBy:0
                                                               toItem:view
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1 constant:0];
    NSLayoutConstraint *con2 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY
                                                            relatedBy:0
                                                               toItem:view
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1 constant:0];
    NSLayoutConstraint *con3 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth
                                                            relatedBy:0
                                                               toItem:view
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1 constant:0];
    NSLayoutConstraint *con4 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight
                                                            relatedBy:0
                                                               toItem:view
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1 constant:0];

    [self.view addConstraints:@[con1,con2,con3,con4]];
}

- (MenuViewController *)menuViewController
{
    if(!_menuViewController){
        _menuViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MenuViewController"];
    }

    return _menuViewController;
}

- (void)setup
{
    if([self.viewControllers count]){
        UIViewController *rootViewController = [self.viewControllers firstObject];
        [self addMenuButton:rootViewController];
        [self addHelpButton:rootViewController];
    }
}

- (void)setupPKRevealController
{
        // PKRevealController.h contains a list of all the specifiable options
    NSDictionary *options = @{
                              PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
                              PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
                              };

    self.revealController = [PKRevealController revealControllerWithFrontViewController:self
                                                                     leftViewController:self.menuViewController
                                                                                options:options];

}

@end
