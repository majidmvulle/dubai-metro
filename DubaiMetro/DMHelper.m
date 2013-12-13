//
//  DMHelper.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/16/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//
//  Metric            -> Imperial

//  1 metre (m.)      -> 1.09361 yard (yd.)
//  kilometre (km.)   -> 0.621371 mile (mi.)

#import <sys/utsname.h>
#import "DMHelper.h"
#import "DMBarButtonItem.h"
#import "Settings.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface DMHelper()
@property (nonatomic, readwrite) BOOL isOS7AndAbove;
@end

@implementation DMHelper

#define METRE_IN_YARDS 1.09361
#define YARD_IN_MILES 0.000568182
#define METRE_IN_KILOMETRES 0.001

+ (DMHelper *)sharedInstance
{
    static dispatch_once_t dmHelperDispatcher = 0;
    __strong static DMHelper *_sharedInstance = nil;

    dispatch_once(&dmHelperDispatcher, ^{
        _sharedInstance = [[self alloc] init];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
            _sharedInstance.isOS7AndAbove = YES;
        }

    });

    return _sharedInstance;
}

- (NSString *)formatDistance:(NSNumber *)distance withSuffix:(DistanceSuffix)distanceSuffix
{
    NSString *distanceWithSuffix = @"";
    
    float distanceInMetres = [distance floatValue];

    if([Settings sharedInstance].isMeasurementImperial){

        float distanceInYards = distanceInMetres * METRE_IN_YARDS;

        float distanceInMiles = distanceInYards * YARD_IN_MILES;

        if(distanceInMiles < 1.0){
            if(distanceSuffix.isShortSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%ld yd.", lroundf(distanceInYards)];
            else if (distanceSuffix.isLongSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%ld yards", lroundf(distanceInYards)];
        }else{

            if(distanceSuffix.isShortSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%.1f mi.", distanceInMiles];
            else if (distanceSuffix.isLongSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%.1f miles", distanceInMiles];
        }

    }else{

        float distanceInKilometres = distanceInMetres * METRE_IN_KILOMETRES;

        if(distanceInKilometres < 1.0){
            if(distanceSuffix.isShortSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%ld m.", lroundf(distanceInMetres)];
            else if (distanceSuffix.isLongSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%ld metres", lroundf(distanceInMetres)];
        }else{
            if(distanceSuffix.isShortSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%.1f km.", distanceInKilometres];
            else if (distanceSuffix.isLongSuffix)
                distanceWithSuffix = [NSString stringWithFormat:@"%.1f kilometres", distanceInKilometres];
        }
    }

    return distanceWithSuffix;
}

+ (UIFont *)dmFontWithSize:(CGFloat)fontSize
{
    if(fontSize == 0.0) fontSize = [UIFont systemFontSize];

    UIFont *font = [UIFont fontWithName:DM_FONT_NAME size:fontSize];

    if(!font) font = [UIFont systemFontOfSize:fontSize];

    return font;
}

+ (UIFont *)dmNavigationTitleFont
{
    UIFont *font = [UIFont fontWithName:DM_NAVIGATION_TITLE_FONT_NAME size:0.0];

    if(!font) font = [UIFont systemFontOfSize:0.0];

    return font;
}

+ (void)maskButton:(id)button
{
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors([[UIImage alloc] init].CGImage, colorMask);
    UIImage *image = [UIImage imageWithCGImage: imageRef];

    if([button respondsToSelector:@selector(setBackgroundImage:forState:barMetrics:)]){
        [button setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [button setBackgroundImage:image forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    }

    CGImageRelease(imageRef);
}

+ (void)navigationControllerSetup:(UINavigationController *)navigationController
{

    navigationController.navigationBar.translucent = NO; //iOS 7 sets it to YES by default
    const float colorMask[6] = {23, 255, 30, 255, 49, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors([[UIImage alloc] init].CGImage, colorMask);
    UIImage *maskedImage = [UIImage imageWithCGImage: imageRef];

    if([DMHelper sharedInstance].isOS7AndAbove){
        navigationController.navigationBar.barTintColor = [UIColor colorWithRed:23/255.0 green:30/255.0 blue:49/255.0 alpha:1.0];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:23/255.0 green:30/255.0 blue:49/255.0 alpha:1.0];
        navigationController.navigationBar.tintColor =[UIColor colorWithRed:23/255.0 green:30/255.0 blue:49/255.0 alpha:1.0];
    }

    [navigationController.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];

    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[self dmNavigationTitleFont], UITextAttributeFont,[UIColor whiteColor], UITextAttributeTextColor, nil]];

    if([navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)]){
            //remove shadow
        [navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }

    for(id item in navigationController.navigationBar.items){
        if([item isKindOfClass:[UINavigationItem class]]){
            UINavigationItem *aNavigationItem = (UINavigationItem *)item;

            NSArray *theBarButtonItems = [NSArray arrayWithObjects:aNavigationItem.leftBarButtonItems,
                                          aNavigationItem.rightBarButtonItems, nil];

            for(id aBarButtonItems in theBarButtonItems){
                if([aBarButtonItems isKindOfClass:[NSArray class]]){
                    [aBarButtonItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                        if([obj isKindOfClass:[DMBarButtonItem class]]){
                            [(DMBarButtonItem *)obj setup];
                        }
                    }];
                }
            }
        }
    }

    CGImageRelease(imageRef);
}

+ (BOOL)isAtStation:(float)proximity
{
    if(proximity >= 0 && proximity <= AT_STATION_RADIUS) return YES;

    return NO;
}

+ (BOOL)isRetinaScreen
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
            // Retina
        return YES;
    }

    return NO;
}

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


#pragma mark - Angle calculations

+ (CGFloat)angleBetweenLocation:(CLLocation *)firstLocation andLocation:(CLLocation *)secondLocation
{
    double dblLat1, dblLat2, dblLon1, dblLon2, fltLat, fltLon;

    dblLat1 = [self degreesToRadians:firstLocation.coordinate.latitude];
    dblLon1 = [self degreesToRadians:firstLocation.coordinate.longitude];

    dblLat2 = [self degreesToRadians:secondLocation.coordinate.latitude];
    dblLon2 = [self degreesToRadians:secondLocation.coordinate.longitude];

    fltLat = dblLat2 - dblLat1;
    fltLon = dblLon2 - dblLon1;

    return atan2(fltLon, fltLat) * 180 /M_PI;
}

+ (CGFloat)degreesToRadians:(CGFloat)degrees
{
    return degrees * M_PI / 180;
}

+ (CGFloat)radiansToDegrees:(CGFloat)radians
{
    return radians * 180 / M_PI;
}

#pragma mark - Google Analytics

+ (void)trackScreenWithName:(NSString *)screenName
{
        // May return nil if a tracker has not already been initialized with a
        // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];

        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:screenName];

    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end