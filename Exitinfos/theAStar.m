//
//  theAStar.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/7.
//
//

#import "theAStar.h"
#import "theSQLite.h"
#define NSLog(FORMAT, ...) fprintf( stderr, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String] );

@implementation theAStar
@synthesize PathFindingNumberResults;
-(id)initWithStartStationNumber:(int)StartStation AndDestinyStationNumber:(int)DestinyStation
{
    if ([super init]) {
        StartStationNumber = StartStation;
        DestinyStationNumber = DestinyStation;
        PathFindingNumberResults = [NSMutableArray new];
        theSQLite *SQLite = [theSQLite new];
        NSMutableArray *DestinyStationInfos = [SQLite ReturnSingleRow:[[NSString alloc] initWithFormat:@"select * from Map where StationNumber = %i",DestinyStationNumber]];
        NSMutableArray *StartStationInfos = [SQLite ReturnSingleRow:[[NSString alloc] initWithFormat:@"select * from Map where StationNumber = %i",StartStationNumber]];
        OpenList = [NSMutableArray new];
        CLosedList = [NSMutableArray new];
        [self AddDataToClosedList:-1 AndSelf:StartStationNumber];
        DestinyCoordinate = CGPointMake([[DestinyStationInfos objectAtIndex:3] floatValue], [[DestinyStationInfos objectAtIndex:4] floatValue]);
        StartCoordinate = CGPointMake([[StartStationInfos objectAtIndex:3] floatValue], [[StartStationInfos objectAtIndex:4] floatValue]);
        [self PathFindingCenter:StartStationNumber AndDestiny:DestinyStationNumber];
    }
    return self;
}

-(void)PathFindingCenter:(int)CurrentStationNumber AndDestiny:(int)DestinyNumber
{
    if (CurrentStationNumber == DestinyStationNumber) {
        [self FindFinalResult:DestinyStationNumber];
    }else{
        theSQLite *SQLite = [theSQLite new];
        NSMutableArray *CurrentNumberInfos = [SQLite ReturnSingleRow:[[NSString alloc] initWithFormat:@"select * from Map where StationNumber = %i",CurrentStationNumber]];
        NSMutableArray *AllConnectStation = [NSMutableArray new];
        //儲存所有連結點
        for (int i = 6; i <= 15; i=i+3) {
            if ([[CurrentNumberInfos objectAtIndex:i] intValue] == -1)
                break;
            else
                [AllConnectStation addObject:[CurrentNumberInfos objectAtIndex:i]];
        }
        for (int i = 0; i < [AllConnectStation count]; i++) {
            int TransferTime = 0;
            if (CurrentStationNumber != StartStationNumber){
                if ([self DetectTransfer:[[AllConnectStation objectAtIndex:i] intValue] AndStartStation:CurrentStationNumber])
                    TransferTime = [self GetTransferTime:CurrentStationNumber];
            }
            int CurrentStationIndexAtOpenListed = [self HaveExistedInOpenList:[[AllConnectStation objectAtIndex:i] intValue]];
            if (CurrentStationIndexAtOpenListed == -1 && ![self HaveExistedInClosedList:[[AllConnectStation objectAtIndex:i] intValue]]) {
                [self AddDataToOpenList:CurrentStationNumber AndSelf:[[AllConnectStation objectAtIndex:i] intValue] AndHeuristic:[self ReturnTime:[[AllConnectStation objectAtIndex:i] intValue] AndDestinyNumber:DestinyNumber] AndMovementCost:[self ReturnTime:CurrentStationNumber AndDestinyNumber:[[AllConnectStation objectAtIndex:i] intValue]] + TransferTime];
            }else if(CurrentStationIndexAtOpenListed != -1){
                //已存在開啟列表中
                if ([self ReturnTime:StartStationNumber AndDestinyNumber:[[AllConnectStation objectAtIndex:i] intValue]] < [[[OpenList objectAtIndex:CurrentStationIndexAtOpenListed] objectAtIndex:3] floatValue]) {
                    [OpenList replaceObjectAtIndex:CurrentStationIndexAtOpenListed withObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:CurrentStationNumber],[NSNumber numberWithInt:[[AllConnectStation objectAtIndex:i] intValue]], [NSNumber numberWithFloat:[self ReturnTime:[[AllConnectStation objectAtIndex:i] intValue] AndDestinyNumber:DestinyNumber]], [NSNumber numberWithFloat:[self ReturnTime:[[AllConnectStation objectAtIndex:i] intValue] AndDestinyNumber:CurrentStationNumber] + TransferTime],[NSNumber numberWithFloat:([self ReturnTime:[[AllConnectStation objectAtIndex:i] intValue] AndDestinyNumber:DestinyNumber]+[self ReturnTime:[[AllConnectStation objectAtIndex:i] intValue] AndDestinyNumber:CurrentStationNumber] + TransferTime)],nil]];
                }
            }
        }
        float ShortestDistance = -1,MovementCost = -1;
        int theBestStationNumber = -1;
        int StationIndexAtOpenListed = -1;
        for (int i = 0; i < [OpenList count]; i++) {
            if (ShortestDistance != -1) {
                if ([[[OpenList objectAtIndex:i] objectAtIndex:4] floatValue] < ShortestDistance){
                    ShortestDistance = [[[OpenList objectAtIndex:i] objectAtIndex:4] floatValue];
                    theBestStationNumber = [[[OpenList objectAtIndex:i] objectAtIndex:1] intValue];
                    MovementCost = [[[OpenList objectAtIndex:i] objectAtIndex:3] floatValue];
                    StationIndexAtOpenListed = i;
                }
            }else{
                StationIndexAtOpenListed = i;
                ShortestDistance = [[[OpenList objectAtIndex:i] objectAtIndex:4] floatValue];
                theBestStationNumber = [[[OpenList objectAtIndex:i] objectAtIndex:1] intValue];
                MovementCost = [[[OpenList objectAtIndex:i] objectAtIndex:3] floatValue];
            }
        }
        [self AddDataToClosedList:[[[OpenList objectAtIndex:StationIndexAtOpenListed] objectAtIndex:0] intValue] AndSelf:[[[OpenList objectAtIndex:StationIndexAtOpenListed] objectAtIndex:1] intValue]];
        [self PathFindingCenter:theBestStationNumber AndDestiny:DestinyStationNumber];
    }
}

