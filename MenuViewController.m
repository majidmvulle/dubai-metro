//
//  MenuViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MenuViewController.h"
#import "DefaultNavigationController.h"
#import "MetroStationCDTVC.h"
#import "CoreDataHelper.h"
#import "MenuCell.h"
#import "DMViewController.h"
#import "DMBarButtonItem.h"
#import "JourneyTableViewController.h"

@interface MenuViewController () <UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;
@property (nonatomic, strong) NSMutableDictionary *menuViewControllers;
@end

@implementation MenuViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [DMHelper trackScreenWithName:@"Menu"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.menuViewControllers = nil;
#ifdef DM_DEBUG
    NSLog(@"Menu received memory warning");
#endif
}

- (void)setup
{
    self.topToolBar.translucent = NO; //iOS 7 sets it to YES by default

    const float colorMask[6] = {23, 255, 30, 255, 49, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors([[UIImage alloc] init].CGImage, colorMask);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];

    if([DMHelper sharedInstance].isOS7AndAbove){
        self.topToolBar.barTintColor = BACKGROUND_COLOR;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        self.topToolBar.backgroundColor = BACKGROUND_COLOR;
    }

    [self.topToolBar setBackgroundImage:maskedImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];

    CGImageRelease(imageRef);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Embed TVC"]){
        if([segue.destinationViewController isKindOfClass:[UITableViewController class]]){
            self.embeddedTableViewController = (UITableViewController *)segue.destinationViewController;
            self.embeddedTableViewController.tableView.delegate = self;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[MenuCell class]]){
        MenuCell *cell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];

        NSString *reuseId = cell.reuseIdentifier;

        if([self.revealController.frontViewController isKindOfClass:[DefaultNavigationController class]]){
            DefaultNavigationController *frontViewController = (DefaultNavigationController *)self.revealController.frontViewController;

                //set Dashboard currentlyActive the first time
            if([[frontViewController viewControllers] count] == 1 && [reuseId isEqualToString:@"dashboard"]){
                if([[[frontViewController viewControllers] lastObject] isKindOfClass:[DMViewController class]]){
                    cell.currentlyActive = YES;
                    self.menuViewControllers[@"dashboard"] = [[frontViewController viewControllers] lastObject];
                }
            }

            if(!cell.isCurrentlyActive){

                if(reuseId){
                    UIViewController *aViewController = nil;

                    if([reuseId isEqualToString:@"dashboard"]){

                        if([self.menuViewControllers[@"dashboard"] isKindOfClass:[UIViewController class]]){
                            aViewController = self.menuViewControllers[@"dashboard"];
                        }else{
                            aViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DMViewController"];
                        }

                        [self setCellActive:cell];

                    }else if([reuseId isEqualToString:@"train"]){

                        if([self.menuViewControllers[@"train"] isKindOfClass:[UIViewController class]]){
                            aViewController = self.menuViewControllers[@"train"];
                        }else{

                            aViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MetroStationCDTVC"];
                        }

                        NSManagedObjectContext *context = frontViewController.managedObjectContext;

                        if(!context){
                            context = [CoreDataHelper sharedManagedDocument].managedObjectContext;
                        }
                        ((MetroStationCDTVC *)aViewController).managedObjectContext = context;
                        aViewController.title = @"Metro Station Details";
                        [self setCellActive:cell];

                    }else if([reuseId isEqualToString:@"routes"]){

                        if([self.menuViewControllers[@"routes"] isKindOfClass:[UIViewController class]]){
                            aViewController = self.menuViewControllers[@"routes"];
                        }else{
                            aViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"JourneyTableViewController"];
                        }
                        aViewController.title = @"Journey Routes";

                        NSManagedObjectContext *context = frontViewController.managedObjectContext;

                        if(!context){
                            context = [CoreDataHelper sharedManagedDocument].managedObjectContext;
                        }

                        ((JourneyTableViewController*)aViewController).managedObjectContext = context;
                        
                        [self setCellActive:cell];

                    }else if ([reuseId isEqualToString:@"timings"]){

                        if([self.menuViewControllers[@"timings"] isKindOfClass:[UIViewController class]]){
                            aViewController = self.menuViewControllers[@"timings"];
                        }else{
                            aViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MetroStationCDTVC"];
                        }

                        NSManagedObjectContext *context = frontViewController.managedObjectContext;

                        if(!context){
                            context = [CoreDataHelper sharedManagedDocument].managedObjectContext;
                        }

                        ((MetroStationCDTVC *)aViewController).managedObjectContext = context;
                        ((MetroStationCDTVC *)aViewController).shouldShowStationTrainTimings = YES;
                        aViewController.title = @"Metro Station Timings";

                        [self setCellActive:cell];

                    }else if ([reuseId isEqualToString:@"settings"]){

                        if([self.menuViewControllers[@"settings"] isKindOfClass:[UIViewController class]]){
                            aViewController = self.menuViewControllers[@"settings"];
                        }else{
                            aViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
                        }

                        [self setCellActive:cell];

                    }else if ([reuseId isEqualToString:@"rate"]){
#ifdef DM_DEBUG
                        NSLog(@"Rating");
#endif
                        [self setCellActive:cell];

                    }else if ([reuseId isEqualToString:@"about"]){

                        if([self.menuViewControllers[@"about"] isKindOfClass:[UIViewController class]]){
                            aViewController = self.menuViewControllers[@"about"];
                        }else{
                             aViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
                        }

                        [self setCellActive:cell];
                    }

                        if(aViewController){
                            [frontViewController setViewControllers:@[aViewController] animated:NO];

                            if(![aViewController isKindOfClass:[JourneyTableViewController class]]){
                                [self cacheViewController:aViewController forKey:reuseId];
                            }
                        }

                    aViewController = nil;

                } //end reuseId check
            } //end currently active check

        }//end Navigation Controller check

            //Feedbacking
        if ([reuseId isEqualToString:@"feedback"]){
            if([MFMailComposeViewController canSendMail]){
                MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                mailComposer.mailComposeDelegate = self;
                [mailComposer setToRecipients:@[@"dubaimetro@majidmvulle.com"]];
                [mailComposer setSubject:@"DubaiMetro App Feedback"];

                NSLocale *usEnglishLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];

                NSString *model = [[UIDevice currentDevice] model];
                NSString *systemVersion = [[UIDevice currentDevice] systemVersion];

                NSString *country = [usEnglishLocale displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] localeIdentifier]];
                NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];

                NSString *mailBody = @"";

                mailBody =[NSString stringWithFormat:@"<br/><br/><br/><br/>%@ (%@) running iOS %@ <br/>Locale: %@ <br>DubaiMetro app version %@",model,[DMHelper deviceName],
                           systemVersion, country, appVersion] ;

                [mailComposer setMessageBody:mailBody isHTML:YES];

                [self presentViewController:mailComposer animated:YES completion:^{
                    [DMHelper trackScreenWithName:@"Feeback"];
                }];

            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Send Emails"
                                                                message:@"To send a feedback, you have to be able to send emails"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }

        }else{
            [self.revealController showViewController:self.revealController.frontViewController];
        }

    } //end table Cell check
}

- (void)setCellActive:(MenuCell *)cell
{
    NSArray *cells = [self.embeddedTableViewController.tableView visibleCells];

    for(id aCell in cells){
        if([aCell isKindOfClass:[MenuCell class]]) ((MenuCell *)aCell).currentlyActive = NO;
    }

    cell.currentlyActive = YES;
}

- (NSMutableDictionary *)menuViewControllers
{
    if(!_menuViewControllers) _menuViewControllers = [NSMutableDictionary dictionary];

    return _menuViewControllers;
}

- (void)cacheViewController:(id)aViewController forKey:(id)key
{
    [self.menuViewControllers setObject:aViewController forKey:key];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end