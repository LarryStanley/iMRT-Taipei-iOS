//
//  YouBikeViewController.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/8/4.
//
//

#import <UIKit/UIKit.h>
#import "theGrayButton.h"
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "theOnlyTextLabel.h"

@interface YouBikeViewController : UIViewController <MKMapViewDelegate,UIActionSheetDelegate>
{
    UIActivityIndicatorView *DataLoadingIndicatorView;
    UILabel *DataLoadingLabel;
    theGrayButton *ShowInMapButton,*RouteNavigateButton;
    UIScrollView *ScrollView;
    UIView *WhiteLineTop,*WhiteLineMiddle,*WhiteLineButton;
    MKMapView *MapView;
    theOnlyTextLabel *StopNameLable,*AddressLable,*CountOfBikeLable,*ExitNameLable;
    NSString *StopName,*MRTStationName,*ExitName;
    NSDictionary *YouBikeData;
}

@property (nonatomic,strong) NSString *StopName;
@property (nonatomic,strong) NSString *MRTStationName;
@property (nonatomic,strong) NSString *ExitName;

-(void)ShowData;
-(void)ShowInMapButtonClick;
-(void)RouteNavigateButtonClick;

@end
