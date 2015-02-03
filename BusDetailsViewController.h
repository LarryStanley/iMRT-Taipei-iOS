//
//  BusDetailsViewController.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/6/6.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "theGrayButton.h"
#import "theBusMap.h"
@interface BusDetailsViewController : UIViewController <MKMapViewDelegate,UIActionSheetDelegate>
{
    NSString *BusName,*StopName,*StationName,*Destination;
    UILabel *DataLoadingLabel,*BusNameLabel,*StopNameLabel,*BusExitLabel;
    UIActivityIndicatorView *DataLoadingIndicatorView;
    UIScrollView *ScrollView;
    UIView *WhiteLineTop,*WhiteLineMiddle,*WhiteLineButton;
    MKMapView *MapView;
    CLLocation *StopCoordinate;
    theGrayButton *RouteNavigateButton,*ShowInMapButton;
    theBusMap *BusMap;
}

@property(strong,nonatomic) NSString *BusName,*StopName,*Destination,*StationName;
@property(strong,nonatomic) CLLocation *StopCoordinate;

-(void)GetDetails;
-(void)ShowDetailsData;
-(void)RouteNavigateButtonClick;
-(void)ShowInMapButtonClick;

@end
