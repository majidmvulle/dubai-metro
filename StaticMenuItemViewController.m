//
//  StaticMenuItemViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/15/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import "StaticMenuItemViewController.h"
#import "OpenInChromeController.h"
#import "LoadingOverlay.h"

@interface StaticMenuItemViewController ()<UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
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
        NSURL *url = [NSURL URLWithString:APP_WEBPAGE];
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
- (IBAction)doFeedback:(UIButton *)sender {
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

        LoadingOverlay *loadingOverlay = [[LoadingOverlay alloc] initWithCustomFrame:[UIScreen mainScreen].bounds];

        [self.navigationController.view addSubview:loadingOverlay];
        [self.navigationController.view bringSubviewToFront:loadingOverlay];

        [self presentViewController:mailComposer animated:YES completion:^{
            [loadingOverlay hide];
            [DMHelper trackScreenWithName:@"Feeback"];
        }];

    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Send Emails"
                                                        message:@"To send a feedback, you have to be able to send emails"
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)doShareApp:(UIButton *)sender
{
    UIImage *firstScreenShot = [UIImage imageNamed:@"walkthrough-1.png"];

    NSString *descriptionText = [@"I have been using this beautiful DubaiMetro app. Grab it over here: "
                                 stringByAppendingString:APPSTORE_SHORT_URL];

    NSArray *activityItems = @[firstScreenShot, descriptionText];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:nil];
    LoadingOverlay *loadingOverlay = [[LoadingOverlay alloc] initWithCustomFrame:[UIScreen mainScreen].bounds];

    [self.navigationController.view addSubview:loadingOverlay];
    [self.navigationController.view bringSubviewToFront:loadingOverlay];

    [self presentViewController:activityViewController animated:YES completion:^{
        [loadingOverlay hide];
        [DMHelper trackScreenWithName:@"Share This App"];
    }];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end