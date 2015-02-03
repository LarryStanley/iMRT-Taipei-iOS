//
//  theTransferView.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/6/1.
//
//

#import <UIKit/UIKit.h>
#import "WhiteSearchBarInterface.h"
#import <MapKit/MapKit.h>
#import "theOnlyTextLabel.h"

@class theTransferView;

@protocol theShowBusDetailsDelegate <NSObject>
-(void)ShowBusDetails:(theTransferView*)theTransfer AndBusData:(NSMutableDictionary *)BusData;
@end

@protocol theShowYouBikeDataDelegate <NSObject>
-(void)ShowYouBikeData:(theTransferView*)theTransfer AndYouBikeData:(NSMutableDictionary *)YouBikeData;
@end



@interface theTransferView : UIView <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    UITableView *TransitResultsTable,*CategoryTable;
    UISearchBar *BusSearchBar;
    NSMutableArray *BusData,*ExitData,*BusSectionData,*SearchResults,*YouBikeTableData,*YouBikeTableSubtitleData,*YouBikeNameData;
    UIActivityIndicatorView *DataLoadingIndicatorView;
    UILabel *DataLoadingLabel;
    theOnlyTextLabel *NoDataLabel;
    UIView *GrayView;
    UITapGestureRecognizer *TapGestureRecognizer;
    id<theShowBusDetailsDelegate>_ShowBusDetailsDelegate;
    id<theShowYouBikeDataDelegate>_ShowYouBikeDataDelegate;
    BOOL Searching;
    UISwipeGestureRecognizer *RightSwipeRecognizer,*LeftSwipeRecognizer;
    UITapGestureRecognizer *TapRecognizerForTableView;
    int StationNumber;
    CGRect SelectedRowPosition;
}

@property (nonatomic,assign) id<theShowBusDetailsDelegate>ShowBusDetailsDelegate;
@property (nonatomic,assign) id<theShowYouBikeDataDelegate>ShowYouBikeDataDelegate;
@property (nonatomic,strong) UITableView *TransitResultsTable;

@property CGRect SelectedRowPosition;


-(void)LoadingBusData;
- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)theStationNumber;
-(NSString *)SearchClosestExit:(CLLocationCoordinate2D)PlaceCoordinate;
-(void)SearchBus;
-(void)HideKeyboard;
-(void)LeftSwipe;
-(void)RightSwipe;
-(void)ShowBusInfo;
-(void)ShowYouBikeInfo;
-(void)HideCategoryTable;
-(void)ShowIllustration;
@end
