//
//  DubaiMetroAppDelegate.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 8/27/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface DubaiMetroAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<GAITracker> tracker;

@end
