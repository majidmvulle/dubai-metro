//
//  DMHelper.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/16/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef struct {BOOL isShortSuffix; BOOL isLongSuffix;} DistanceSuffix;

@interface DMHelper : NSObject
@property (nonatomic, readonly) BOOL isLocaleImperial;
@property (nonatomic, readonly) BOOL isOS7AndAbove;
+ (DMHelper *)sharedInstance;
- (NSString *)formatDistance:(NSNumber *)distance withSuffix:(DistanceSuffix)distanceSuffix;
+ (UIFont *)dmFontWithSize:(CGFloat)fontSize;
+ (UIFont *)dmNavigationTitleFont;
+ (void)maskButton:(id)button;
+ (void)navigationControllerSetup:(UINavigationController *)navigationController;
+ (CGFloat)angleBetweenLocation:(CLLocation *)firstLocation andLocation:(CLLocation *)secondLocation;
+ (CGFloat)degreesToRadians:(CGFloat)degrees;
+ (CGFloat)radiansToDegrees:(CGFloat)radians;
+ (BOOL)isAtStation:(float)proximity;
+ (BOOL)isRetinaScreen;
+ (NSString *)deviceName;
+ (void)trackScreenWithName:(NSString *)screenName;
@end