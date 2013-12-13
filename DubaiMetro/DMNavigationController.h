//
//  NavigationController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface DMNavigationController : UINavigationController
@property (nonatomic, readonly) CGFloat navHeight;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end