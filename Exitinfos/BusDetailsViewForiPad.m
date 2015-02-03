//
//  BusDetailsViewForiPad.m
//  iMRT Taipei
//
//  Created by Stanley on 2013/11/25.
//
//

#import "BusDetailsViewForiPad.h"
#import "theColor.h"
#import "theCheckInternet.h"
#import "theSQLite.h"

@implementation BusDetailsViewForiPad
@synthesize BusName,StopName,Destination,StopCoordinate,StationName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [theColor WhiteBackground];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    theCheckInternet *CheckInternet = [theCheckInternet new];
    if ([CheckInternet isConnectionAvailable]) {
        //設定資料載入中元素
        DataLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [DataLoadingIndicatorView startAnimating];
        DataLoadingIndicatorView.center = CGPointMake(self.frame.size.width/2, 60);
        [self addSubview:DataLoadingIndicatorView];
        DataLoadingLabel = [UILabel new];
        DataLoadingLabel.text = NSLocalizedString(@"Loading", nil);
        DataLoadingLabel.font = [UIFont systemFontOfSize:15];
        DataLoadingLabel.backgroundColor = [UIColor clearColor];
        DataLoadingLabel.textAlignment = UITextAlignmentCenter;
        [DataLoadingLabel sizeToFit];
        DataLoadingLabel.center = CGPointMake(self.frame.size.width/2, DataLoadingIndicatorView.center.y+25);
        [self addSubview:DataLoadingLabel];
        //查詢公車路線圖
        theSQLite *SQLite = [theSQLite new];
        NSMutableArray *BusData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from MRTBusRoute where BusName = '%@' and Direction = 0",BusName] andIndexOFColumn:CGPointMake(0, 3)];
        //設定資料元件
        ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        ScrollView.backgroundColor = [UIColor clearColor];
        if (BusData && ![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"])
            ScrollView.contentSize = CGSizeMake(self.frame.size.width, 468+([BusData count]-1)*40);
        else
            ScrollView.contentSize = CGSizeMake(self.frame.size.width, 418);
        
        [self addSubview:ScrollView];
        
        //設定公車路線圖
        if (BusData && ![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"]) {
            BusMap = [[theBusMap alloc] initWithFrame:CGRectMake(0, 408, self.frame.size.width, 60+([BusData count]-1)*40) AndRouteData:BusData AndCurrentStopName:[[StopName componentsSeparatedByString:@" "] objectAtIndex:1]];
            BusMap.alpha = 0;
            [ScrollView addSubview:BusMap];
        }
        
        //設定結果標簽
        BusNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
        BusNameLabel.backgroundColor = [UIColor clearColor];
        BusNameLabel.font = [UIFont systemFontOfSize:20];
        BusNameLabel.textColor = [UIColor blackColor];
        BusNameLabel.alpha = 0;
        [ScrollView addSubview:BusNameLabel];
        
        StopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 320, 20, 15)];
        StopNameLabel.backgroundColor = [UIColor clearColor];
        StopNameLabel.font = [UIFont systemFontOfSize:15];
        StopNameLabel.textColor = [UIColor blackColor];
        StopNameLabel.alpha = 0;
        [ScrollView addSubview:StopNameLabel];
        
        BusExitLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 345, 20, 15)];
        BusExitLabel.backgroundColor = [UIColor clearColor];
        BusExitLabel.font = [UIFont systemFontOfSize:15];
        BusExitLabel.textColor = [UIColor blackColor];
        BusExitLabel.alpha = 0;
        [ScrollView addSubview:BusExitLabel];
        
        //設定按鈕
        ShowInMapButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2-103, 370, 98, 33) AndButtonText:NSLocalizedString(@"ShowInMap", nil)];
        [ShowInMapButton addTarget:self action:@selector(ShowInMapButtonClick) forControlEvents:UIControlEventTouchUpInside];
        ShowInMapButton.alpha = 0;;
        [ScrollView addSubview:ShowInMapButton];
        
        RouteNavigateButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2+5, 370, 98, 33) AndButtonText:NSLocalizedString(@"Route", nil)];
        [RouteNavigateButton addTarget:self action:@selector(RouteNavigateButtonClick) forControlEvents:UIControlEventTouchUpInside];
        RouteNavigateButton.alpha = 0;;
        [ScrollView addSubview:RouteNavigateButton];
        
        //設定白線
        WhiteLineTop = [[UIView alloc] initWithFrame:CGRectMake(20, 45, self.bounds.size.width-40, 1.5)];
        WhiteLineTop.backgroundColor = [theColor WhiteLine];
        WhiteLineTop.alpha = 0;
        [ScrollView addSubview:WhiteLineTop];
        
        WhiteLineMiddle = [[UIView alloc] initWithFrame:CGRectMake(20, 315, self.bounds.size.width-40, 1.5)];
        WhiteLineMiddle.backgroundColor = [theColor WhiteLine];
        WhiteLineMiddle.alpha = 0;
        [ScrollView addSubview:WhiteLineMiddle];
        
        WhiteLineButton = [[UIView alloc] initWithFrame:CGRectMake(20, 365, self.bounds.size.width-40, 1.5)];
        WhiteLineButton.backgroundColor = [theColor WhiteLine];
        WhiteLineButton.alpha = 0;
        [ScrollView addSubview:WhiteLineButton];
        
        //設定地圖
        MapView = [[MKMapView alloc] initWithFrame:CGRectMake(20, 50, 280, 260)];
        MapView.delegate = self;
        MapView.showsUserLocation = YES;
        MapView.mapType = MKMapTypeStandard;
        MapView.scrollEnabled = YES;
        MapView.zoomEnabled = YES;
        MapView.alpha = 0;
        [ScrollView addSubview:MapView];
        [self GetDetails];
    }else{
        UILabel *InternetFailLbael = [UILabel new];
        InternetFailLbael.textAlignment = UITextAlignmentCenter;
        InternetFailLbael.text = NSLocalizedString(@"CheckInternet", nil);
        InternetFailLbael.font = [UIFont systemFontOfSize:20];
        [InternetFailLbael sizeToFit];
        InternetFailLbael.backgroundColor = [UIColor clearColor];
        InternetFailLbael.center = CGPointMake(self.bounds.size.width/2, 70);
        [self addSubview:InternetFailLbael];
    }
}

