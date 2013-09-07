//
//  DubaiMetroViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 8/27/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMViewController.h"
#import "MapViewController.h"
#import "DMNavigationController.h"

@interface DMViewController ()

@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setupGoogleMaps];
}

- (void)setupGoogleMaps
{
    MapViewController *mapvc = [[MapViewController alloc] init];

    mapvc.mapViewFrame = self.customMapView.bounds;

    [self.customMapView addSubview:mapvc.view];
}

- (IBAction)showMenu:(UIBarButtonItem *)sender
{

    if([self.navigationController isKindOfClass:[DMNavigationController class]]){
        DMNavigationController *dmNavigationController = (DMNavigationController *)self.navigationController;

            //show if not visible
        if(!dmNavigationController.menuTVC.view.window)
            [dmNavigationController.revealController showViewController:dmNavigationController.menuTVC];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
