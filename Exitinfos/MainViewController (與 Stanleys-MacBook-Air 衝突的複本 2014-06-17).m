//
//  MainViewController.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/5.
//
//

#import "MainViewController.h"
#import "theColor.h"
#import "WhiteSearchBarInterface.h"
#import "MRTMap.h"
#import "theSQLite.h"
#import "TableViewCellBackground.h"
#import "PlaceDetailsViewController.h"
#import "theCheckInternet.h"
#import "BusDetailsViewController.h"
#import "YouBikeViewController.h"
#import <MapKit/MapKit.h>
#import "theGrayIllustratorView.h"

#define FunctionViewHeight 150

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize TopSearchBar,LocationButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (![[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"]) {
            if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hant"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"Languages"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hant" forKey:@"Languages"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] stringForKey:@"Languages"], nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [theColor ClassicGrayBackground];
    
    //iOS 7 Setting
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        StatusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        StatusBarBackgroundView.backgroundColor = [self RGBColor:@"dark gray"];
        [self.view addSubview:StatusBarBackgroundView];
        StatusBarHeight = 20;
        [self setNeedsStatusBarAppearanceUpdate];
        
        TopSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    }else{
        StatusBarHeight = 0;
        
        TopSearchBar = [[WhiteSearchBarInterface alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    }
    [self.view addSubview:TopSearchBar];
    self.TopSearchBar.delegate = self;
    self.TopSearchBar.backgroundColor = [theColor WhiteGrayColor];
    self.TopSearchBar.placeholder = NSLocalizedString(@"Search station", nil);
    TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideKeyboard)];
    //設定地圖
    Map = [[MRTMap alloc] initWithFrame:CGRectMake(0, 0, 1660, 2120) AndSuperView:self.view];
    Map.ShowFunctionDelegate = self;
    Map.DismissFunctionDelegate = self;
    [self.MRTMapScrollView addSubview:Map];
    UITapGestureRecognizer *DoubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DoubleTapZoom:)];
    [DoubleTapGesture setNumberOfTapsRequired:2];
    [self.MRTMapScrollView addGestureRecognizer:DoubleTapGesture];
    self.MRTMapScrollView.delegate = self;
    self.MRTMapScrollView.contentSize = Map.bounds.size;
    self.MRTMapScrollView.maximumZoomScale = 1.0;
    self.MRTMapScrollView.minimumZoomScale = 0.2;
    [self.MRTMapScrollView setUserInteractionEnabled:YES];
    [self.MRTMapScrollView setShowsHorizontalScrollIndicator:NO];
    [self.MRTMapScrollView setShowsVerticalScrollIndicator:NO];
    Scrolling = NO;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LastMapZoomScale"] !=nil)
        [self.MRTMapScrollView setZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"LastMapZoomScale"] animated:YES];
    else
        [self.MRTMapScrollView setZoomScale:1.0 animated:YES];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LastMapLocationX"] != nil)
        [self.MRTMapScrollView setContentOffset:CGPointMake([[NSUserDefaults standardUserDefaults] floatForKey:@"LastMapLocationX"], [[NSUserDefaults standardUserDefaults] floatForKey:@"LastMapLocationY"]) animated:YES];
    else{
        CGPoint CentralPoint = [Map ConvertStationCoordinate:[[Map.AllStationCoordinate objectAtIndex:0] CGPointValue]];
        CentralPoint = CGPointMake(CentralPoint.x-self.view.bounds.size.width/2, CentralPoint.y-self.view.bounds.size.height/3);
        [self.MRTMapScrollView setContentOffset:CentralPoint animated:YES];
    }
    SQLite = [theSQLite new];
    MRTList = [NSMutableArray new];
    MRTList = [SQLite ReturnTableData:@"select * from StationDataForStanley" andIndexOFColumn:1];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Version2.3Illustration"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) {
        UIAlertView *VersionIllustration = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"VersionIllustration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NoThanks", nil) otherButtonTitles:NSLocalizedString(@"RateMessage", nil), nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Version2.3Illustration"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HaveRated"];
        [VersionIllustration show];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchTimes"] > 3 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"HaveRated"]) {
            UIAlertView *JoinAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"RateAlertViewTitle", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NoThanks", nil) otherButtonTitles:NSLocalizedString(@"RateMessage", nil), nil];
            [JoinAlertView show];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HaveRated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchTimes"] > 5 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"HaveLike"]) {
            UIAlertView *RateAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"JoinFanPageTitle", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NoThanks", nil) otherButtonTitles:NSLocalizedString(@"JoinMessage", nil), nil];
            [RateAlertView show];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HaveLike"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        Illustration = [[theIllustration alloc] initWithFrame:CGRectMake(0, TopSearchBar.frame.size.height+StatusBarHeight, self.view.bounds.size.width, 30) AndType:@"MainViewIllustration"];
        [self.view addSubview:Illustration];
    }
    FunctionViewIsShow = NO;
    //設定現在位置按鈕
    LocationButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-45, 25, 25)];
    [LocationButton setImage:[UIImage imageNamed:@"LocationButtonNormal.png"] forState:UIControlStateNormal];
    [LocationButton setImage:[UIImage imageNamed:@"LocationButtonSelected.png"] forState:UIControlStateHighlighted];
    [LocationButton setImage:[UIImage imageNamed:@"LocationButtonSelected.png"] forState:UIControlStateSelected];
    [LocationButton setImage:[UIImage imageNamed:@"LocationButtonSelected.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self.view addSubview:LocationButton];
    [LocationButton addTarget:self action:@selector(LocationButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSUserDefaults *Setting = [NSUserDefaults standardUserDefaults];
    /*if ([Setting stringForKey:@"CardType"] == nil) {
        UIActionSheet *CardTypeOption = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Ticket Type", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Single Journal", nil),NSLocalizedString(@"EasyCard", nil),NSLocalizedString(@"Elder", nil), nil];
        [CardTypeOption showInView:self.MRTMapScrollView];
    }*/
}

- (void)viewDidUnload {
    [self setTopSearchBar:nil];
    [self setMRTMapScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Top search bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];

    if (![searchBar.text length]) {
        SearchResults = [NSMutableArray new];
        SearchResultsStationNumber = [NSMutableArray new];
        GrayView = [[UIView alloc] initWithFrame:CGRectMake(0, TopSearchBar.frame.size.height + TopSearchBar.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
        GrayView.backgroundColor = [UIColor grayColor];
        GrayView.alpha = 0.5;
        [GrayView addGestureRecognizer:TapGestureRecognizer];
        [self.view addSubview:GrayView];
        [self.TopSearchBar setShowsCancelButton:YES animated:YES];
        self.TopSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.TopSearchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self DismissStationSearchTableview];
    [self.TopSearchBar setShowsCancelButton:NO animated:YES];
    [self.TopSearchBar resignFirstResponder];
    self.TopSearchBar.text = @"";
    [self DismissStationSearchTableview];
    [GrayView removeFromSuperview];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [NoDataLable removeFromSuperview];
    if (NoDataLable)
        [NoDataLable removeFromSuperview];
    if (!StationSearchTableView.alpha)
        [self AddStationSearchTableView];
    if (searchText.length) {
        [self SearchMRT];
        [GrayView removeGestureRecognizer:TapGestureRecognizer];
        [GrayView removeFromSuperview];
    }else{
        if (StationSearchTableView.alpha)
            [self DismissStationSearchTableview];
        [GrayView addGestureRecognizer:TapGestureRecognizer];
        [self.view addSubview:GrayView];
    }
}

-(void)SearchMRT{
    [QueryFromGoogle.Connection cancel];
    QueryFromGoogle = nil;
    SearchBarText =  TopSearchBar.text;
    [SearchResults removeAllObjects];
    [SearchResultsStationNumber removeAllObjects];
    for (int i = 0; i < [MRTList count]; i ++) {
        NSString *StationIndex = [NSString stringWithFormat:@"%i",i];
        NSString *StationName = NSLocalizedString(StationIndex, nil);
        if ([StationName rangeOfString:SearchBarText options:NSAnchoredSearch].location != NSNotFound){
            [SearchResults addObject:StationName];
            [SearchResultsStationNumber addObject:[NSNumber numberWithInt:i]];
        }
    }
    if (![SearchResults count]) {
        theCheckInternet *CheckInternet = [theCheckInternet new];
        if (![CheckInternet isConnectionAvailable]) {
            if (!InternetFailLabel) {
                InternetFailLabel = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) AndLabelText:NSLocalizedString(@"CheckInternet", nil) AndTextSize:15];
                InternetFailLabel.textColor = [UIColor whiteColor];
                InternetFailLabel.center = CGPointMake(self.view.frame.size.width/2, 70);
                [StationSearchTableView addSubview:InternetFailLabel];
            }
        }else{
            SearchType = @"SearchPlace";
            CurrentLocation = [[theCurrentLocation alloc] initAndType:@"SearchCurrentCoordinate"];
            CurrentLocation.GetLocationCoordinateDelegate = self;
            [InternetFailLabel removeFromSuperview];
            //設定資料載入中
            if (![StationSearchTableView numberOfRowsInSection:0]) {
                if (!DataLoadingLabel) {
                    DataLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                    [DataLoadingIndicatorView startAnimating];
                    DataLoadingIndicatorView.center = CGPointMake(self.view.frame.size.width/2, self.TopSearchBar.frame.size.height+60);
                    DataLoadingIndicatorView.alpha = 0;
                    [StationSearchTableView addSubview:DataLoadingIndicatorView];
                    DataLoadingLabel = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) AndLabelText:NSLocalizedString(@"Loading", nil) AndTextSize:15];
                    DataLoadingLabel.textColor = [UIColor whiteColor];
                    DataLoadingLabel.center = CGPointMake(self.view.frame.size.width/2, DataLoadingIndicatorView.center.y+25);
                    DataLoadingLabel.alpha = 0;
                    [StationSearchTableView addSubview:DataLoadingLabel];
                    PowerByGoogleLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-non-white@2x.png"]];
                    PowerByGoogleLogo.frame = CGRectMake(self.view.frame.size.width/2-52, DataLoadingLabel.center.y+15, 104, 16);
                    PowerByGoogleLogo.alpha = 0;
                    [StationSearchTableView addSubview:PowerByGoogleLogo];
                }
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                PowerByGoogleLogo.alpha = 1;
                DataLoadingLabel.alpha = 1;
                DataLoadingIndicatorView.alpha = 1;
                [UIView commitAnimations];
            }
        }
    }else{
        SearchType = @"SearchMRT";
        [StationSearchTableView reloadData];
    }
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    KeyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    StationSearchTableView.frame = CGRectMake(0, 44+StatusBarHeight, 320, self.view.frame.size.height-44-KeyboardRect.size.height);
}

-(void)HideKeyboard
{
    [self DismissStationSearchTableview];
    [self.TopSearchBar setShowsCancelButton:NO animated:YES];
    [self.TopSearchBar resignFirstResponder];
    self.TopSearchBar.text = @"";
    [self DismissStationSearchTableview];
    [GrayView removeFromSuperview];
    [GrayView removeGestureRecognizer:TapGestureRecognizer];
}

-(void)LocationCoordinate:(theCurrentLocation *)CLocation
{
    QueryFromGoogle = [[theQueryDataFromGoogle alloc] initAndQueryGooglePlaces:SearchBarText AndSearchType:@"DirectSearch" AndCoordinate:CLLocationCoordinate2DMake(CurrentLocation.CurrentLocationData.coordinate.latitude, CurrentLocation.CurrentLocationData.coordinate.longitude) AndRadius:10000];
    QueryFromGoogle.QueryGoogleDelegate = self;
}

-(void)ShowGoogleResult:(theQueryDataFromGoogle *)QueryGooglePlace
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    PowerByGoogleLogo.alpha = 0;
    DataLoadingLabel.alpha = 0;
    DataLoadingIndicatorView.alpha = 0;
    [UIView commitAnimations];
    [StationSearchTableView reloadData];
    
    if (![QueryFromGoogle.PlaceExitResults count]) {
        if (!NoDataLable) {
            NoDataLable = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) AndLabelText:NSLocalizedString(@"NoData", nil) AndTextSize:15];
            NoDataLable.textColor = [UIColor whiteColor];
            NoDataLable.center = CGPointMake(self.view.frame.size.width/2, 70);
            NoDataLable.alpha = 0;
        }
        [StationSearchTableView addSubview:NoDataLable];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        NoDataLable.alpha = 1;
        [UIView commitAnimations];
    }
}

