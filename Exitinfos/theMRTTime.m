//
//  theMRTTime.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/8.
//
//

#import "theMRTTime.h"
#import "theColor.h"
#import "TableVIewCellWhiteGrayBackground.h"
#import "theOnlyTextButton.h"
#import "theSQLite.h"

@implementation theMRTTime

- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)StationNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        [self GetTimeData:StationNumber];
    }
    return self;
}

-(void)GetTimeData:(int)StationNumber
{
    
    //Get json data
    NSString *JsonFilePath = [[NSBundle mainBundle] pathForResource:@"timeTable" ofType:@"json"];
    NSString *JsonString = [NSString stringWithContentsOfFile:JsonFilePath encoding:NSUTF8StringEncoding error:Nil];
    NSData *JsonData = [JsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *AllTimeData = [NSJSONSerialization JSONObjectWithData:JsonData options:0 error:nil];
    NSDictionary *StationData = [AllTimeData objectAtIndex:StationNumber];
    
    //Find Direction
    NSArray *TimeData = [StationData objectForKey:@"TimeTable"];
    DirectionNames = [NSMutableArray new];
    for (int i = 0; i < [TimeData count]; i++)
        [DirectionNames addObject:[[TimeData objectAtIndex:i] objectForKey:@"Direction"]];
    
    //Category
    AllTime = [NSMutableArray new];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    for (int i = 0; i < [TimeData count]; i++) {
        NSDictionary *singleDirectionData = [TimeData objectAtIndex:i];
        if (weekday >=1 && weekday <7) {
            //weekdays
            NSDictionary *WeekdaysData = [singleDirectionData objectForKey:@"Weekdays"];
            NSArray *EarlyTime = [WeekdaysData objectForKey:@"Early"];
            NSArray *LatelyTime = [WeekdaysData objectForKey:@"Lately"];
            [AllTime addObject:[[NSMutableArray alloc] initWithObjects:EarlyTime, LatelyTime,nil]];
        }else{
            //holidays
            NSDictionary *HolidaysData = [singleDirectionData objectForKey:@"Holidays"];
            NSArray *EarlyTime = [HolidaysData objectForKey:@"Early"];
            NSArray *LatelyTime = [HolidaysData objectForKey:@"Lately"];
            [AllTime addObject:[[NSMutableArray alloc] initWithObjects:EarlyTime, LatelyTime,nil]];
        }
    }
    [self SetUI];
}

-(void)SetUI
{
    CurrentButtonIndex = 0;
        
    //Add direction buttons
    DestinyButtons = [NSMutableArray new];
    int MaxNumber = 4;
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"])
        MaxNumber = 3;
    if ([DirectionNames count] > MaxNumber) {
        UIScrollView *ButtonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 41.5)];
        ButtonScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:ButtonScrollView];
        [ButtonScrollView setShowsHorizontalScrollIndicator:NO];
        [ButtonScrollView setShowsVerticalScrollIndicator:NO];
        for (int i = 0; i < [DirectionNames count]; i++) {
            CGPoint ButtonLocation;
            if (!i)
                ButtonLocation = CGPointMake(0, 0);
            else{
                theOnlyTextButton *LastButton = (theOnlyTextButton *)[DestinyButtons objectAtIndex:i-1];
                ButtonLocation = CGPointMake(LastButton.frame.origin.x+LastButton.frame.size.width, 0);
            }
            theOnlyTextButton *DestinyButton = [[theOnlyTextButton alloc] initWithFrame:CGRectMake(ButtonLocation.x, 0, (self.frame.size.width)/4, 40) AndButtonText:[NSString stringWithFormat:NSLocalizedString(@"MRTTimeTo", nil),NSLocalizedString([DirectionNames objectAtIndex:i], nil)] AndTextSize:15];
            [DestinyButton sizeToFit];
            DestinyButton.frame = CGRectMake(DestinyButton.frame.origin.x+20, DestinyButton.frame.origin.y, DestinyButton.frame.size.width, 40);
            [DestinyButton setTag:i];
            [DestinyButton addTarget:self action:@selector(DestinyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [DestinyButtons addObject:DestinyButton];
            [ButtonScrollView addSubview:DestinyButton];
        }
        
        //Set ContentSize
        theOnlyTextButton *LastButton = (theOnlyTextButton *)[DestinyButtons objectAtIndex:[DestinyButtons count]-1];
        ButtonScrollView.contentSize = CGSizeMake(LastButton.frame.origin.x+LastButton.frame.size.width+10, 41.5);
        
        //Set line
        UIView *WhiteLine = [[UIView alloc] initWithFrame:CGRectMake(-165, 40, LastButton.frame.origin.x+LastButton.frame.size.width+330, 1.5)];
        WhiteLine.backgroundColor = [UIColor colorWithRed:126/255.0f green:128/255.0f blue:131/255.0f alpha:1.0];
        [ButtonScrollView addSubview:WhiteLine];
        
        //Set arrow
        ArrowView = [[theArrowView alloc] initWithFrame:CGRectMake((self.frame.size.width)/4/2-7.5, 31.5, 15, 10)];
        [ButtonScrollView addSubview:ArrowView];
    }else{
        for (int i = 0; i < [DirectionNames count]; i++) {
            theOnlyTextButton *DestinyButton = [[theOnlyTextButton alloc] initWithFrame:CGRectMake(i*(self.frame.size.width)/[DirectionNames count], 0, (self.frame.size.width)/[DirectionNames count], 40) AndButtonText:[NSString stringWithFormat:NSLocalizedString(@"MRTTimeTo", nil),NSLocalizedString([DirectionNames objectAtIndex:i], nil)] AndTextSize:15];
            [DestinyButton setTag:i];
            [DestinyButton addTarget:self action:@selector(DestinyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [DestinyButtons addObject:DestinyButton];
            [self addSubview:DestinyButton];
        }
        
        //Set line
        UIView *WhiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 1.5)];
        WhiteLine.backgroundColor = [UIColor colorWithRed:126/255.0f green:128/255.0f blue:131/255.0f alpha:1.0];
        [self addSubview:WhiteLine];
        
        //Set Arrow
        ArrowView = [[theArrowView alloc] initWithFrame:CGRectMake((self.frame.size.width)/[DirectionNames count]/2-7.5, 31.5, 15, 10)];
        [self addSubview:ArrowView];
    }
    //Set time table
    TimeTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 41.5, self.frame.size.width, self.frame.size.height-41.5) style:UITableViewStyleGrouped];
    TimeTable.delegate = self;
    TimeTable.dataSource = self;
    TimeTable.backgroundView = nil;
    TimeTable.backgroundColor = [UIColor clearColor];
    [self addSubview:TimeTable];
}

