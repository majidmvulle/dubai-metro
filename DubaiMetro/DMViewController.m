//
//  DMViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/14/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import "DMViewController.h"
#import "MetroStation+CreateFetch.h"

@interface DMViewController ()
@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldUpdateProximity = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateMetroStationProximities];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];


    if(![self.metroStationsMapvc.mapView.annotations count])
        [self reloadMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateMetroStationProximities{} //abstract

- (void)reloadMap
{
    if(self.view.window){
        [self.metroStationsMapvc reload];
    }
}

#pragma mark Core Data stuff


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{}


#pragma mark Setup methods

- (void)setMetroStationsMapvc:(AllMetroStationsMapViewController *)metroStationsMapvc
{
    _metroStationsMapvc = metroStationsMapvc;

    [self reloadMap];
}

@end
