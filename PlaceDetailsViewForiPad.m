//
//  PlaceDetailsViewForiPad.m
//  iMRT Taipei
//
//  Created by Stanley on 2013/11/23.
//
//

#import "PlaceDetailsViewForiPad.h"
#import "theColor.h"
#import "MapPin.h"
#define KGOOGLE_API_KEY @"AIzaSyD_tisamtW-bgF19T4iHPP4yfp5dLfrIlI"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#import "theCheckInternet.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlaceDetailsViewForiPad
@synthesize PlaceReference,PlaceExit;

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
        PowerByGoogleLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white@2x.png"]];
        PowerByGoogleLogo.frame = CGRectMake(self.frame.size.width/2-52, DataLoadingLabel.center.y+15, 104, 16);
        [self addSubview:PowerByGoogleLogo];
        //設定結果元件
        ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        ScrollView.backgroundColor = [UIColor clearColor];
        ScrollView.contentSize = CGSizeMake(self.frame.size.width, 481);
        [self addSubview:ScrollView];
        
        WhiteLineTop = [[UIView alloc] initWithFrame:CGRectMake(20, 45, self.bounds.size.width-40, 1.5)];
        WhiteLineTop.backgroundColor = [theColor WhiteLine];
        WhiteLineTop.alpha = 0;
        [ScrollView addSubview:WhiteLineTop];
        
        WhiteLineMiddle = [[UIView alloc] initWithFrame:CGRectMake(20, 315, self.bounds.size.width-40, 1.5)];
        WhiteLineMiddle.backgroundColor = [theColor WhiteLine];
        WhiteLineMiddle.alpha = 0;
        [ScrollView addSubview:WhiteLineMiddle];
        
        WhiteLineButton = [[UIView alloc] initWithFrame:CGRectMake(20, 390, self.bounds.size.width-40, 1.5)];
        WhiteLineButton.backgroundColor = [theColor WhiteLine];
        WhiteLineButton.alpha = 0;
        [ScrollView addSubview:WhiteLineButton];
        
        PlaceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
        PlaceNameLabel.backgroundColor = [UIColor clearColor];
        PlaceNameLabel.font = [UIFont systemFontOfSize:20];
        PlaceNameLabel.textColor = [UIColor blackColor];
        PlaceNameLabel.alpha = 0;
        [ScrollView addSubview:PlaceNameLabel];
        
        PlaceAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 320, 20, 15)];
        PlaceAddressLabel.backgroundColor = [UIColor clearColor];
        PlaceAddressLabel.font = [UIFont systemFontOfSize:15];
        PlaceAddressLabel.textColor = [UIColor blackColor];
        PlaceAddressLabel.alpha = 0;
        [ScrollView addSubview:PlaceAddressLabel];
        
        PlaceExitNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 345, 20, 15)];
        PlaceExitNameLabel.backgroundColor = [UIColor clearColor];
        PlaceExitNameLabel.font = [UIFont systemFontOfSize:15];
        PlaceExitNameLabel.textColor = [UIColor blackColor];
        PlaceExitNameLabel.text = PlaceExit;
        [PlaceExitNameLabel sizeToFit];
        PlaceExitNameLabel.alpha = 0;
        [ScrollView addSubview:PlaceExitNameLabel];
        
        PlaceOpenNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 370, 20, 15)];
        PlaceOpenNowLabel.backgroundColor = [UIColor clearColor];
        PlaceOpenNowLabel.font = [UIFont systemFontOfSize:15];
        PlaceOpenNowLabel.textColor = [UIColor blackColor];
        PlaceOpenNowLabel.text = PlaceExit;
        PlaceOpenNowLabel.alpha = 0;
        [ScrollView addSubview:PlaceOpenNowLabel];
        
        GoogleSearchButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2-103, 395, 98, 33) AndButtonText:NSLocalizedString(@"Google", nil)];
        [GoogleSearchButton addTarget:self action:@selector(GoogleSearchButtonClick) forControlEvents:UIControlEventTouchUpInside];
        GoogleSearchButton.alpha = 0;
        [ScrollView addSubview:GoogleSearchButton];
        
        RouteNavigateButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2+5, 395, 98, 33) AndButtonText:NSLocalizedString(@"Route", nil)];
        [RouteNavigateButton addTarget:self action:@selector(RouteNavigateButtonClick) forControlEvents:UIControlEventTouchUpInside];
        RouteNavigateButton.alpha = 0;;
        [ScrollView addSubview:RouteNavigateButton];
        
        CallNumberButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2-103, 438, 98, 33) AndButtonText:NSLocalizedString(@"Call", nil)];
        [CallNumberButton addTarget:self action:@selector(CallNumberButtonClick) forControlEvents:UIControlEventTouchUpInside];
        CallNumberButton.alpha = 0;
        [ScrollView addSubview:CallNumberButton];
        
        OfficeWebsiteButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2+5, 438, 98, 33) AndButtonText:NSLocalizedString(@"Website", nil)];
        [OfficeWebsiteButton addTarget:self action:@selector(PlaceWebsiteButtonClick) forControlEvents:UIControlEventTouchUpInside];
        OfficeWebsiteButton.alpha = 0;
        [ScrollView addSubview:OfficeWebsiteButton];
        
        MapView = [[MKMapView alloc] initWithFrame:CGRectMake(20, 50, 280, 260)];
        MapView.delegate = self;
        MapView.showsUserLocation = YES;
        MapView.mapType = MKMapTypeStandard;
        MapView.scrollEnabled = YES;
        MapView.zoomEnabled = YES;
        MapView.alpha = 0;
        [ScrollView addSubview:MapView];
        //google查詢
        [self queryGooglePlaces];
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

