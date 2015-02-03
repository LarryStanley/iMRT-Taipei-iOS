//
//  YouBikeViewController.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/8/4.
//
//

#import "YouBikeViewController.h"
#import "theColor.h"
#import "theCheckInternet.h"
#import "theSQLite.h"

@interface YouBikeViewController ()

@end

@implementation YouBikeViewController
@synthesize StopName,MRTStationName,ExitName;

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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setTitle:NSLocalizedString(@"DetailedInfos", nil)];
    self.view.backgroundColor = [theColor WhiteBackground];
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
    theCheckInternet *CheckInternet = [theCheckInternet new];
    if ([CheckInternet isConnectionAvailable]) {
        //iOS 7 setting
        int StatusBarHeight;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            StatusBarHeight = 20;
        else
            StatusBarHeight = 0;
        //設定資料載入中元素
        DataLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [DataLoadingIndicatorView startAnimating];
        DataLoadingIndicatorView.center = CGPointMake(self.view.frame.size.width/2, 60+StatusBarHeight);
        [self.view addSubview:DataLoadingIndicatorView];
        DataLoadingLabel = [UILabel new];
        DataLoadingLabel.text = NSLocalizedString(@"Loading", nil);
        DataLoadingLabel.font = [UIFont systemFontOfSize:15];
        DataLoadingLabel.backgroundColor = [UIColor clearColor];
        DataLoadingLabel.textAlignment = UITextAlignmentCenter;
        [DataLoadingLabel sizeToFit];
        DataLoadingLabel.center = CGPointMake(self.view.frame.size.width/2, DataLoadingIndicatorView.center.y+25);
        [self.view addSubview:DataLoadingLabel];
        //查詢Youbike資料
        theSQLite *SQLite = [theSQLite new];
        YouBikeData = [SQLite ReturnSingleRowWithDictionary:[NSString stringWithFormat:@"select * from YouBike where StopName = '%@'",StopName]];
        
        //設定資料元件
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        else
            ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];        ScrollView.backgroundColor = [UIColor clearColor];
        ScrollView.alpha = 0;
        [self.view addSubview:ScrollView];
        
        //設定結果標簽
        StopNameLable = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(20, 20, 0, 0) AndLabelText:[YouBikeData objectForKey:@"StopName"] AndTextSize:20];
        [ScrollView addSubview:StopNameLable];
        AddressLable = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(20, 320, 0, 0) AndLabelText:[NSString stringWithFormat:NSLocalizedString(@"Address", nil),[YouBikeData objectForKey:@"Address"]] AndTextSize:15];
        [ScrollView addSubview:AddressLable];
        ExitNameLable = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(20, 345, 0, 0) AndLabelText:[NSString stringWithFormat:@"%@ %@",MRTStationName, ExitName] AndTextSize:15];
        [ScrollView addSubview:ExitNameLable];
        CountOfBikeLable = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(20, 370, 0, 0) AndLabelText:[NSString stringWithFormat:NSLocalizedString(@"CountOfPark", nil),[YouBikeData objectForKey:@"CountOfBike"]] AndTextSize:15];
        [ScrollView addSubview:CountOfBikeLable];
        
        //設定按鈕
        ShowInMapButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-103, 395, 98, 33) AndButtonText:NSLocalizedString(@"ShowInMap", nil)];
        [ShowInMapButton addTarget:self action:@selector(ShowInMapButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [ScrollView addSubview:ShowInMapButton];
        
        RouteNavigateButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2+5, 395, 98, 33) AndButtonText:NSLocalizedString(@"Route", nil)];
        [RouteNavigateButton addTarget:self action:@selector(RouteNavigateButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [ScrollView addSubview:RouteNavigateButton];
        
        //設定ScrollView內容大小
        ScrollView.contentSize = CGSizeMake(self.view.frame.size.width, ShowInMapButton.frame.origin.y+ShowInMapButton.frame.size.height+10);
        
        //設定白線
        WhiteLineTop = [[UIView alloc] initWithFrame:CGRectMake(20, 45, self.view.bounds.size.width-40, 1.5)];
        WhiteLineTop.backgroundColor = [theColor WhiteLine];
        [ScrollView addSubview:WhiteLineTop];
        
        WhiteLineMiddle = [[UIView alloc] initWithFrame:CGRectMake(20, 315, self.view.bounds.size.width-40, 1.5)];
        WhiteLineMiddle.backgroundColor = [theColor WhiteLine];
        [ScrollView addSubview:WhiteLineMiddle];
        
        WhiteLineButton = [[UIView alloc] initWithFrame:CGRectMake(20, 390, self.view.bounds.size.width-40, 1.5)];
        WhiteLineButton.backgroundColor = [theColor WhiteLine];
        [ScrollView addSubview:WhiteLineButton];
        
        //設定地圖
        MapView = [[MKMapView alloc] initWithFrame:CGRectMake(20, 50, 280, 260)];
        MapView.delegate = self;
        MapView.showsUserLocation = YES;
        MapView.mapType = MKMapTypeStandard;
        MapView.scrollEnabled = YES;
        MapView.zoomEnabled = YES;
        [ScrollView addSubview:MapView];
        [MapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]), MKCoordinateSpanMake(0.004, 0.004))];
        MapPin *StationPin = [[MapPin alloc] initWithCoordinate:CLLocationCoordinate2DMake([[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue])];
        StationPin.title = [YouBikeData objectForKey:@"StopName"];
        StationPin.subtitle = [YouBikeData objectForKey:@"Address"];
        [MapView addAnnotation:StationPin];
        
        [self ShowData];
        
    }else{
        UILabel *InternetFailLbael = [UILabel new];
        InternetFailLbael.textAlignment = UITextAlignmentCenter;
        InternetFailLbael.text = NSLocalizedString(@"CheckInternet", nil);
        InternetFailLbael.font = [UIFont systemFontOfSize:20];
        [InternetFailLbael sizeToFit];
        InternetFailLbael.backgroundColor = [UIColor clearColor];
        InternetFailLbael.center = CGPointMake(self.view.bounds.size.width/2, 70);
        [self.view addSubview:InternetFailLbael];
    }
}

-(void)ShowData
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    ScrollView.alpha = 1;
    DataLoadingIndicatorView.alpha = 0;
    DataLoadingLabel.alpha = 0;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - All about button click method

-(void)ShowInMapButtonClick
{
    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"BusShowOnMapInfos", nil),[YouBikeData objectForKey:@"StopName"]];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ShowInMap", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self.view];
    else
        [MapGuideAlertView show];
}

-(void)RouteNavigateButtonClick
{
    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"BusShowRouteInfos", nil),[YouBikeData objectForKey:@"StopName"]];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Route", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self.view];
    else
        [MapGuideAlertView show];
}

#pragma mark All about actionsheet alerview delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *ButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *Title = [actionSheet title];
    if ([Title isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"BusShowOnMapInfos", nil),[YouBikeData objectForKey:@"StopName"]]]) {
        if(buttonIndex == 0){
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%f,%f",[[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }else if (buttonIndex == 1){
            NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f", [[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
                MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",[[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }else{
        if ([ButtonTitle isEqualToString:NSLocalizedString(@"iOSMap", nil)]) {
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, [[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }else if ([ButtonTitle isEqualToString:NSLocalizedString(@"GoogleMap", nil)]){
            NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=walking",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, [[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
                MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, [[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:NSLocalizedString(@"Route", nil)]){
        if (buttonIndex == 1) {
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, [[YouBikeData objectForKey:@"Latitude"] floatValue], [[YouBikeData objectForKey:@"Longitude"] floatValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }
}
@end
