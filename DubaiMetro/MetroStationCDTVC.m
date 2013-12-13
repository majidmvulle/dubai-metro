//
//  AllStationsCDTVC.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/7/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "MetroStationCDTVC.h"
#import "DMLocationManager.h"
#import "DMBarButtonItem.h"
#import "DefaultNavigationController.h"
#import "MetroStationTableViewCell.h"
#import "MetroStation+CreateFetch.h"
#import "MetroStationLine.h"
#import "TrainTimeViewController.h"

#define HOW_RECENT_INTERVAL 3.0
#define SORT_NEAREST_TO_ME @"Sort Nearest to Me"
#define SORT_BY_ALPHABET @"Sort Alphabetically"

@interface MetroStationCDTVC ()<CLLocationManagerDelegate,
UIActionSheetDelegate, DMLocationManagerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) DMLocationManager *dmLocationManager;
@property (nonatomic, strong) NSArray *metroStationSortDescriptors; //of SortDescriptors
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSPredicate *searchPredicate;
@end

@implementation MetroStationCDTVC

@synthesize metroStationSortDescriptors = _metroStationSortDescriptors;

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors([[UIImage alloc] init].CGImage, colorMask);
    UIImage *image = [UIImage imageWithCGImage:imageRef];

    UIBarButtonItem *cancelButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];

        UITextField *searchTextField = [UITextField appearanceWhenContainedIn:[UISearchBar class], nil];

    CGFloat cancelButtonFontSize = 14.0;

    if([DMHelper sharedInstance].isOS7AndAbove){
        [self.searchBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        self.searchBar.barTintColor = BACKGROUND_COLOR;
        cancelButtonFontSize = 16.0;

        [searchTextField setTextColor:[UIColor whiteColor]];
    }else{
        [self.searchBar setBackgroundImage:image];
        self.searchBar.tintColor = BACKGROUND_COLOR;

        [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn-ordinary.jpg"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }

    
    [cancelButton setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],
                                           NSFontAttributeName:[DMHelper dmFontWithSize:cancelButtonFontSize]}
                                forState:UIControlStateNormal];

    [searchTextField setFont:[DMHelper dmFontWithSize:searchTextField.font.pointSize]];

    self.searchBar.backgroundColor = BACKGROUND_COLOR;

    CGImageRelease(imageRef);

    [self hideTheSearchBar];
    [self setupRightBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(self.searchBar.text.length < 1){
        self.searchPredicate = nil;
        [self hideTheSearchBar];
    }

    [self setupFetchedResultsController];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupLocationManager];

    if(self.shouldShowStationTrainTimings){
            [DMHelper trackScreenWithName:@"Train Timings Table View"];
    }else{
            [DMHelper trackScreenWithName:@"Metro Stations Table View"];
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.dmLocationManager stopChangeUpdates];
    self.dmLocationManager.dmLocationDelegate = nil;
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewStationDetails"] ||
       [segue.identifier isEqualToString:@"viewStationTrainTimings"]){

        if([sender isKindOfClass:[UITableViewCell class]]){
            NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];

            if(indexPath){
                if([segue.destinationViewController respondsToSelector:@selector(setMetroStation:)]){
                    MetroStation *station = [self.fetchedResultsController objectAtIndexPath:indexPath];
                
                    [segue.destinationViewController performSelector:@selector(setMetroStation:) withObject:station];
                }
            }
        }
    }
}


#pragma mark - Setups

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    [self setupLocationManager];
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if(self.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MetroStation"];
        request.sortDescriptors = self.metroStationSortDescriptors;

        request.predicate = self.searchPredicate; //all records

        NSString *cacheName = (!self.searchPredicate ? @"All Metro Stations Cache" : nil);

        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:cacheName];
    }else{
        self.fetchedResultsController = nil;
    }
}

- (NSArray *)metroStationSortDescriptors
{
    if(!_metroStationSortDescriptors) _metroStationSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stationProximity"
                                                                                                     ascending:YES],
                                                                       [NSSortDescriptor sortDescriptorWithKey:@"stationName"
                                                                                                     ascending:YES]];
    return _metroStationSortDescriptors;
}

- (void)setMetroStationSortDescriptors:(NSArray *)metroStationSortDescriptors
{
    if([metroStationSortDescriptors count]){
        if(![_metroStationSortDescriptors isEqualToArray:metroStationSortDescriptors]){
            _metroStationSortDescriptors = metroStationSortDescriptors;
        }
    }
}

- (void)setupLocationManager
{
    self.dmLocationManager = [DMLocationManager sharedInstance];
    self.dmLocationManager.dmLocationDelegate = self;

    [self.dmLocationManager startStandardChangeUpdates];
}