#pragma mark - NSURLConnection delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    GoogleData = [NSMutableData new];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [GoogleData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UILabel *InternetFailLabel = [UILabel new];
    InternetFailLabel.textAlignment = UITextAlignmentCenter;
    InternetFailLabel.text = NSLocalizedString(@"FailToConnect", nil);
    InternetFailLabel.font = [UIFont systemFontOfSize:15];
    [InternetFailLabel sizeToFit];
    InternetFailLabel.backgroundColor = [UIColor clearColor];
    InternetFailLabel.center = CGPointMake(self.bounds.size.width/2, 70);
    InternetFailLabel.alpha = 0;
    [self addSubview:InternetFailLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    DataLoadingLabel.alpha = 0;
    DataLoadingIndicatorView.alpha = 0;
    PowerByGoogleLogo.alpha = 0;
    InternetFailLabel.alpha = 1;
    [UIView commitAnimations];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(kBgQueue, ^{
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:GoogleData waitUntilDone:YES];
    });
}

#pragma mark All about google place api

-(void) queryGooglePlaces
{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", PlaceReference, KGOOGLE_API_KEY];
    //Formulate the string as a URL object.
    //NSLog(@"%@",url);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:googleRequestURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    NSURLConnection *Connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
    [Connection start];
    // Retrieve the results of the URL.
    /*dispatch_async(kBgQueue, ^{
     NSData* data = [NSData dataWithContentsOfURL:googleRequestURL];
     [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
     });*/
}

-(void)fetchedData:(NSData *)responseData
{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSDictionary* places = [json objectForKey:@"result"];
    //Write out the data to the console.
    [self plotPositions:places];
}

-(void)plotPositions:(NSDictionary *)data
{
    //地點名稱
    NSString *name=[data objectForKey:@"name"];
    PlaceNameLabel.text = name;
    [PlaceNameLabel sizeToFit];
    //地點地址
    NSString *Address = [data objectForKey:@"formatted_address"];
    PlaceAddressLabel.text = Address;
    [PlaceAddressLabel sizeToFit];
    if (PlaceAddressLabel.frame.size.width > self.frame.size.width-40){
        PlaceAddressLabel.frame = CGRectMake(PlaceAddressLabel.frame.origin.x, PlaceAddressLabel.frame.origin.y, self.frame.size.width-40, PlaceAddressLabel.frame.size.height);
        PlaceAddressLabel.adjustsFontSizeToFitWidth = YES;
    }
    //電話
    PlacePhoneNumber = [data objectForKey:@"formatted_phone_number"];
    //網站
    PlaceWebsite = [data objectForKey:@"website"];
    //營業時間
    NSDictionary *OpeningHours = [data objectForKey:@"opening_hours"];
    PlaceOpenNow = [OpeningHours objectForKey:@"open_now"];
    if (!PlaceOpenNow) {
        PlaceOpenNowLabel.text = NSLocalizedString(@"Close", nil);
        NSDate *now = [NSDate date];
        NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
        [weekday setDateFormat: @"EEEE"];
        NSDictionary *WeekDayNumber = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6", nil] forKeys:[NSArray arrayWithObjects:@"Sunday",@"Monday",@"Tuesday", @"Wednesday", @"Thursday", @"Friday" ,@"Saturday",nil]];
        NSArray *OpenPeriods = [OpeningHours objectForKey:@"periods"];
        PlaceOpenNowLabel.text = [PlaceOpenNowLabel.text stringByAppendingFormat:NSLocalizedString(@"TodayOpenHour", nil),[[[OpenPeriods objectAtIndex:[[WeekDayNumber objectForKey:[weekday stringFromDate:now]] intValue]] objectForKey:@"open"] objectForKey:@"time"],[[[OpenPeriods objectAtIndex:[[WeekDayNumber objectForKey:[weekday stringFromDate:now]] intValue]] objectForKey:@"close"] objectForKey:@"time"]];
        [PlaceOpenNowLabel sizeToFit];
    }else if (PlaceOpenNow){
        PlaceOpenNowLabel.text = NSLocalizedString(@"Open", nil);
        NSDate *now = [NSDate date];
        NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
        [weekday setDateFormat: @"EEEE"];
        NSDictionary *WeekDayNumber = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6", nil] forKeys:[NSArray arrayWithObjects:@"Sunday",@"Monday",@"Tuesday", @"Wednesday", @"Thursday", @"Friday" ,@"Saturday",nil]];
        NSArray *OpenPeriods = [OpeningHours objectForKey:@"periods"];
        PlaceOpenNowLabel.text = [PlaceOpenNowLabel.text stringByAppendingFormat:NSLocalizedString(@"TodayOpenHour", nil),[[[OpenPeriods objectAtIndex:[[WeekDayNumber objectForKey:[weekday stringFromDate:now]] intValue]] objectForKey:@"open"] objectForKey:@"time"],[[[OpenPeriods objectAtIndex:[[WeekDayNumber objectForKey:[weekday stringFromDate:now]] intValue]] objectForKey:@"close"] objectForKey:@"time"]];
        [PlaceOpenNowLabel sizeToFit];
    }
    //地點坐標
    NSDictionary *geo = [data objectForKey:@"geometry"];
    NSDictionary *loc = [geo objectForKey:@"location"];
    placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
    placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
    [MapView setRegion:MKCoordinateRegionMake(placeCoord, MKCoordinateSpanMake(0.004, 0.004))];
    MapPin *StationPin = [[MapPin alloc] initWithCoordinate:placeCoord];
    StationPin.title = name;
    StationPin.subtitle = Address;
    [MapView addAnnotation:StationPin];
    // Storage place reference
    [self ShowResults];
}

