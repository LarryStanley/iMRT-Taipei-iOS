//
//  MainViewController.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/5.
//
//

#import <UIKit/UIKit.h>
#import "WhiteSearchBarInterface.h"
#import "theSQLite.h"
#import "MRTMap.h"
#import "theIllustration.h"
#import "StationFunctionView.h"
#import "theCurrentLocation.h"
#import "theExitInfosView.h"
#import "theOnlyTextLabel.h"
#import "theQueryDataFromGoogle.h"
#import "theOnlyTextLabel.h"
#import "PlaceDetailsViewForiPad.h"
#import "BusDetailsViewForiPad.h"
#import "theLeftArrow.h"

@interface MainViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MRTMapShowFunctionDelegate,MRTMapDismissFunctionDelegate,StationFunctionViewShowMoreDelegate,ChangeStatusBarColorDelegate,theShowPlaceDetailsDelegate,removePlaceDetailViewDelegate,SetExitInfoDelegate,theShowCurrentLocationDelegate,theLocationSearchFailDelegate,UIActionSheetDelegate,theShowBusDetailsDelegate,theShowYouBikeDataDelegate,SetTransferViewDelegate,UIAlertViewDelegate,QueryGooglePlaceDelegate,theLocationCoordinateDelegate,MoveMRTScrollViewLayerDelegate>{
    UITableView *StationSearchTableView;
    NSMutableArray *SearchResults,*SearchResultsStationNumber;
    NSMutableArray *MRTList;
    theSQLite *SQLite;
    UIView *GrayView;
    UITapGestureRecognizer *TapGestureRecognizer;
    MRTMap *Map;
    theIllustration *Illustration;
    StationFunctionView *FunctionView;
    BOOL FunctionViewIsShow,ScrollViewDecelerating;
    theCurrentLocation *CurrentLocation;
    UIButton *LocationButton;
    theOnlyTextLabel *UpIllustration;
    int ArrowAnimationTimes;
    theQueryDataFromGoogle *QueryFromGoogle;
    NSString *SearchType,*SearchBarText;
    CGRect KeyboardRect;
    theOnlyTextLabel *DataLoadingLabel,*InternetFailLabel,*NoDataLable;
    UIActivityIndicatorView *DataLoadingIndicatorView;
    UIImageView *PowerByGoogleLogo;
    UIView *StatusBarBackgroundView,*StatusBarForiPad,*DetectTapView;
    int StatusBarHeight;
    //For iPad
    PlaceDetailsViewForiPad *PlaceDetailsViewiPad;
    BusDetailsViewForiPad *BusDetailsViewiPad;
    theLeftArrow *ArrowView;
}

@property (strong, nonatomic) UISearchBar *TopSearchBar;
@property (weak, nonatomic) IBOutlet UIScrollView *MRTMapScrollView;
@property (strong, nonatomic) IBOutlet UIButton *LocationButton;

#pragma mark - Top search bar method

-(void)SearchMRT;
-(void)keyboardWillShow:(NSNotification*)notification;

#pragma mark - Animation method

-(void)AddStationSearchTableView;
-(void)DismissStationSearchTableview;
-(void)HideKeyboard;
-(void)DoubleTapZoom:(UIGestureRecognizer *)gestureRecognizer;

#pragma mark - All about remove detail view (only for iPad)

-(void)removePlaceDetailView;
-(void)removeBusDetailView;

#pragma mark - All about button method

-(void)LocationButtonClick;

#pragma mark - All about color

-(UIColor*)RGBColor:(NSString *)ColorName;

#pragma mark - All about device rotation

- (void)OrientationChanged:(NSNotification *)note;

#pragma mark - All about show function view

- (void)ShowFunctionViewIllustration;

@end