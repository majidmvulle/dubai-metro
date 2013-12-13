//
//  StaticMenuItemViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/15/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "StaticMenuItemViewController.h"
#import "OpenInChromeController.h"

@interface StaticMenuItemViewController ()<UIActionSheetDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UIActionSheet *appURLActionSheet;
@end

@implementation StaticMenuItemViewController

#pragma mark - UIViewController methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [DMHelper trackScreenWithName:self.title];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"termsofuse"]){
        ((UIViewController *)segue.destinationViewController).title = @"Terms of Use";
    }else if ([segue.identifier isEqualToString:@"privacypolicy"]){
        ((UIViewController *)segue.destinationViewController).title = @"Privacy Policy";
    }
}

- (IBAction)appURLTapped:(UIButton *)sender {
    NSString *chromeTitle = nil;

    if([[OpenInChromeController sharedInstance] isChromeInstalled]) chromeTitle = CHROME;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open In..."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:SAFARI,chromeTitle, nil];
    self.appURLActionSheet = actionSheet;
    [actionSheet showInView:self.navigationController.navigationBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == self.appURLActionSheet){
        NSURL *url = [NSURL URLWithString:APPURL];
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:SAFARI]){
            [[UIApplication sharedApplication] openURL:url];
        }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:CHROME]){
            [[OpenInChromeController sharedInstance] openInChrome:url withCallbackURL:nil createNewTab:YES];
        }
    }
}

- (void)setupFonts
{
    for(id subview in self.view.subviews){
        if([subview isKindOfClass:[UILabel class]]){
            ((UILabel *)subview).font = [DMHelper dmFontWithSize:((UILabel *)subview).font.pointSize];
        }else if([subview isKindOfClass:[UIButton class]]){
            ((UIButton *)subview).titleLabel.font = [DMHelper dmFontWithSize:((UIButton *)subview).titleLabel.font.pointSize];
        }
    }
}

@end