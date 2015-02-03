//
//  MRTMap.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/15.
//
//

#import <UIKit/UIKit.h>
#import "theSQLite.h"
#import "StationFunctionView.h"

@class MRTMap;

@protocol MRTMapShowFunctionDelegate <NSObject>
-(void)ShowFunctionView:(MRTMap*)theMRTMap AndStationNameIndex:(int)i AndStationName:(NSString *)Name AndStationColor:(NSString*)Color;
@end

@protocol MRTMapDismissFunctionDelegate <NSObject>
-(void)DismissFunctionView:(MRTMap *)theMRTMap;
@end


@interface MRTMap : UIView
{
    theSQLite *SQLite;
    NSMutableArray *AllStationCoordinate;
    NSMutableArray *AllStationType;
    NSMutableArray *AllStationColor;
    NSMutableArray *AllStationName;
    NSMutableArray *AllStationLabelType;
    NSMutableArray *AllMRTMapData;
    UIView *theSuperView;
    StationFunctionView *FunctionView;
    BOOL FunctionViewIsShow;
    id<MRTMapShowFunctionDelegate> _ShowFunctionDelegate;
    id<MRTMapDismissFunctionDelegate> _DismissFunctionDelegate;
    CGPoint DoubleTapPoint;

}

@property (nonatomic,assign)  id<MRTMapShowFunctionDelegate> ShowFunctionDelegate;
@property (nonatomic,assign)  id<MRTMapDismissFunctionDelegate> DismissFunctionDelegate;
@property (nonatomic,strong)  NSMutableArray *AllStationCoordinate;
@property CGPoint DoubleTapPoint;

- (id)initWithFrame:(CGRect)frame AndSuperView:(UIView *)theView;
-(void)DrawCircle:(int)Type Color:(NSString *)ColorName Coordinate:(CGPoint)StationCoordinate;
-(void)AddLabel:(int)Type Name:(NSString *)StationName Coordinate:(CGPoint)StationCoordinate DrawCircleTyp:(int)CircleType;
-(CGColorRef)RGBColor:(NSString *)ColorName;
-(CGPoint)ConvertStationCoordinate:(CGPoint)OriginalCoordinate;
-(float)ComputeDistance:(CGPoint)StartCoordinate andDestiny:(CGPoint)DestinyCoordinate;
@end
