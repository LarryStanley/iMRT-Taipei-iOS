//
//  StationFunctionView.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/4.
//
//

#import <UIKit/UIKit.h>
#import "theAStar.h"
#import "CustomMRTMap.h"
#import "theExitInfosView.h"
#import "theTransferView.h"
#import "theMRTTime.h"
#import "theOnlyTextLabel.h"
#import "theGrayIllustratorView.h"

@class StationFunctionView;

@protocol StationFunctionViewShowMoreDelegate <NSObject>
-(void)FunctionViewShowMore:(StationFunctionView*)theStationFunctionView;
@end

@protocol ChangeStatusBarColorDelegate <NSObject>
-(void)ChangeStatusBarColor:(StationFunctionView*)theStationFunctionView AndColorName:(NSString *)ColorName;
@end

@protocol SetExitInfoDelegate <NSObject>
-(void)SetExitInfosView:(StationFunctionView*)theStationFunctionView;
@end

@protocol SetTransferViewDelegate <NSObject>
-(void)SetTransferView:(StationFunctionView*)theStationFunctionView;
@end

@protocol MoveMRTScrollViewLayerDelegate <NSObject>

-(void)MoveMRTMapScrollView:(StationFunctionView*)theStationFunctionView;

@end

@interface StationFunctionView : UIView <UIScrollViewDelegate>
{
    NSString *StartStationName,*StartStationColor,*DestinyStationName,*DestinyStationColor;
    int StartStationNumber,DestinyStationNumber,FunctionViewIndex;
    UIButton *ExitInfosButton,*ShowInMapButton,*TimeButton,*TransferButton;
    UIImageView *ArrowImage;
    UILabel *PriceLabel,*TimeLabel,*DollorLabel,*CardTypeLabel,*EstimateTimeLabel,*MinuteLabel;
    UILabel *StationNameLabel,*DestinyStationLabel,*PathLoadingLabel;
    UITapGestureRecognizer *StartStationTap,*DestinyStationTap;
    UISwipeGestureRecognizer *SwipeGestureRecognizerUp,*SwipeGestureRecognizerDown;
    BOOL PriceAndTimeIsShow,HigherViewIsShow;
    UIActivityIndicatorView *PathLoadingIndicator;
    theAStar *AStar;
    CustomMRTMap *theCustomMap;
    UIScrollView *CustomMapScrollView,*ShowInMapScrollView;
    theExitInfosView *ExitInfosView;
    theTransferView *TransferView;
    theMRTTime *MRTTimeView;
    id<StationFunctionViewShowMoreDelegate> _FunctionViewShowMoreDelegate;
    id<ChangeStatusBarColorDelegate> _ChangeStatusBarColorDelegate;
    id<SetExitInfoDelegate> _SetExitDelegate;
    id<SetTransferViewDelegate> _SetTransferDelegate;
    id<MoveMRTScrollViewLayerDelegate> _MoveMRTMapDelegate;
    NSString *ShowHigherViewType;
    UIView *ButtonWhiteBackground,*LastFunctionView;
    theOnlyTextLabel *IllustrationLabel;
    CGPoint TouchBeganPoint;
    float TouchDistanceToOrigin,TouchBeganTimeStamp;
    theGrayIllustratorView *IllustratorGrayView;
    UIImageView *BicycleOpenImageview;
    int StatusBarHeight;
}
@property (nonatomic,assign)  id<StationFunctionViewShowMoreDelegate> FunctionViewShowMoreDelegate;
@property (nonatomic,assign)  id<ChangeStatusBarColorDelegate> ChangeStatusBarColorDelegate;
@property (nonatomic,assign)  id<SetExitInfoDelegate> SetExitDelegate;
@property (nonatomic,assign)  id<SetTransferViewDelegate> SetTransferDelegate;
@property (nonatomic,assign)  id<MoveMRTScrollViewLayerDelegate> MoveMRTMapDelegate;
@property (nonatomic,strong)  theExitInfosView *ExitInfosView;
@property (nonatomic,strong)  theTransferView *TransferView;
@property (nonatomic,strong)  NSString *StartStationName;
@property (nonatomic,strong)  UIImageView *ArrowImage;
@property BOOL PriceAndTimeIsShow;
@property (nonatomic,strong)  theGrayIllustratorView *IllustratorGrayView;

- (id)initWithFrame:(CGRect)frame StationName:(NSString *)Name StationColor:(NSString *)Color AndStationNumber:(int)Number;
-(CGColorRef)RGBColor:(NSString *)ColorName;
-(void)ShowPriceAndTime:(NSString *)Name AndStationColor:(NSString *)Color AndStationNumber:(int)Number;
-(void)ChangeDestinyStation:(NSString *)Name AndStationColor:(NSString *)Color AndStationNumber:(int)Number;
-(void)AddButtonsAnimation;
-(void)DismissButtons;
-(void)HideBicycleImage;
-(void)AddArrow;
-(void)AddDestinyLabel;
-(void)AddPriceLabel;
-(void)AddCardTypeLabel;
-(void)AddDollorLabel;
-(void)AddEstimateTimeLabel;
-(void)AddTimeLabel;
-(void)AddMinuteLabel;
-(void)AddCustomMRTMap;
-(void)ShowHigherView;
-(void)DismissHigherView;
-(void)RemoveFunctionView;
-(void)DismissPriceAndTime;
-(void)DismissIllustrationLabel;
-(void)AddButtonWhiteBackground:(UIButton *)theButton;
-(void)DestinyStationBecomeStartStation;
-(void)ExitButtonPressed;
-(void)TransferButtonPressed;
-(void)ShowInMapButtonPressed;
-(void)TimeButtonPressed;
-(void)SwitchFunction:(UIView *)SelectedFunctionView AndFunctionViewIndex:(int)Index;
-(void)RemoveDestinyStationLabel;
-(void)HideStationInfoForiPad;
@end
