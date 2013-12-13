//
//  JourneyTableViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/18/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "JourneyTableViewController.h"
#import "DMBarButtonItem.h"
#import "MetroStation.h"
#import "MetroStationCDTVC.h"
#import "JourneyRoutesViewController.h"

#define PUSH_VIEW_ROUTES_SEGUE @"View Routes"

@interface JourneyTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *fromStationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *toStationCell;
@property (nonatomic, readwrite) MetroStation *fromStation;
@property (nonatomic, readwrite) MetroStation *toStation;
@property (nonatomic) NSIndexPath *selectedCellIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *viewRoutesButton;
@end

@implementation JourneyTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self setupBarButtonItems];
    [self setupCells];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [DMHelper trackScreenWithName:@"Journey Route Selection"];
}

- (void)setupCells
{
    self.fromStationCell.detailTextLabel.font = [DMHelper dmFontWithSize:self.fromStationCell.detailTextLabel.font.pointSize];
    self.toStationCell.detailTextLabel.font = [DMHelper dmFontWithSize:self.toStationCell.detailTextLabel.font.pointSize];

    self.fromStationCell.textLabel.font = [DMHelper dmFontWithSize:self.fromStationCell.textLabel.font.pointSize];
    self.toStationCell.textLabel.font = [DMHelper dmFontWithSize:self.toStationCell.textLabel.font.pointSize];
}

- (void)setupBarButtonItems
{
    if(self.isStartingJourney){
        if([self.navigationItem.leftBarButtonItem isKindOfClass:[DMBarButtonItem class]]){
            [((DMBarButtonItem *)self.navigationItem.leftBarButtonItem) setupOrdinaryBackgroundImage];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        //0, 0 -> From
        //0, 1 -> To
    self.selectedCellIndexPath = indexPath;
    [self performSegueWithIdentifier:@"setManagedObjectContext:" sender:[tableView cellForRowAtIndexPath:indexPath]];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"setManagedObjectContext:"]){
        if([sender isKindOfClass:[UITableViewCell class]]){
            if([segue.destinationViewController isKindOfClass:[MetroStationCDTVC class]]){
                MetroStationCDTVC *mcdtvc = (MetroStationCDTVC *)segue.destinationViewController;
                mcdtvc.managedObjectContext = self.managedObjectContext;
                mcdtvc.startingJourney = YES;

                if([sender isEqual:self.fromStationCell]){
                    if(self.toStation) mcdtvc.metroStationToDisable = self.toStation;
                }else if([sender isEqual:self.toStationCell]){
                    if(self.fromStation) mcdtvc.metroStationToDisable = self.fromStation;
                }
            }
        }
    }else if([segue.identifier isEqualToString:PUSH_VIEW_ROUTES_SEGUE]){
        if([segue.destinationViewController isKindOfClass:[JourneyRoutesViewController class]]){
            JourneyRoutesViewController *jrvc = (JourneyRoutesViewController *)segue.destinationViewController;
            jrvc.fromStation = self.fromStation;
            jrvc.toStation = self.toStation;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:PUSH_VIEW_ROUTES_SEGUE]){
        if(!self.fromStation || !self.toStation) return NO;
    }
    return YES;
}

- (IBAction)unwindToSetupJourney:(UIStoryboardSegue *)segue
{
    self.viewRoutesButton.hidden = YES;

    if([segue.sourceViewController isKindOfClass:[MetroStationCDTVC class]]){

        if(self.selectedCellIndexPath.section == 0 && self.selectedCellIndexPath.item == 0){ //From
            self.fromStation = ((MetroStationCDTVC *)segue.sourceViewController).selectedMetroStation;
        }else if(self.selectedCellIndexPath.section == 0 && self.selectedCellIndexPath.item == 1){ //To
            self.toStation = ((MetroStationCDTVC *)segue.sourceViewController).selectedMetroStation;
        }

        if(self.toStation && self.fromStation) self.viewRoutesButton.hidden = NO;
    }

}

- (void)setFromStation:(MetroStation *)fromStation
{
    _fromStation = fromStation;
    self.fromStationCell.detailTextLabel.text = _fromStation.stationName;
}

- (void)setToStation:(MetroStation *)toStation
{
    _toStation = toStation;
    self.toStationCell.detailTextLabel.text = _toStation.stationName;
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end