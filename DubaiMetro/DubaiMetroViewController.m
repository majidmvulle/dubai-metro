//
//  DubaiMetroViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 8/27/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DubaiMetroViewController.h"
#import "MapViewController.h"

@interface DubaiMetroViewController ()

@end

@implementation DubaiMetroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"menu-icon.png"];


    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    UIImage *img = [[UIImage alloc] init];
    UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];

    [self.navigationItem.leftBarButtonItem setBackgroundImage:maskedImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];


    MapViewController *mapvc = [[MapViewController alloc] init];

    mapvc.mapViewFrame = self.customMapView.bounds;

    [self.customMapView addSubview:mapvc.view];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
