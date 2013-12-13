//
//  MetroStation+MKAnnotation.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/19/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStation+MKAnnotation.h"

@implementation MetroStation (MKAnnotation)

- (NSString *)title
{
    return self.stationName;
}

- (NSString *)subtitle
{
    DistanceSuffix distanceSuffix;
    distanceSuffix.isShortSuffix = YES;
    distanceSuffix.isLongSuffix = NO;

    if([DMHelper isAtStation:[self.stationProximity floatValue]]) return AT_STATION_TEXT;

    return [NSString stringWithFormat:@"About %@ Away", [[DMHelper sharedInstance] formatDistance:self.stationProximity
                                                                                       withSuffix:distanceSuffix]];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.stationLatitude doubleValue], [self.stationLongitude doubleValue]);
}

- (UIImage *)thumbnail
{
    UIImage *thumbnail = nil;

    if([DMHelper sharedInstance].isOS7AndAbove){
        thumbnail = [UIImage imageNamed:@"map-annotation-blue.png"];
    }else{
        thumbnail = [UIImage imageNamed:@"map-annotation-white.png"];
    }

    return thumbnail;
}

@end