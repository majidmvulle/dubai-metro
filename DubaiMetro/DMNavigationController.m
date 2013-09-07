//
//  NavigationController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMNavigationController.h"
#import "DMBarButtonItem.h"

@interface DMNavigationController ()
@end

@implementation DMNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
    [self setupPKRevealController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[[UIApplication sharedApplication] delegate] window].rootViewController = self.revealController;

}

- (MenuTVC *)menuTVC
{
    if(!_menuTVC) _menuTVC = [[MenuTVC alloc] init];

    return _menuTVC;
}

- (void)setupPKRevealController
{
        // PKRevealController.h contains a list of all the specifiable options
    NSDictionary *options = @{
                              PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
                              PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
                              };

    self.revealController = [PKRevealController revealControllerWithFrontViewController:self leftViewController:self.menuTVC options:options];
}

- (void)setup
{
    self.navigationBar.translucent = YES; // Setting this slides the view up, underneath the nav bar (otherwise it'll appear black)
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    UIImage *img = [[UIImage alloc] init];
    UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];

    [self.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
        //remove shadow

    if([self.navigationBar respondsToSelector:@selector(setShadowImage:)]){
        [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    }

    for(id item in self.navigationBar.items){

        if([item isKindOfClass:[UINavigationItem class]]){
            UINavigationItem *aNavigationItem = (UINavigationItem *)item;

            NSArray *theBarButtonItems = [NSArray arrayWithObjects:aNavigationItem.leftBarButtonItems, aNavigationItem.rightBarButtonItems, nil];

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

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
