//
//  SettingsTableViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/15/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Settings.h"

@interface SettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *trackUsageSwitch;

@end

@implementation SettingsTableViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        //For iOS 6, uncheck all
    Settings *sharedSettings = [Settings sharedInstance];

    for(UITableViewCell *cell in [self.tableView visibleCells]){

        cell.detailTextLabel.font = [DMHelper dmFontWithSize:cell.detailTextLabel.font.pointSize];

            if([cell respondsToSelector:@selector(setAccessoryType:)]){
                cell.accessoryType = UITableViewCellAccessoryNone;

                if([cell.reuseIdentifier isEqualToString:@"imperial"]){
                    if(sharedSettings.isMeasurementImperial){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }

                }else if([cell.reuseIdentifier isEqualToString:@"metric"]){
                    if(!sharedSettings.isMeasurementImperial){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }

                }else if([cell.reuseIdentifier isEqualToString:@"twelvehour"]){
                    if(sharedSettings.isTimeTwelveHour) cell.accessoryType = UITableViewCellAccessoryCheckmark;

                }else if([cell.reuseIdentifier isEqualToString:@"twentyfourhour"]){
                    if(!sharedSettings.isTimeTwelveHour) cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
    }
    
    self.trackUsageSwitch.on = sharedSettings.shouldTrackUsage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [DMHelper trackScreenWithName:@"Settings"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Settings *sharedSettings = [Settings sharedInstance];

        //if measurements or time
    if(indexPath.section == 0 || indexPath.section == 1){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        [self uncheckCellsAtSection:indexPath.section];

        if([cell respondsToSelector:@selector(setAccessoryType:)]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;

            if([cell.reuseIdentifier isEqualToString:@"imperial"]){
                sharedSettings.measurementImperial = YES;
            }else if([cell.reuseIdentifier isEqualToString:@"metric"]){
                sharedSettings.measurementImperial = NO;
            }else if([cell.reuseIdentifier isEqualToString:@"twelvehour"]){
                sharedSettings.timeTwelveHour = YES;

            }else if([cell.reuseIdentifier isEqualToString:@"twentyfourhour"]){
                sharedSettings.timeTwelveHour = NO;
            }
        }
    }
    
    [sharedSettings synchronize];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)uncheckCellsAtSection:(NSInteger)section
{
    NSUInteger numberOfCellsInSection = [self.tableView numberOfRowsInSection:section];

    for(int i = 0; i <= numberOfCellsInSection; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];

        if(indexPath){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

            if(cell){
                if([cell respondsToSelector:@selector(setAccessoryType:)]){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
}

- (IBAction)trackUsageSwitchChanged:(UISwitch *)sender
{
    [Settings sharedInstance].shouldTrackUsage = sender.on;
    [[Settings sharedInstance] synchronize];
}

@end