-(void)ShowResults
{
    LocationManager = [[CLLocationManager alloc] init];
    [LocationManager setDelegate:self];
    [LocationManager setDistanceFilter:kCLDistanceFilterNone];
    [LocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    DataLoadingIndicatorView.alpha = 0;
    DataLoadingLabel.alpha = 0;
    PowerByGoogleLogo.alpha = 0;
    PlaceNameLabel.alpha = 1;
    PlaceAddressLabel.alpha = 1;
    PlaceExitNameLabel.alpha = 1;
    GoogleSearchButton.alpha = 1;
    RouteNavigateButton.alpha = 1;
    if ([PlacePhoneNumber length])
        CallNumberButton.alpha = 1;
    if ([PlaceWebsite length])
        OfficeWebsiteButton.alpha = 1;
    if (PlaceOpenNow)
        PlaceOpenNowLabel.alpha = 1;
    MapView.alpha = 1;
    WhiteLineTop.alpha = 1;
    WhiteLineMiddle.alpha = 1;
    WhiteLineButton.alpha = 1;
    [UIView commitAnimations];
}

#pragma mark All about button method

-(void)GoogleSearchButtonClick
{
    NSString *URLString = [[NSString alloc] initWithFormat:@"http://www.google.com.tw/search?q=%@",PlaceNameLabel.text];
    NSString *URLStringUTF8 = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLStringUTF8]];
}

-(void)RouteNavigateButtonClick
{
    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"ShowRouteInfos", nil),PlaceNameLabel.text];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Route", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self.superview];
    else
        [MapGuideAlertView show];
}

-(void)CallNumberButtonClick
{
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"CallInfos", nil),PlaceNameLabel.text];
    UIAlertView  *CallPhoneAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Call", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"MakePhoneCall", nil), nil];
    [CallPhoneAlertView show];
}

-(void)PlaceWebsiteButtonClick
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PlaceWebsite]];
}


#pragma mark All about actionsheet alerview delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *Title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([Title isEqualToString:NSLocalizedString(@"iOSMap", nil)]) {
        NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, placeCoord.latitude, placeCoord.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
    }else if ([Title isEqualToString:NSLocalizedString(@"GoogleMap", nil)]){
        NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=walking",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, placeCoord.latitude, placeCoord.longitude];
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
            MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, placeCoord.latitude, placeCoord.longitude];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"Call", nil)]) {
        PlacePhoneNumber = [NSString stringWithFormat:@"tel://%@",[PlacePhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]];
        if (buttonIndex == 1)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PlacePhoneNumber]];
    }else if([alertView.title isEqualToString:NSLocalizedString(@"Route", nil)]){
        if (buttonIndex == 1) {
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, placeCoord.latitude, placeCoord.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }
}

@end
