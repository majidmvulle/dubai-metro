//
//  MetroStationTableViewCell.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/12/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetroStationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationZoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationOperationLabel;
@property (weak, nonatomic) IBOutlet UIView *proximityView;
@property (weak, nonatomic) IBOutlet UILabel *proximityTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityBottomLabel;
@end