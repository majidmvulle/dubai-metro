//
//  JourneyRoutesCollectionViewCell.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/29/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JourneyRoutesCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *fromStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *toStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextTrainMinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromTowardsLabel;
@end