#pragma mark - All about table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[AllTime objectAtIndex:CurrentButtonIndex] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[AllTime objectAtIndex:CurrentButtonIndex] objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.backgroundView = [TableVIewCellWhiteGrayBackground new];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //關於要顯示的文字
    cell.textLabel.text = [[[AllTime objectAtIndex:CurrentButtonIndex] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (![[[AllTime objectAtIndex:CurrentButtonIndex] objectAtIndex:section] count])
                return nil;
            else
                return NSLocalizedString(@"FirstTrains", nil);
            break;
        case 1:
            if (![[[AllTime objectAtIndex:CurrentButtonIndex] objectAtIndex:section] count])
                return nil;
            else
                return NSLocalizedString(@"After11PM", nil);
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *Title;
    switch (section) {
        case 1:
            Title = NSLocalizedString(@"TimeTableNote", nil);
            break;
        default:
            Title = nil;
            break;
    }
    return Title;
}

#pragma mark - All about button method

-(void)DestinyButtonPressed:(UIButton *)button
{
    for (theOnlyTextButton *AllButton in DestinyButtons) {
        AllButton.selected = NO;
        AllButton.highlighted = NO;
    }
    button.selected = YES;
    button.highlighted = YES;
    if (button.tag != CurrentButtonIndex) {
        CurrentButtonIndex = button.tag;
        [self MoveArrow];
        [TimeTable reloadData];
    }
}

#pragma mark - All about animation

-(void)MoveArrow
{
    theOnlyTextButton *SelectedButton = (theOnlyTextButton *)[DestinyButtons objectAtIndex:CurrentButtonIndex];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    ArrowView.frame = CGRectMake(SelectedButton.center.x-7.5, 31.5, 15, 10);
    [UIView commitAnimations];
}

@end
