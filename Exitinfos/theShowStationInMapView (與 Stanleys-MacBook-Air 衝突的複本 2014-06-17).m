//
//  theShowStationInMapView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/27.
//
//

#import "theShowStationInMapView.h"
#import "theSQLite.h"
#import "MapPin.h"
#import "UIImage+Resize.h"
#import "theColor.h"

@implementation theShowStationInMapView

- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)Number
{
    self = [super initWithFrame:frame];
    if (self) {
        StationNumber = Number;
        self.backgroundColor = [UIColor clearColor];
        MapLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [MapLoadingIndicator startAnimating];
        MapLoadingIndicator.center = CGPointMake(self.bounds.size.width/2, 50);
        [self addSubview:MapLoadingIndicator];
        MapLoadingLabel = [UILabel new];
        MapLoadingLabel.text = NSLocalizedString(@"Loading", nil);
        MapLoadingLabel.font = [UIFont systemFontOfSize:15];
        MapLoadingLabel.backgroundColor = [UIColor clearColor];
        MapLoadingLabel.textAlignment = UITextAlignmentCenter;
        [MapLoadingLabel sizeToFit];
        MapLoadingLabel.center = CGPointMake(self.bounds.size.width/2, MapLoadingIndicator.center.y+25);
        [self addSubview:MapLoadingLabel];
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(ShowMap) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

-(void)ShowMap
{
    //查詢該捷運站資料
    theSQLite *SQLite = [theSQLite new];
    StationData = [SQLite ReturnSingleRow:[NSString stringWithFormat:@"select * from StationDataForStanley where StationNumber = %i",StationNumber]];
    NSMutableArray *ExitData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from ExitInfos where StationNumber = %i",StationNumber] andIndexOFColumn:CGPointMake(0, 5)];
    //設定地圖位置等設定
    StationMap = [[MKMapView alloc] initWithFrame:CGRectMake(20, 20, 280, 260)];
    StationMap.delegate = self;
    StationMap.showsUserLocation = YES;
    StationMap.mapType = MKMapTypeStandard;
    StationMap.scrollEnabled = YES;
    StationMap.zoomEnabled = YES;
    StationMap.alpha = 0;
    [StationMap setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]), MKCoordinateSpanMake(0.002, 0.002))];
    [self addSubview:StationMap];
    //按鈕設定
    ShowInMapButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-118, 300, 108, 33) AndButtonText:NSLocalizedString(@"ShowInMap", nil)];
    [ShowInMapButton addTarget:self action:@selector(ShowInMapButtonClick) forControlEvents:UIControlEventTouchUpInside];
    ShowInMapButton.alpha = 0;
    [self addSubview:ShowInMapButton];
    RouteNavigateButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2+10, 300, 108, 33) AndButtonText:NSLocalizedString(@"Route", nil)];
    [RouteNavigateButton addTarget:self action:@selector(RouteNavigateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    RouteNavigateButton.alpha = 0;
    [self addSubview:RouteNavigateButton];
    //設定捷運站大頭針
    MapPin *StationPin = [[MapPin alloc] initWithCoordinate:CLLocationCoordinate2DMake([[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue])];
    StationPin.title = NSLocalizedString([StationData objectAtIndex:0], nil);
    if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"])
        StationPin.subtitle = [StationData objectAtIndex:4];
        [StationMap addAnnotation:StationPin];
    for (int i = 0; i < [ExitData count]; i++) {
        MapPin *ExitPin = [[MapPin alloc] initWithCoordinate:CLLocationCoordinate2DMake([[[ExitData objectAtIndex:i] objectAtIndex:3] doubleValue], [[[ExitData objectAtIndex:i] objectAtIndex:4] doubleValue])];
        if (![[[ExitData objectAtIndex:i] objectAtIndex:2] intValue])
            ExitPin.title = NSLocalizedString(@"SingleExit", nil);
        else
            ExitPin.title = [NSString stringWithFormat:NSLocalizedString(@"ExitIndex", nil),[[[ExitData objectAtIndex:i] objectAtIndex:2] intValue]];
        if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"])
            ExitPin.subtitle = [[ExitData objectAtIndex:i] objectAtIndex:5];
        [StationMap addAnnotation:ExitPin];
    }
    //載入動畫
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    MapLoadingLabel.alpha = 0;
    [MapLoadingIndicator stopAnimating];
    StationMap.alpha = 1;
    ShowInMapButton.alpha = 1;
    RouteNavigateButton.alpha = 1;
    [UIView commitAnimations];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *PinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    NSString *ExitName;
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"])
        ExitName = @"Exit";
    else
        ExitName = @"出口";
    if ([PinView.annotation.title rangeOfString:ExitName options:NSLiteralSearch].location != NSNotFound)
        PinView.pinColor = MKPinAnnotationColorGreen;
    else
        PinView.pinColor = MKPinAnnotationColorRed;
    PinView.canShowCallout = YES;
    return PinView;
}

#pragma mark All about button method

-(void)ShowInMapButtonClick
{
    LocationManager = [[CLLocationManager alloc] init];
    [LocationManager setDelegate:self];
    [LocationManager setDistanceFilter:kCLDistanceFilterNone];
    [LocationManager setDesiredAccuracy:kCLLocationAccuracyBest];

    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"ShowStationOnMapInfos", nil),[StationData objectAtIndex:1]];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Route", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self];
    else
        [MapGuideAlertView show];
}

-(void)RouteNavigateButtonClick
{
    LocationManager = [[CLLocationManager alloc] init];
    [LocationManager setDelegate:self];
    [LocationManager setDistanceFilter:kCLDistanceFilterNone];
    [LocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    NSString *Version = [[UIDevice currentDevice] systemVersion];
    NSString *AlertViewMessage = [NSString stringWithFormat:NSLocalizedString(@"ShowRouteInfos", nil),[StationData objectAtIndex:1]];
    UIActionSheet *MapGuideOption = [[UIActionSheet alloc] initWithTitle:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"iOSMap", nil),NSLocalizedString(@"GoogleMap", nil), nil];
    UIAlertView *MapGuideAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Route", nil) message:AlertViewMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ToMap", nil), nil];
    if ([Version intValue] >= 6)
        [MapGuideOption showInView:self];
    else
        [MapGuideAlertView show];
}

#pragma mark All about ActionSheet AlertView

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *Title = [actionSheet title];
    if ([Title isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"ShowRouteInfos", nil),[StationData objectAtIndex:1]]]){
        if(buttonIndex == 0){
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, [[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }else if (buttonIndex == 1){
            NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=walking",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, [[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
                MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",LocationManager.location.coordinate.latitude, LocationManager.location.coordinate.longitude, [[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }else{
        if(buttonIndex == 0){
            NSString *MapURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%f,%f",[[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }else if (buttonIndex == 1){
            NSString *MapURL = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f", [[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]]) {
                MapURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",[[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MapURL]];
        }
    }
}

@end
