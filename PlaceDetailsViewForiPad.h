//
//  PlaceDetailsViewForiPad.h
//  iMRT Taipei
//
//  Created by Stanley on 2013/11/23.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "theGrayButton.h"

@interface PlaceDetailsViewForiPad : UIView<MKMapViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>
{
    CLLocationManager *LocationManager;
    CLLocationCoordinate2D placeCoord;
    UIScrollView *ScrollView;
    MKMapView *MapView;
    UIView *WhiteLineTop,*WhiteLineMiddle,*WhiteLineButton;
    NSString *PlaceReference,*PlaceExit,*PlacePhoneNumber,*PlaceWebsite,*PlaceOpenNow;
    UILabel *DataLoadingLabel,*PlaceNameLabel,*PlaceAddressLabel,*PlaceExitNameLabel,*PlaceOpenNowLabel;
    theGrayButton *GoogleSearchButton,*RouteNavigateButton,*CallNumberButton,*OfficeWebsiteButton;
    UIImageView *PowerByGoogleLogo;
    UIActivityIndicatorView *DataLoadingIndicatorView;
    NSMutableData *GoogleData;
}

@property (nonatomic,strong) NSString *PlaceReference;
@property (nonatomic,strong) NSString *PlaceExit;

-(void)queryGooglePlaces;
-(void)fetchedData:(NSData *)responseData;
-(void)plotPositions:(NSDictionary *)data;
-(void)ShowResults;
-(void)GoogleSearchButtonClick;
-(void)RouteNavigateButtonClick;
-(void)CallNumberButtonClick;
-(void)PlaceWebsiteButtonClick;


@end