-(void)GetDetails
{
    BusNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BusTo", nil),BusName,Destination];
    [BusNameLabel sizeToFit];
    
    NSString *ExitName = [[StopName componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSString *RealStopName = [[StopName componentsSeparatedByString:@" "] objectAtIndex:1];
    
    [MapView setRegion:MKCoordinateRegionMake(StopCoordinate.coordinate, MKCoordinateSpanMake(0.004, 0.004))];
    MapPin *StationPin = [[MapPin alloc] initWithCoordinate:StopCoordinate.coordinate];
    StationPin.title = BusName;
    StationPin.subtitle = RealStopName;
    [MapView addAnnotation:StationPin];
    
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"]) {
        StopNameLabel.text = StationName;
        [StopNameLabel sizeToFit];
        
        BusExitLabel.text = StopName;
        [BusExitLabel sizeToFit];
        
    }else{
        StopNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BusStopName", nil),RealStopName];
        [StopNameLabel sizeToFit];
        
        BusExitLabel.text = [NSString stringWithFormat:@"%@ %@",StationName,ExitName];
        [BusExitLabel sizeToFit];
    }
    [self ShowDetailsData];
}

-(void)ShowDetailsData
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    DataLoadingIndicatorView.alpha = 0;
    DataLoadingLabel.alpha = 0;
    BusNameLabel.alpha = 1;
    StopNameLabel.alpha = 1;
    BusExitLabel.alpha = 1;
    ShowInMapButton.alpha = 1;
    RouteNavigateButton.alpha = 1;
    WhiteLineTop.alpha = 1;
    WhiteLineMiddle.alpha = 1;
    WhiteLineButton.alpha = 1;
    BusMap.alpha = 1;
    MapView.alpha = 1;
    [UIView commitAnimations];
}

#pragma mark - All about button click method

-(void)ShowInMapButtonClick
{
    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"BusShowOnMapInfos", nil),[[StopName componentsSeparatedByString:@" "] objectAtIndex:1]];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ShowInMap", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self.superview];
    else
        [MapGuideAlertView show];
}

-(void)RouteNavigateButtonClick
{
    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"BusShowRouteInfos", nil),[[StopName componentsSeparatedByString:@" "] objectAtIndex:1]];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Route", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self.superview];
    else
        [MapGuideAlertView show];
}

#pragma mark All about actionsheet alerview delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *ButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *Title = [actionSheet title];
    if ([Title isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"BusShowOnMapInfos", nil),[[StopName componentsSeparatedByString:@" "] objectAtIndex:1]]]) {
        if(buttonIndex == 0){
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%f,%f",StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }else if (buttonIndex == 1){
            NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f", StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
                MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }else{
        if ([ButtonTitle isEqualToString:NSLocalizedString(@"iOSMap", nil)]) {
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }else if ([ButtonTitle isEqualToString:NSLocalizedString(@"GoogleMap", nil)]){
            NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=walking",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
                MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:NSLocalizedString(@"Route", nil)]){
        if (buttonIndex == 1) {
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",MapView.userLocation.location.coordinate.latitude, MapView.userLocation.location.coordinate.longitude, StopCoordinate.coordinate.latitude, StopCoordinate.coordinate.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }
}


@end