- (void)setupRightBarButtonItem
{
    if([self.navigationItem.rightBarButtonItem isKindOfClass:[DMBarButtonItem class]]){
        [((DMBarButtonItem *)self.navigationItem.rightBarButtonItem) setupOrdinaryBackgroundImage];
    }

    [self.navigationItem.backBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[DMHelper dmNavigationTitleFont], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
}


- (IBAction)sort:(DMBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort Metro Stations"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:SORT_NEAREST_TO_ME,SORT_BY_ALPHABET, nil];

    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *sortBy = [NSArray array];

    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:SORT_NEAREST_TO_ME]){
        sortBy = @[[NSSortDescriptor sortDescriptorWithKey:@"stationProximity"
                                                 ascending:YES],
                   [NSSortDescriptor sortDescriptorWithKey:@"stationName"
                                                 ascending:YES]];
    }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:SORT_BY_ALPHABET]){
        sortBy = @[[NSSortDescriptor sortDescriptorWithKey:@"stationName"
                                                 ascending:YES],
                   [NSSortDescriptor sortDescriptorWithKey:@"stationProximity"
                                                 ascending:YES]];
    }

    self.metroStationSortDescriptors = [NSArray arrayWithArray:sortBy];
    [self setupFetchedResultsController];
}

#pragma mark - UITableViewController Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetroStationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MetroStationCell"];
    MetroStation *metroStation = [self.fetchedResultsController objectAtIndexPath:indexPath];


    if(self.isStartingJourney){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    BOOL isStationOperational = [metroStation.isStationOperational boolValue];
    [cell setUserInteractionEnabled:YES];

    if(!isStationOperational || [metroStation isEqual:self.metroStationToDisable]){
        [cell setUserInteractionEnabled:NO];
    }

    NSMutableArray *stationLineNames = [NSMutableArray array];

        //Station Lines
    [[metroStation.stationLines allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MetroStationLine *line = (MetroStationLine *)obj;
        [stationLineNames addObject:line.stationLineName];
    }];

        //Set up Cell info
    cell.stationNameLabel.text = [metroStation.stationName uppercaseString];
    cell.stationLineLabel.text = [NSString stringWithFormat:@"Lines: %@",
                                  [[stationLineNames componentsJoinedByString:@", "] uppercaseString]];
    cell.stationZoneLabel.text = [NSString stringWithFormat:@"Zone: %d", [metroStation.stationZone intValue]];
    cell.stationOperationLabel.text = [NSString stringWithFormat:@"Status: %@",
                                       [metroStation.isStationOperational intValue] ? DM_STATION_ACTIVE : DM_STATION_NOT_ACTIVE];
    cell.proximityView.backgroundColor = [UIColor clearColor];

    DistanceSuffix distanceSuffix;
    distanceSuffix.isShortSuffix = YES;
    distanceSuffix.isLongSuffix = NO;

    NSString *proximityTextTop = @"";
    NSString *proximityTextBottom = @"";

    if([DMHelper isAtStation:[metroStation.stationProximity floatValue]]){
        proximityTextTop = @"You Are";
        proximityTextBottom = @"Here";

    }else{
        proximityTextTop = [NSString stringWithFormat:@"%@",[[DMHelper sharedInstance] formatDistance:metroStation.stationProximity withSuffix:distanceSuffix]];
        proximityTextBottom = @"Away";
    }

    if(self.dmLocationManager.isAuthorized){
        cell.proximityTopLabel.text = proximityTextTop;
        cell.proximityBottomLabel.text = proximityTextBottom;
    }else{
        cell.proximityTopLabel.text = @"-";
        cell.proximityBottomLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if(self.isStartingJourney){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedMetroStation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"unwindToSetupJourney:" sender:cell];
    }else{
        if(self.shouldShowStationTrainTimings){
            [self performSegueWithIdentifier:@"viewStationTrainTimings" sender:cell];
        }else{
            [self performSegueWithIdentifier:@"viewStationDetails" sender:cell];
        }
    }
}

#pragma mark - SearchBar Delegate methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self hideTheSearchBar];
    searchBar.text = nil;
    self.searchPredicate = nil;
    [self setupFetchedResultsController];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length > 0){
        self.searchPredicate = [NSPredicate predicateWithFormat:@"stationName CONTAINS[cd] %@", searchText];
        [self setupFetchedResultsController];
    }else{
        self.searchPredicate = nil;
        [self setupFetchedResultsController];
    }
}

- (void)hideTheSearchBar
{
        //hide search bar
    CGFloat height = 44.0;

    if([self.navigationController isKindOfClass:[DMNavigationController class]]){
        height = ((DMNavigationController *)self.navigationController).navHeight;
    }
        //Hide search bar
    [self.tableView setContentOffset:CGPointMake(0,height) animated:YES];
}

#pragma mark - DMLocationManagerDelegate methods

- (void)currentLocationChangedTo:(CLLocation *)newLocation
{
    if(self.view.window && self.managedObjectContext){
        [MetroStation updateMetroStationProximitiesUsingLocationManager:self.dmLocationManager
                                                 inManagedObjectContext:self.managedObjectContext];
    }
}

- (void)authorizationStatusChangedTo:(CLAuthorizationStatus)status
{
    [self.tableView reloadData];
}

@end