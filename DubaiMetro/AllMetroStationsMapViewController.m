//
//  MetroStationsMapViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/9/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "AllMetroStationsMapViewController.h"
#import "MetroStationLine+CreateFetch.h"
#import "Settings.h"

@interface AllMetroStationsMapViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *aToolBar;

@end

#define MAP_HYBRID @"Hybrid"
#define MAP_STANDARD @"Standard"
#define MAP_SATELLITE @"Satellite"

@implementation AllMetroStationsMapViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.needUpdateRegion = YES;
    [self setupToolBar];

    self.mapView.mapType = [Settings sharedInstance].mapType;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
         if(self.needUpdateRegion) [self updateRegion];
}


- (void)reload
{
    if(self.managedObjectContext){

        self.needUpdateRegion = YES;

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStation"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; //All records.
        NSError *error = nil;

        NSArray *stations = [self.managedObjectContext executeFetchRequest:request error:&error];

        if(!stations || error){
#ifdef DM_DEBUG
            NSLog(@"Map View Error: %@", error);
#endif
        }else{
            [self.mapView removeAnnotations:self.mapView.annotations]; //remove current annotations
            [self.mapView addAnnotations:stations]; //MetroStation implements MKAnnotation in MetroStation+MKAnnotation category
        }

        for(MetroStationLine *stationLine in [MetroStationLine fetchAllMetroStationLinesinManagedObjectContext:self.managedObjectContext]){
            [self drawPolyline:[NSKeyedUnarchiver unarchiveObjectWithData:stationLine.polylinePath]
            forStationLineCode:stationLine.stationLineCode];
        }
    }
}

- (void)drawPolyline:(NSArray *)polylinePath forStationLineCode:(NSString *)stationLineCode
{
    NSUInteger polylineCount = [polylinePath count];
    CLLocationCoordinate2D theCoordinates[polylineCount];

    for(int i = 0; i < polylineCount; i++){
        theCoordinates[i] =CLLocationCoordinate2DMake([(NSNumber *)polylinePath[i][LINE_LATITUDE] doubleValue],
                                                      [(NSNumber *)polylinePath[i][LINE_LONGITUDE] doubleValue]);
    }

    MKPolyline *aPolyline = nil;

    if([stationLineCode isEqualToString:LINE_GREEN_CODE]){
     aPolyline  = [GreenPolyline polylineWithCoordinates:theCoordinates count:polylineCount];
    }else if([stationLineCode isEqualToString:LINE_RED_CODE]){
        aPolyline  = [RedPolyline polylineWithCoordinates:theCoordinates count:polylineCount];
    }

    [self.mapView addOverlay:aPolyline];
}

- (void)setupToolBar
{
    MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];

    [DMHelper maskButton:trackingButton];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                target:self action:@selector(configureMap)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil action:nil];
    self.aToolBar.items = @[trackingButton,flexibleSpace, buttonItem];
    self.aToolBar.translucent = NO;
    [self.aToolBar setBackgroundImage:[UIImage imageNamed:@"bg.jpg"] forToolbarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
}

- (void)configureMap
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:MAP_STANDARD, MAP_HYBRID, MAP_SATELLITE, nil];
    if([DMHelper sharedInstance].isOS7AndAbove){
        sheet.tintColor = BACKGROUND_COLOR;
    }
    
    [sheet showInView:self.aToolBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:MAP_STANDARD]){
        self.mapView.mapType = MKMapTypeStandard;
    }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:MAP_HYBRID]){
        self.mapView.mapType = MKMapTypeHybrid;
    }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:MAP_SATELLITE]){
        self.mapView.mapType = MKMapTypeSatellite;
    }

    [Settings sharedInstance].mapType = self.mapView.mapType;
    [[Settings sharedInstance] synchronize];
}

- (void)updateRegion
{

    self.needUpdateRegion = NO;
    CGRect boundingRect;
    BOOL started = NO;

    for(id<MKAnnotation> annotation in self.mapView.annotations){

        CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);

        if(!started){
            started = YES;
            boundingRect = annotationRect;
        }else{
            boundingRect = CGRectUnion(boundingRect, annotationRect);
        }
    }

    if(started){
        boundingRect = CGRectInset(boundingRect, -0.04, -0.04);

        if((boundingRect.size.width < 20) && (boundingRect.size.height < 20)){
            MKCoordinateRegion region;

            region.center.latitude = boundingRect.origin.x + boundingRect.size.width / 2;
            region.center.longitude = boundingRect.origin.y + boundingRect.size.height / 2;
            region.span.latitudeDelta = boundingRect.size.width;
            region.span.longitudeDelta = boundingRect.size.height;

            [self.mapView setRegion:region animated:YES];
        }
    }

}


@end