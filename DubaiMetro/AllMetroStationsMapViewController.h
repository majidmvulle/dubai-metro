//
//  MetroStationsMapViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/9/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MapViewController.h"

@interface AllMetroStationsMapViewController : MapViewController
@property (nonatomic) BOOL needUpdateRegion;
- (void)reload;
@end