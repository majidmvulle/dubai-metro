//
//  IntroViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "IntroViewController.h"

#define MAX_INTRO_SCREENS 4

@interface IntroViewController ()<UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *aView;
@property (weak, nonatomic) IBOutlet UIButton *letsgoButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@end

@implementation IntroViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
  /*
    if([DMHelper sharedInstance].isOS7AndAbove){
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeAll;
    }
   */
    self.aView.backgroundColor = [UIColor clearColor];

    self.letsgoButton.titleLabel.font = [DMHelper dmFontWithSize:self.letsgoButton.titleLabel.font.pointSize];
    self.skipButton.titleLabel.font = [DMHelper dmFontWithSize:self.skipButton.titleLabel.font.pointSize];

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[self.aView bounds]];

    IntroChildViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO completion:nil];

    [self addChildViewController:self.pageController];
    [self.aView addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [DMHelper trackScreenWithName:@"Walkthrough"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewController Delegate Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{

    NSUInteger index = [(IntroChildViewController *)viewController index];

    if (index == 0) {
        return nil;
    }

    index--;

    return [self viewControllerAtIndex:index];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{

    NSUInteger index = [(IntroChildViewController *)viewController index];

    index++;

    if (index == MAX_INTRO_SCREENS) {
        return nil;
    }

    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
        // The number of items reflected in the page indicator.
    return MAX_INTRO_SCREENS;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
        // The selected item reflected in the page indicator.
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{

    if(completed){

        id currentViewController = [pageViewController.viewControllers lastObject];

        self.letsgoButton.hidden = YES;

        if(self.skipButton.hidden){
            self.skipButton.alpha = 0.0;
            self.skipButton.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{self.skipButton.alpha = 1.0;}
                             completion:nil];
        }

        if([currentViewController isKindOfClass:[IntroChildViewController class]]){

            if(((IntroChildViewController *)currentViewController).index == (MAX_INTRO_SCREENS - 1)){

                self.skipButton.hidden = YES;

                self.letsgoButton.alpha = 0.0;
                self.letsgoButton.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{self.letsgoButton.alpha = 1.0;}
                                 completion:nil];
                
            }
        }
    }
}


- (IntroChildViewController *)viewControllerAtIndex:(NSUInteger)index{

    IntroChildViewController *childViewController = [[IntroChildViewController alloc] initWithNibName:@"IntroChildViewController"
                                                                                               bundle:nil];
    childViewController.index = index;

    return childViewController;
}

- (IBAction)skipButtonTapped:(UIButton *)sender
{
    [self removeMe];
}

- (IBAction)letsgoButtonTapped:(UIButton *)sender
{
    [self removeMe];
}

- (void)removeMe
{
    [UIView animateWithDuration:0.3
                     animations:^{self.view.alpha = 0.0;}
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];

    [self removeFromParentViewController];
}

@end
