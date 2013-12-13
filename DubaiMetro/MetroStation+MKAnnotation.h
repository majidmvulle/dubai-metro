//
//  MetroStation+MKAnnotation.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/19/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStation.h"
#import <MapKit/MapKit.h>

@interface MetroStation (MKAnnotation)<MKAnnotation>
- (UIImage *)thumbnail;
@end