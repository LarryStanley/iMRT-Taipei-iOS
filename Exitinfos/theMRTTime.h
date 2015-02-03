//
//  theMRTTime.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/8.
//
//

#import <UIKit/UIKit.h>
#import "theOnlyTextButton.h"
#import "theArrowView.h"

@interface theMRTTime : UIView <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *TimeTable;
    UISegmentedControl *DirectionSegmented;
    NSInteger CurrentButtonIndex;
    theArrowView *ArrowView;
    NSMutableArray *DestinyButtons;
    NSMutableArray *AllTime,*DirectionNames;
}
- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)StationNumber;
-(void)DestinyButtonPressed:(UIButton *)button;
-(void)GetTimeData:(int)StationNumber;
-(void)SetUI;
-(void)MoveArrow;
@end
