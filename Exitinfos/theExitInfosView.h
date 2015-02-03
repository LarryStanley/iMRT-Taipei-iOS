//
//  theExitInfosView.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/29.
//
//

#import <UIKit/UIKit.h>
#import "WhiteSearchBarInterface.h"
#import <MapKit/MapKit.h>
#import "theOnlyTextLabel.h"

@class theExitInfosView;

@protocol theShowPlaceDetailsDelegate <NSObject>
-(void)ShowPlaceDetails:(theExitInfosView*)theExit;
@end

@protocol removePlaceDetailViewDelegate <NSObject>
-(void)RemovePlaceDetailViewDelegate:(theExitInfosView*)theExit;
@end

@interface theExitInfosView : UIView <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>
{
    UISearchBar *PlaceSearchBar;
    UITableView *PlaceResultTable,*CategoryTable;
    UIView *GrayView;
    UISwipeGestureRecognizer *RightSwipeRecognizer,*LeftSwipeRecognizer;
    UITapGestureRecognizer *TapRecognizer,*TapRecognizerForSearchBar;
    UIActivityIndicatorView *DataLoadingIndicatorView;
    UILabel *DataLoadingLabel,*EmptyDataLabel;
    UIImageView *PowerByGoogleLogo;
    CGPoint StationCoordinate;
    NSMutableArray *PlaceResults,*ExitData,*PlaceExitResults,*PlaceReferences;
    NSString *PlaceReference,*PlaceExit;
    id<theShowPlaceDetailsDelegate>_ShowPlaceDetailsDelegate;
    id<removePlaceDetailViewDelegate>_removePlaceDetailDelegate;
    NSMutableData* GoogleData;
    CGRect SelectedRowPosition;
}

@property (nonatomic,assign) id<theShowPlaceDetailsDelegate> ShowPlaceDetailsDelegate;
@property (nonatomic,assign) id<removePlaceDetailViewDelegate> removePlaceDetailDelegate;
@property (nonatomic,strong) NSString *PlaceReference;
@property (nonatomic,strong) NSString *PlaceExit;
@property (nonatomic,strong) UITableView *PlaceResultTable;

@property  CGRect SelectedRowPosition;
@property  BOOL ExitInfosSwiping;

- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)StationNumber;
-(void)RightSwipe;
-(void)LeftSwipe;
-(void)queryGooglePlaces:(NSString *)googleType AndSearchType:(NSString *)SearchType;
-(void)fetchedData:(NSData *)responseData;
-(void)plotPositions:(NSArray *)data;
-(NSString *)SearchClosestExit:(CLLocationCoordinate2D)PlaceCoordinate;
-(void)HideKeyboard;
@end
