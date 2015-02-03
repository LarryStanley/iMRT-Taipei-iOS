//
//  theAStar.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/7.
//
//

#import <Foundation/Foundation.h>

@interface theAStar : NSObject
{
    int StartStationNumber,DestinyStationNumber;
    NSMutableArray *PathFindingNumberResults;
    NSMutableArray *OpenList,*CLosedList;
    CGPoint DestinyCoordinate,StartCoordinate;
}
@property (nonatomic,strong) NSArray *PathFindingNumberResults;
-(id)initWithStartStationNumber:(int)StartStation AndDestinyStationNumber:(int)DestinyStation;

#pragma mark - All about path finding
-(void)PathFindingCenter:(int)CurrentStationNumber AndDestiny:(int)DestinyNumber;
-(void)AddDataToOpenList:(int)FatherStation AndSelf:(int)StationNumber AndHeuristic:(float)Heuristic AndMovementCost:(float)MovementCost;
-(void)AddDataToClosedList:(int)FatherStation AndSelf:(int)StationNumber;
-(void)RemoveDataFromOpenList:(int)StationNumber;
-(BOOL)HaveExistedInClosedList:(int)StationNumber;
-(int)HaveExistedInOpenList:(int)StationNumber;
-(void)FindFinalResult:(int)SelfStation;
-(BOOL)DetectTransfer:(int)DestinyStation AndStartStation:(int)StartStation;
-(int)GetTransferTime:(int)StationNumber;
#pragma mark - All about math functions
-(int)ReturnTime:(int)StartNumber AndDestinyNumber:(int)DestinyNumber;

@end
