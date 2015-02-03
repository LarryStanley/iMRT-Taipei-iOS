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

@interface MainViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MRTMapShowFunctionDelegate,MRTMapDismissFunctionDelegate,StationFunctionViewShowMoreDelegate,ChangeStatusBarColorDelegate,theShowPlaceDetailsDelegate,SetExitInfoDelegate,theShowCurrentLocationDelegate,theLocationSearchFailDelegate,UIActionSheetDelegate,theShowBusDetailsDelegate,theShowYouBikeDataDelegate,SetTransferViewDelegate,UIAlertViewDelegate,QueryGooglePlaceDelegate,theLocationCoordinateDelegate>{
    UITableView *StationSearchTableView;
    NSMutableArray *SearchResults,*SearchResultsStationNumber;
    NSMutableArray *MRTList;
    theSQLite *SQLite;
    UIView *GrayView;
    UITapGestureRecognizer *TapGestureRecognizer;
    MRTMap *Map;
    theIllustration *Illustration;
    StationFunctionView *FunctionView;
    BOOL FunctionViewIsShow,Scrolling;
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
    UIView *StatusBarBackgroundView;
    int StatusBarHeight;
}

@property (strong, nonatomic) UISearchBar *TopSearchBar;
@property (weak, nonatomic) IBOutlet UIScrollView *MRTMapScrollView;
@property (strong, nonatomic) UIButton *LocationButton;

#pragma mark - Top search bar method

-(void)SearchMRT;
-(void)keyboardWillShow:(NSNotification*)notification;

#pragma mark - Animation method

-(void)AddStationSearchTableView;
-(void)DismissStationSearchTableview;
-(void)HideKeyboard;
-(void)DoubleTapZoom:(UIGestureRecognizer *)gestureRecognizer;

#pragma mark - All about button method

-(void)LocationButtonClick;

#pragma mark - All about color

-(UIColor*)RGBColor:(NSString *)ColorName;

@end