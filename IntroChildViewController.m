//
//  IntroChildViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/24/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "IntroChildViewController.h"

@implementation IntroChildViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSInteger i = self.index + 1;

    switch (i) {
        case 1:
            self.featureTextLabel.attributedText = [self applyLabelAtrributesForTitle:@"Find."
                                                                             subtitle:@"Nearest Metro Station."];
            self.featureImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"walkthrough-%d.png",(int)i]];
            break;
        case 2:
            self.featureTextLabel.attributedText = [self applyLabelAtrributesForTitle:@"Calculate."
                                                                             subtitle:@"Routes. Tickect Prices."];
            self.featureImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"walkthrough-%d.png",(int)i]];
            break;
        case 3:
            self.featureTextLabel.attributedText = [self applyLabelAtrributesForTitle:@"View."
                                                                             subtitle:@"Metro Station Details."];
            self.featureImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"walkthrough-%d.png",(int)i]];
            break;
        case 4:
            self.featureTextLabel.attributedText = [self applyLabelAtrributesForTitle:@"See."
                                                                             subtitle:@"Train Timings."];
            self.featureImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"walkthrough-%d.png",(int)i]];
            break;

        default:
            break;
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSMutableAttributedString *)applyLabelAtrributesForTitle:(NSString *)mainTitle
                                                   subtitle:(NSString *)subTitle
{
    CGFloat fontSize = 18.0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];

    NSMutableAttributedString *attributedString = nil;
    attributedString = [[NSMutableAttributedString alloc] initWithString:[[mainTitle stringByAppendingString:@"\n"]
                                                                          stringByAppendingString:subTitle]];

    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    NSRange mainTitleRange = NSMakeRange(0, mainTitle.length);

    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:DM_FONT_NAME size:fontSize] range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:DM_FONT_NAME size:(fontSize * 2.0)] range:mainTitleRange];
        //    [attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:1.0] range:attributedStringRange];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedStringRange];

    return attributedString;
}

@end
