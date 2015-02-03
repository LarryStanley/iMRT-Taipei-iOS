//
//  CustomMRTMap.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/15.
//
//

#import <UIKit/UIKit.h>
#import "theSQLite.h"
@interface CustomMRTMap : UIView
{
    theSQLite *SQLite;
    NSMutableArray *PathFindingResults;
    NSMutableArray *AllStationCoordinate;
    NSMutableArray *AllStationType;
    NSMutableArray *AllStationColor;
    NSMutableArray *AllStationName;
    NSMutableArray *AllStationLabelType;
    NSMutableArray *AllMRTMapData;
    CGPoint FirstPoint,LastPoint,MapSize;
}
@property CGPoint MapSize;
- (id)initWithFrame:(CGRect)frame AndPathFindingResults:(NSArray *)Results;
-(void)DrawLine:(int)Type Color:(NSString *)ColorName Start:(CGPoint)StartCoordinate Destiny:(CGPoint)DestinyCoordinate;
-(void)DrawCircle:(int)Type Color:(NSString *)ColorName Coordinate:(CGPoint)StationCoordinate;
-(void)AddLabel:(int)Type Name:(NSString *)StationName Coordinate:(CGPoint)StationCoordinate DrawCircleTyp:(int)CircleType;
-(CGColorRef)RGBColor:(NSString *)ColorName;
-(CGPoint)ConvertStationCoordinate:(CGPoint)OriginalCoordinate;
-(void)CalculateFirstPoint;
@end
