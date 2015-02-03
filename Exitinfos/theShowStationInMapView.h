//
//  theShowStationInMapView.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/27.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "theGrayButton.h"

@interface theShowStationInMapView : UIView <MKMapViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>
{
    MKMapView *StationMap;
    CLLocationManager *LocationManager;
    UIActivityIndicatorView *MapLoadingIndicator;
    UILabel *MapLoadingLabel;
    theGrayButton *ShowInMapButton,*RouteNavigateButton;
    int StationNumber;
    NSMutableArray *StationData;
}

- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)Number;
- (void)ShowMap;
- (void)ShowInMapButtonClick;
- (void)RouteNavigateButtonClick;
@end
