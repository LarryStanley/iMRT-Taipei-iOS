//
//  CopyRightViewController.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/6.
//
//

#import "CopyRightViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "theColor.h"
#import <MessageUI/MessageUI.h>
#import "TableViewCellBackground.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface CopyRightViewController ()

@end

@implementation CopyRightViewController
@synthesize NavigationBar,CardTypeTableView,VersionLable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIView *StatusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        StatusBarBackgroundView.backgroundColor = [UIColor colorWithRed:127/255.f green:127/255.f blue:127/255.f alpha:1.0];
        NavigationBar.backgroundColor = [theColor WhiteGrayColor];
        [self.view addSubview:StatusBarBackgroundView];
        [self setNeedsStatusBarAppearanceUpdate];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [StatusBarBackgroundView setAutoresizesSubviews:YES];
            [StatusBarBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        }
    }else{
        self.NavigationBar.frame = CGRectMake(0, 0, 320, 44);
    }
    
    self.view.backgroundColor = [theColor ClassicGrayBackground];
    NavigationBar.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        
    CardTypeTableView.delegate = self;
    CardTypeTableView.dataSource = self;
    CardTypeTableView.scrollEnabled = NO;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    VersionLable.text = [NSString stringWithFormat:NSLocalizedString(@"Version", nil),version];
    
    self.IconImageView.layer.cornerRadius = 10;
    self.IconImageView.layer.masksToBounds = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CopyRight View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContactUs:nil];
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
    [self setAppStoreRate:nil];
    [self setNavigationBar:nil];
    [self setCardTypeTableView:nil];
    [self setVersionLable:nil];
    [self setIconImageView:nil];
    [super viewDidUnload];
}

#pragma mark - All about butto method

- (IBAction)ContactUsButtonTouch:(id)sender {
    MFMailComposeViewController *MailController = [MFMailComposeViewController new];
    MailController.mailComposeDelegate = self;
    [MailController setToRecipients:[NSArray arrayWithObject:@"Ly9Stanley@gmail.com"]];
    [MailController setSubject:NSLocalizedString(@"LetterTitle", nil)];
    [self presentModalViewController:MailController animated:YES];
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CopyRight View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Contact Us Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (IBAction)AppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=555616229"]];
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CopyRight View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"App Store Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (IBAction)FacebookButtonPressed:(id)sender {
    NSURL *fanPageURL = [NSURL URLWithString:@"fb://profile/344802778940827"];
    if (![[UIApplication sharedApplication] openURL: fanPageURL]) {
        //fanPageURL failed to open.  Open the website in Safari instead
        NSURL *webURL = [NSURL URLWithString:@"https://www.facebook.com/iMRTTaipei"];
        [[UIApplication sharedApplication] openURL: webURL];
    }
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CopyRight View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Facebook Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (IBAction)TwitterButtonPressed:(id)sender {
    NSURL *TwitterPageURL = [NSURL URLWithString:@"twitter://user?screen_name=iMRTTaipei"];
    if (![[UIApplication sharedApplication] openURL: TwitterPageURL]) {
        //fanPageURL failed to open.  Open the website in Safari instead
        NSURL *webURL = [NSURL URLWithString:@"https://twitter.com/iMRTTaipei"];
        [[UIApplication sharedApplication] openURL: webURL];
    }
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CopyRight View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Twitter Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}


#pragma mark - All about table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [theColor WhiteGrayColor];
    cell.backgroundView = [TableViewCellBackground new];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"CellSelectedBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    //關於要顯示的文字
    CardTypeName = NSLocalizedString(@"TypeOfTicket", nil);
    NSUserDefaults *Setting = [NSUserDefaults standardUserDefaults];
    if ([[Setting stringForKey:@"CardType"] isEqualToString:@"EasyCard"])
        CardTypeName = [CardTypeName stringByAppendingString:NSLocalizedString(@"EasyCard", nil)];
    else if ([[Setting stringForKey:@"CardType"] isEqualToString:@"ElderCard"])
        CardTypeName = [CardTypeName stringByAppendingString:NSLocalizedString(@"Elder", nil)];
    else
        CardTypeName = [CardTypeName stringByAppendingString:NSLocalizedString(@"Single Journal", nil)];
    cell.textLabel.text = CardTypeName;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *CardTypeOption = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelctTicketTypeShort", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Single Journal", nil),NSLocalizedString(@"EasyCard", nil),NSLocalizedString(@"Elder", nil), nil];
    [CardTypeOption showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *Setting = [NSUserDefaults standardUserDefaults];
    switch (buttonIndex) {
        case 1:
            [Setting setObject:@"EasyCard" forKey:@"CardType"];
            break;
        case 2:
            [Setting setObject:@"ElderCard" forKey:@"CardType"];
            break;
        default:
            [Setting setObject:@"NormalCard" forKey:@"CardType"];
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [CardTypeTableView reloadData];
}

#pragma mark All about mail delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}
@end