-(void)AddDataToOpenList:(int)FatherStation AndSelf:(int)StationNumber AndHeuristic:(float)Heuristic AndMovementCost:(float)MovementCost
{
    bool HaveExisted = NO;
    for (int i = 0; i <[OpenList count]; i++) {
        if ([[[OpenList objectAtIndex:i] objectAtIndex:1] intValue] == StationNumber){
            HaveExisted = YES;
            break;
        }
    }
    if (!HaveExisted)
        [OpenList addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:FatherStation], [NSNumber numberWithInt:StationNumber],[NSNumber numberWithFloat:Heuristic], [NSNumber numberWithFloat:MovementCost],[NSNumber numberWithFloat:(Heuristic+MovementCost)],nil]];
}

-(void)RemoveDataFromOpenList:(int)StationNumber
{
    for (int i = 0; i <[OpenList count]; i++) {
        if ([[[OpenList objectAtIndex:i] objectAtIndex:1] intValue] == StationNumber){
            [OpenList removeObjectAtIndex:i];
            break;
        }
    }
}

-(void)AddDataToClosedList:(int)FatherStation AndSelf:(int)StationNumber
{
    [self RemoveDataFromOpenList:StationNumber];
    [CLosedList addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:FatherStation], [NSNumber numberWithInt:StationNumber],nil]];
}

-(BOOL)HaveExistedInClosedList:(int)StationNumber
{
    BOOL HaveExisted = NO;
    for (int i = 0; i < [CLosedList count]; i++) {
        if ([[[CLosedList objectAtIndex:i] objectAtIndex:1] intValue] == StationNumber) {
            HaveExisted = YES;
            break;
        }
    }
    return HaveExisted;
}

-(int)HaveExistedInOpenList:(int)StationNumber
{
    int HaveExisted = -1;
    for (int i = 0; i < [OpenList count]; i++) {
        if ([[[OpenList objectAtIndex:i] objectAtIndex:1] intValue] == StationNumber) {
            HaveExisted = i;
            break;
        }
    }
    return HaveExisted;
}

-(void)FindFinalResult:(int)SelfStation
{
    [PathFindingNumberResults addObject:[NSNumber numberWithInt:SelfStation]];
    if (SelfStation != StartStationNumber) {
        for (int i = 0; i < [CLosedList count]; i++) {
            if ([[[CLosedList objectAtIndex:i] objectAtIndex:1] intValue] == SelfStation) {
                [self FindFinalResult:[[[CLosedList objectAtIndex:i] objectAtIndex:0] intValue]];
                break;
            }
        }
    }
}

-(BOOL)DetectTransfer:(int)DestinyStation AndStartStation:(int)StartStation
{
    BOOL Transfer = NO;
    theSQLite *SQLite = [theSQLite new];
    NSString *FatherConnectName, *DestinyConnectName;
    NSMutableArray *StartStationData = [SQLite ReturnSingleRow:[NSString stringWithFormat:@"select * from Map where StationNumber = %i", StartStation]];
    int FatherStationNumber = [[[CLosedList objectAtIndex:[CLosedList count]-1] objectAtIndex:0] intValue];
    
    for (int i = 6; i < [StartStationData count]; i = i + 3) {
        if ([[StartStationData objectAtIndex:i] intValue] == DestinyStation)
            DestinyConnectName = [StartStationData objectAtIndex:i+2];
        else if ([[StartStationData objectAtIndex:i] intValue] == FatherStationNumber)
            FatherConnectName = [StartStationData objectAtIndex:i+2];
        else if ([[StartStationData objectAtIndex:i] intValue] == -1)
            break;
    }
    
    if (![FatherConnectName isEqualToString:DestinyConnectName])
        Transfer = YES;
    
    return Transfer;
}

-(int)GetTransferTime:(int)StationNumber
{
    theSQLite *SQLite = [theSQLite new];
    NSDictionary *StationData = [SQLite ReturnSingleRowWithDictionary:[NSString stringWithFormat:@"select * from StationDataForStanley where StationNumber = %i",StationNumber]];
    return [[StationData objectForKey:@"TransferTime"] intValue];
}

#pragma mark - All about math functions

-(int)ReturnTime:(int)StartNumber AndDestinyNumber:(int)DestinyNumber;
{
    theSQLite *SQLite = [theSQLite new];
    int Time = [[[SQLite ReturnSingleRowWithDictionary:[NSString stringWithFormat:@"select * from PriceAndTime where StartStationNumber = %i and DestinyStationNumber = %i",StartNumber,DestinyNumber]] objectForKey:@"TravelTime"] intValue];
    return Time;
}

@end