#pragma mark - Search bar table data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger NumberOfRows;
    if ([SearchType isEqualToString:@"SearchMRT"])
        NumberOfRows = SearchResults.count;
    else
        NumberOfRows = QueryFromGoogle.PlaceResults.count;
    
    return NumberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[TableViewCellBackground alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"CellSelectedBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    }
    if ([SearchType isEqualToString:@"SearchMRT"])
        cell.textLabel.text = [SearchResults objectAtIndex:indexPath.row];
    else{
        cell.textLabel.text = [QueryFromGoogle.PlaceResults objectAtIndex:indexPath.row];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.text = [QueryFromGoogle.PlaceExitResults objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([SearchType isEqualToString:@"SearchMRT"]) {
        [self HideKeyboard];
        [self DismissStationSearchTableview];
        CGPoint CentralStation = [Map ConvertStationCoordinate:[[Map.AllStationCoordinate objectAtIndex:[[SearchResultsStationNumber objectAtIndex:indexPath.row] intValue]] CGPointValue]];
        CentralStation = CGPointMake(CentralStation.x-self.view.bounds.size.width/2, CentralStation.y-self.view.bounds.size.height/3);
        [self.MRTMapScrollView setZoomScale:self.MRTMapScrollView.maximumZoomScale animated:YES];
        [self.MRTMapScrollView setContentOffset:CentralStation animated:YES];
        NSString *StationIndex = [NSString stringWithFormat:@"%@",[SearchResultsStationNumber objectAtIndex:indexPath.row]];
        [self ShowFunctionView:Map AndStationNameIndex:[StationIndex intValue] AndStationName:NSLocalizedString(StationIndex, nil) AndStationColor:[[SQLite ReturnTableData:@"select * from Map" andIndexOFColumn:18] objectAtIndex:[[SearchResultsStationNumber objectAtIndex:indexPath.row] intValue]]];
        [SearchResults removeAllObjects];
        [SearchResultsStationNumber removeAllObjects];
    }else{
        PlaceDetailsViewController *PlaceDetailsView = [[PlaceDetailsViewController alloc] init];
        PlaceDetailsView.PlaceReference = [QueryFromGoogle.PlaceReferences objectAtIndex:indexPath.row];
        PlaceDetailsView.PlaceExit = [QueryFromGoogle.PlaceExitResults objectAtIndex:indexPath.row];
        [self setTitle:NSLocalizedString(@"SearchPlace", nil)];
        [[self navigationController] pushViewController:PlaceDetailsView animated:YES];
        [GrayView removeFromSuperview];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Animation method

-(void)AddStationSearchTableView
{
    StationSearchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44+StatusBarHeight, 320, self.view.frame.size.height-44-KeyboardRect.size.height) style:UITableViewStyleGrouped];
    StationSearchTableView.dataSource = self;
    StationSearchTableView.delegate = self;
    StationSearchTableView.backgroundView = nil;
    StationSearchTableView.backgroundColor = [theColor ClassicGrayBackground];
    StationSearchTableView.alpha = 0;
    [self.view addSubview:StationSearchTableView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    StationSearchTableView.alpha = 1;
    [UIView commitAnimations];
}

-(void)DismissStationSearchTableview
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    StationSearchTableView.alpha = 0;
    [UIView commitAnimations];
    [InternetFailLabel removeFromSuperview];
    InternetFailLabel = nil;
}

#pragma mark Scrollview method

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return Map;
}

-(void)DoubleTapZoom:(UIGestureRecognizer *)gestureRecognizer
{
    if(self.MRTMapScrollView.zoomScale > self.MRTMapScrollView.minimumZoomScale){
        //縮小
        [self.MRTMapScrollView setZoomScale:self.MRTMapScrollView.minimumZoomScale animated:YES];
    }else{
        //放大
        [self.MRTMapScrollView zoomToRect:CGRectMake(Map.DoubleTapPoint.x-self.view.frame.size.width/2, Map.DoubleTapPoint.y-self.view.frame.size.height/2, Map.frame.size.width/self.MRTMapScrollView.maximumZoomScale, Map.frame.size.height/self.MRTMapScrollView.maximumZoomScale) animated:YES];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    Scrolling = NO;
    [[NSUserDefaults standardUserDefaults] setFloat:self.MRTMapScrollView.contentOffset.x forKey:@"LastMapLocationX"];
    [[NSUserDefaults standardUserDefaults] setFloat:self.MRTMapScrollView.contentOffset.y forKey:@"LastMapLocationY"];
    [[NSUserDefaults standardUserDefaults] setFloat:self.MRTMapScrollView.zoomScale forKey:@"LastMapZoomScale"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    Scrolling = YES;
}

#pragma mark All about MRTMap delegate

-(void)ShowFunctionView:(MRTMap*)theMRTMap AndStationNameIndex:(int)i AndStationName:(NSString *)Name AndStationColor:(NSString *)Color
{
    if (!FunctionViewIsShow) {
        [FunctionView removeFromSuperview];
        FunctionView = [[StationFunctionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height) StationName:Name StationColor:Color AndStationNumber:i];
        FunctionView.FunctionViewShowMoreDelegate = self;
        FunctionView.ChangeStatusBarColorDelegate = self;
        FunctionView.SetExitDelegate = self;
        FunctionView.SetTransferDelegate = self;
        [self.view addSubview:FunctionView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [FunctionView setFrame:CGRectMake(0, self.view.bounds.size.height-FunctionViewHeight, self
                                          .view.bounds.size.width, self.view.bounds.size.height)];
        [LocationButton setFrame:CGRectMake(20, self.view.bounds.size.height-FunctionViewHeight-45, 25, 25)];
        [UIView commitAnimations];
    }else if([FunctionView PriceAndTimeIsShow]){
        [FunctionView ChangeDestinyStation:Name AndStationColor:Color AndStationNumber:i];
    }else{
        if (![Name isEqualToString:FunctionView.StartStationName]){
            [FunctionView ShowPriceAndTime:Name AndStationColor:Color AndStationNumber:i];
            FunctionView.PriceAndTimeIsShow = YES;
        }
    }
    FunctionViewIsShow = YES;
}

-(void)DismissFunctionView:(MRTMap *)theMRTMap
{
    if (FunctionViewIsShow && !Scrolling) {
        [UpIllustration removeFromSuperview];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [FunctionView setFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
        [LocationButton setFrame:CGRectMake(20, self.view.bounds.size.height-45, 25, 25)];
        [UIView commitAnimations];
        
        FunctionViewIsShow = NO;
        LocationButton.highlighted = NO;
        LocationButton.selected = NO;
        [Illustration removeFromSuperview];
    }
}

#pragma mark All about show place details delegate

-(void)ShowPlaceDetails:(theExitInfosView *)theExit
{
    PlaceDetailsViewController *PlaceDetailsView = [[PlaceDetailsViewController alloc] init];
    PlaceDetailsView.PlaceReference = FunctionView.ExitInfosView.PlaceReference;
    PlaceDetailsView.PlaceExit = [NSString stringWithFormat:@"%@ %@",FunctionView.StartStationName,FunctionView.ExitInfosView.PlaceExit];
    [self setTitle:NSLocalizedString(@"ExitInfos", nil)];
    [[self navigationController] pushViewController:PlaceDetailsView animated:YES];
}

-(void)ShowBusDetails:(theTransferView *)theTransfer AndBusData:(NSMutableDictionary *)BusData
{
    BusDetailsViewController *BusDetailsView = [[BusDetailsViewController alloc] init];
    BusDetailsView.BusName = [BusData objectForKey:@"BusName"];
    BusDetailsView.Destination = [BusData objectForKey:@"Destination"];
    BusDetailsView.StopCoordinate = [BusData objectForKey:@"StopCoordinate"];
    BusDetailsView.StopName = [BusData objectForKey:@"StopName"];
    BusDetailsView.StationName = [BusData objectForKey:@"StationName"];
    [self setTitle:NSLocalizedString(@"TransitInfos", nil)];
    [[self navigationController] pushViewController:BusDetailsView animated:YES];
}

-(void)ShowYouBikeData:(theTransferView *)theTransfer AndYouBikeData:(NSMutableDictionary *)YouBikeData
{
    YouBikeViewController *YouBikeView = [[YouBikeViewController alloc] init];
    YouBikeView.StopName = [YouBikeData objectForKey:@"StopName"];
    YouBikeView.MRTStationName = [YouBikeData objectForKey:@"MRTStationName"];
    YouBikeView.ExitName = [YouBikeData objectForKey:@"ExitName"];
    [self setTitle:NSLocalizedString(@"TransitInfos", nil)];
    [[self navigationController] pushViewController:YouBikeView animated:YES];
}

#pragma mark  All about function view delegate

-(void)FunctionViewShowMore:(StationFunctionView *)theStationFunctionView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    FunctionView.frame = CGRectMake(0, StatusBarHeight, self.view.bounds.size.width, self.view.bounds.size.height-StatusBarHeight);
    if (FunctionView.IllustratorGrayView) {
        [UIView setAnimationDelegate:FunctionView.IllustratorGrayView];
        [UIView setAnimationDidStopSelector:@selector(ShowClearly)];
        FunctionView.IllustratorGrayView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        FunctionView.IllustratorGrayView.alpha = 0.7;
    }
    UpIllustration.alpha = 0;
    [UIView commitAnimations];
}

-(void)ChangeStatusBarColor:(StationFunctionView *)theStationFunctionView AndColorName:(NSString *)ColorName
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    StatusBarBackgroundView.backgroundColor = [self RGBColor:ColorName];
    [UIView commitAnimations];
}

-(void)SetExitInfosView:(StationFunctionView *)theStationFunctionView
{
    FunctionView.ExitInfosView.ShowPlaceDetailsDelegate = self;
}

-(void)SetTransferView:(StationFunctionView *)theStationFunctionView
{
    FunctionView.TransferView.ShowBusDetailsDelegate = self;
    FunctionView.TransferView.ShowYouBikeDataDelegate = self;
}

#pragma mark All about button click method

-(void)LocationButtonClick
{
    LocationButton.selected = YES;
    LocationButton.highlighted = YES;
    CurrentLocation = nil;
    CurrentLocation = [[theCurrentLocation alloc] initAndType:@"SearchStation"];
    CurrentLocation.ShowCurrentLocationDelegate = self;
    CurrentLocation.LocationSearchFailDelegate = self;
}

-(void)ShowCurrentLocation:(theCurrentLocation *)CLocation AndStationNameIndex:(int)i AndStationName:(NSString *)Name AndStationColor:(NSString *)Color
{
    if (!FunctionViewIsShow) {
        [FunctionView removeFromSuperview];
        FunctionView = [[StationFunctionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height) StationName:Name StationColor:Color AndStationNumber:i];
        FunctionView.FunctionViewShowMoreDelegate = self;
        FunctionView.ChangeStatusBarColorDelegate = self;
        FunctionView.SetExitDelegate = self;
        [self.view addSubview:FunctionView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [FunctionView setFrame:CGRectMake(0, self.view.bounds.size.height-FunctionViewHeight, self
                                          .view.bounds.size.width, self.view.bounds.size.height)];
        [LocationButton setFrame:CGRectMake(20, self.view.bounds.size.height-FunctionViewHeight-45, 25, 25)];
        [UIView commitAnimations];
        CGPoint CentralStation = [Map ConvertStationCoordinate:[[Map.AllStationCoordinate objectAtIndex:i] CGPointValue]];
        CentralStation = CGPointMake(CentralStation.x-self.view.bounds.size.width/2, CentralStation.y-self.view.bounds.size.height/3);
        [self.MRTMapScrollView setZoomScale:self.MRTMapScrollView.maximumZoomScale animated:YES];
        [self.MRTMapScrollView setContentOffset:CentralStation animated:YES];
    }else if([FunctionView PriceAndTimeIsShow]){
        [FunctionView ChangeDestinyStation:Name AndStationColor:Color AndStationNumber:i];
    }else{
        [FunctionView ShowPriceAndTime:Name AndStationColor:Color AndStationNumber:i];
        FunctionView.PriceAndTimeIsShow = YES;
    }
    FunctionViewIsShow = YES;
}

-(void)LocationSearchFail:(theCurrentLocation *)CLocation
{
    Illustration = nil;
    if ([CurrentLocation.CurrentStationName isEqualToString:NSLocalizedString(@"NoStationHere", nil)])
        Illustration = [[theIllustration alloc] initWithFrame:CGRectMake(0, TopSearchBar.frame.size.height+StatusBarHeight, self.view.bounds.size.width, 30) AndType:@"NoMRTNearby"];
    else
        Illustration = [[theIllustration alloc] initWithFrame:CGRectMake(0, TopSearchBar.frame.size.height+StatusBarHeight, self.view.bounds.size.width, 30) AndType:@"LocationSearchFail"];
    [self.view addSubview:Illustration];
    LocationButton.highlighted = NO;
    LocationButton.selected = NO;
}

#pragma mark - About actioin sheet and alert view

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
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView message] isEqualToString:NSLocalizedString(@"RateAlertViewTitle", nil)] || [[alertView message] isEqualToString:NSLocalizedString(@"VersionIllustration", nil)]) {
        switch (buttonIndex) {
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=555616229"]];
                break;
            default:
                break;
        }
    }else{
        if (buttonIndex == 1) {
            NSURL *fanPageURL = [NSURL URLWithString:@"fb://profile/344802778940827"];
            if (![[UIApplication sharedApplication] openURL: fanPageURL]) {
                //fanPageURL failed to open.  Open the website in Safari instead
                NSURL *webURL = [NSURL URLWithString:@"https://www.facebook.com/iMRTTaipei"];
                [[UIApplication sharedApplication] openURL: webURL];
            }
        }
    }
}

#pragma mark - All about color

-(UIColor *)RGBColor:(NSString *)ColorName
{
    UIColor *Color;
    if ([ColorName isEqualToString:@"blue"])
        Color = [UIColor colorWithRed:108/255.f green:122/255.f blue:152/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"brown"])
        Color = [UIColor colorWithRed:152/255.f green:70/255.f blue:46/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"orange"])
        Color = [UIColor colorWithRed:220/255.f green:147/255.f blue:81/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"red"])
        Color = [UIColor colorWithRed:178/255.f green:51/255.f blue:59/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"dark green"])
        Color = [UIColor colorWithRed:66/255.f green:112/255.f blue:96/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"green"])
        Color = [UIColor colorWithRed:78/255.f green:166/255.f blue:112/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"pink"])
        Color = [UIColor colorWithRed:226/255.f green:109/255.f blue:124/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"gray"])
        Color = [UIColor colorWithRed:65/255.f green:65/255.f blue:65/255.f alpha:1.0];
    else
        Color = [UIColor colorWithRed:127/255.f green:127/255.f blue:127/255.f alpha:1.0];

    return Color;
}

@end
