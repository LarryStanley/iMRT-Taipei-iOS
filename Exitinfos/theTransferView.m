//
//  theTransferView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/6/1.
//
//

#import "theTransferView.h"
#import "theColor.h"
#import "TableViewCellBackground.h"
#import "theSQLite.h"
#import "TableViewCellGrayBackgroundSelected.h"
#import "TableViewCellGrayBackground.h"
#import "theGrayIllustratorView.h"

@implementation theTransferView
@synthesize ShowBusDetailsDelegate,ShowYouBikeDataDelegate,TransitResultsTable,SelectedRowPosition;
- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)theStationNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        //資料載入中元件
        DataLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [DataLoadingIndicatorView startAnimating];
        DataLoadingIndicatorView.center = CGPointMake(self.bounds.size.width/2, 60);
        [self addSubview:DataLoadingIndicatorView];
        DataLoadingLabel = [UILabel new];
        DataLoadingLabel.text = NSLocalizedString(@"Loading", nil);
        DataLoadingLabel.font = [UIFont systemFontOfSize:15];
        DataLoadingLabel.backgroundColor = [UIColor clearColor];
        DataLoadingLabel.textAlignment = UITextAlignmentCenter;
        [DataLoadingLabel sizeToFit];
        DataLoadingLabel.center = CGPointMake(self.bounds.size.width/2, DataLoadingIndicatorView.center.y+25);
        [self addSubview:DataLoadingLabel];
        
        //設定種類表格
        CategoryTable = [[UITableView alloc] initWithFrame:CGRectMake(-120, 0, 120, self.bounds.size.height) style:UITableViewStylePlain];
        CategoryTable.dataSource = self;
        CategoryTable.delegate = self;
        CategoryTable.backgroundView = nil;
        CategoryTable.backgroundColor = [theColor GrayTableCellNormal];
        [CategoryTable setSeparatorColor:[theColor DarkGrayLine]];
        [CategoryTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];
        
        //設定手勢
        RightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(RightSwipe)];
        RightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        LeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(LeftSwipe)];
        LeftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        TapRecognizerForTableView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LeftSwipe)];
        TapRecognizerForTableView.numberOfTapsRequired = 1;
        
        StationNumber = theStationNumber;
        Searching = NO;
        [self LoadingBusData];
    }
    return self;
}

#pragma mark - All about show data

-(void)LoadingBusData
{
    //All about sqlite
    theSQLite *SQLite = [theSQLite new];
    BusSectionData = [NSMutableArray new];
    if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"])
        BusData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from EnglishMRTBusInfos where StationNumber = %i",StationNumber] andIndexOFColumn:CGPointMake(0, 7)];
    else
        BusData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from MRTBusInfos where StationNumber = %i order by BusName ASC",StationNumber] andIndexOFColumn:CGPointMake(0, 7)];
    ExitData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from ExitInfos where StationNumber = %i",StationNumber] andIndexOFColumn:CGPointMake(0, 4)];
    NSString *FirstCharacter = [NSString new];
    NSMutableArray *TempArray = [NSMutableArray new];
    //搜尋最近出口順便分類
    for (int i = 0; i < [BusData count]; i++) {
        [[BusData objectAtIndex:i] replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%@ %@",[self SearchClosestExit:CLLocationCoordinate2DMake([[[BusData objectAtIndex:i] objectAtIndex:5] floatValue], [[[BusData objectAtIndex:i] objectAtIndex:6] floatValue])],[[BusData objectAtIndex:i] objectAtIndex:4]]];
        if (!i) {
            FirstCharacter = [[[BusData objectAtIndex:i] objectAtIndex:3] substringToIndex:1];
            [TempArray addObject:[BusData objectAtIndex:i]];
        }else if ([FirstCharacter isEqualToString:[[[BusData objectAtIndex:i] objectAtIndex:3] substringToIndex:1]]){
            [TempArray addObject:[BusData objectAtIndex:i]];
            if (i == [BusData count]-1){
                [TempArray addObject:[BusData objectAtIndex:i]];
                [BusSectionData addObject:TempArray];
            }
        }else{
            [BusSectionData addObject:TempArray];
            FirstCharacter = [[[BusData objectAtIndex:i] objectAtIndex:3] substringToIndex:1];
            TempArray = nil;
            TempArray = [NSMutableArray new];
            [TempArray addObject:[BusData objectAtIndex:i]];
            if (i == [BusData count]-1)
                [BusSectionData addObject:TempArray];
        }
    }
    //設置搜尋元件
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        BusSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    else
        BusSearchBar = [[WhiteSearchBarInterface alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    BusSearchBar.backgroundColor = [theColor WhiteGrayColor];
    BusSearchBar.placeholder = NSLocalizedString(@"SearchBusName", nil);
    BusSearchBar.delegate = self;
    [self addSubview:BusSearchBar];
    
    //設置結果表格
    TransitResultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height-44) style:UITableViewStylePlain];
    TransitResultsTable.dataSource = self;
    TransitResultsTable.delegate = self;
    TransitResultsTable.backgroundView = nil;
    TransitResultsTable.backgroundColor = [UIColor clearColor];
    [TransitResultsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [TransitResultsTable addGestureRecognizer:RightSwipeRecognizer];

    //顯示表格動畫
    TransitResultsTable.alpha = 0;
    CategoryTable.alpha = 0;
    BusSearchBar.alpha = 0;
    [self addSubview:BusSearchBar];
    [self addSubview:TransitResultsTable];
    [self addSubview:CategoryTable];
    [self ShowBusInfo];
}

-(void)ShowBusInfo
{
    NoDataLabel.alpha = 0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(ShowIllustration)];
    TransitResultsTable.frame = CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height-44);
    TransitResultsTable.alpha = 1;
    [TransitResultsTable reloadData];
    BusSearchBar.alpha = 1;
    DataLoadingIndicatorView.alpha = 0;
    DataLoadingLabel.alpha = 0;
    [UIView commitAnimations];
}

-(void)ShowYouBikeInfo
{
    theSQLite *SQLite = [theSQLite new];
    NSMutableArray *MRTCoordinateData = [SQLite ReturnPointData:[NSString stringWithFormat:@"select * from StationDataForStanley where StationNumber = %i",StationNumber] andIndexOFColumn:2];
    CLLocation *CurrentStationCoordinate = [[CLLocation alloc] initWithLatitude:[[MRTCoordinateData objectAtIndex:0] CGPointValue].x longitude:[[MRTCoordinateData objectAtIndex:0] CGPointValue].y];
    NSMutableArray *YouBikeInfo = [SQLite ReturnMultiRowsData:@"select * from YouBike" andIndexOFColumn:CGPointMake(0, 5)];
    YouBikeTableData = [NSMutableArray new];
    YouBikeTableSubtitleData = [NSMutableArray new];
    YouBikeNameData = [NSMutableArray new];
    
    for (int i = 0; i < [YouBikeInfo count]; i++) {
        CLLocation *CurrentYouBikeStationCoordinate = [[CLLocation alloc] initWithLatitude:[[[YouBikeInfo objectAtIndex:i] objectAtIndex:4] floatValue] longitude:[[[YouBikeInfo objectAtIndex:i] objectAtIndex:5] floatValue]];
        if ([CurrentStationCoordinate distanceFromLocation:CurrentYouBikeStationCoordinate] < 500) {
            [YouBikeTableData addObject:[NSString stringWithFormat:NSLocalizedString(@"CountOfParkWithStopName", nil),[[YouBikeInfo objectAtIndex:i] objectAtIndex:1],[[YouBikeInfo objectAtIndex:i] objectAtIndex:3]]];
            [YouBikeNameData addObject:[[YouBikeInfo objectAtIndex:i] objectAtIndex:1]];
            [YouBikeTableSubtitleData addObject:[self SearchClosestExit:CurrentYouBikeStationCoordinate.coordinate]];
        }
    }
    
    NoDataLabel.alpha = 0;
    if (![YouBikeTableData count]) {
        if (!NoDataLabel) {
            NoDataLabel = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) AndLabelText:NSLocalizedString(@"NoData", nil) AndTextSize:15];
            NoDataLabel.center = CGPointMake(self.bounds.size.width/2, DataLoadingIndicatorView.center.y+25);
            NoDataLabel.alpha = 0;
            [self addSubview:NoDataLabel];
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    if (![YouBikeTableData count])
        NoDataLabel.alpha = 1;
    BusSearchBar.alpha = 0;
    TransitResultsTable.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [TransitResultsTable reloadData];
    [UIView commitAnimations];
}

-(void)ShowIllustration
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"YoubikeIllustration"]) {
        theGrayIllustratorView *IllustratorGrayView;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YoubikeIllustration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        IllustratorGrayView = [[theGrayIllustratorView alloc] initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];
        [IllustratorGrayView AddIllustratorImageAndTextInCenter:NSLocalizedString(@"SwipeRightToTransfer", nil) AndImageName:@"Swipe_Right.png"];
        IllustratorGrayView.alpha = 0;
        [self.superview addSubview:IllustratorGrayView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:IllustratorGrayView];
        [UIView setAnimationDidStopSelector:@selector(ShowClearly)];
        IllustratorGrayView.alpha = 0.7;
        [UIView commitAnimations];
    }
}

#pragma makr All about table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == CategoryTable)
        return 1;
    else{
        if ([CategoryTable indexPathForSelectedRow].row == 0) {
            if (Searching)
                return 1;
            else
                return [BusSectionData count];
        }else
            return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == CategoryTable)
        return 2;
    else{
        if ([CategoryTable indexPathForSelectedRow].row == 0) {
            if (Searching)
                return [SearchResults count];
            else
                return [[BusSectionData objectAtIndex:section] count];
        }else{
            return [YouBikeTableData count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (tableView == TransitResultsTable)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    if (tableView == TransitResultsTable) {
        cell.backgroundView = [[TableViewCellBackground alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"CellSelectedBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        //關於要顯示的文字
        if ([CategoryTable indexPathForSelectedRow].row == 0) {
            if (Searching) {
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BusTo", nil),[[SearchResults objectAtIndex:indexPath.row] objectAtIndex:3],[[SearchResults objectAtIndex:indexPath.row] objectAtIndex:7]];
                cell.detailTextLabel.text = [[SearchResults objectAtIndex:indexPath.row] objectAtIndex:4];
            }else{
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BusTo", nil),[[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:3],[[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:7]];
                cell.detailTextLabel.text = [[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:4];
            }
        }else{
            cell.textLabel.text = [YouBikeTableData objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [YouBikeTableSubtitleData objectAtIndex:indexPath.row];
        }
    }else{
        cell.backgroundView = [[TableViewCellGrayBackground alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[TableViewCellGrayBackgroundSelected alloc] init];
        NSMutableArray *CategoryName = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"Bus", nil), @"Youbike",nil];
        cell.textLabel.text = [CategoryName objectAtIndex:indexPath.row];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [theColor GrayTextColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == TransitResultsTable) {
        if (![CategoryTable indexPathForSelectedRow].row) {
            if (Searching)
                return 0;
            else
                return 22;
        }else
            return 0;
    }else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == TransitResultsTable) {
        if (![CategoryTable indexPathForSelectedRow].row) {
            if (Searching)
                return nil;
            else
                return [[[[BusSectionData objectAtIndex:section] objectAtIndex:0] objectAtIndex:3] substringToIndex:1];
        }else
            return nil;
    }else
        return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == TransitResultsTable) {
        if (![CategoryTable indexPathForSelectedRow].row) {
            NSMutableArray *Index = [NSMutableArray new];
            if (!Searching) {
                for (int i = 0; i < [BusSectionData count]; i++)
                    [Index addObject:[[[[BusSectionData objectAtIndex:i] objectAtIndex:0] objectAtIndex:3] substringToIndex:1]];
                return Index;
            }else
                return nil;
        }else
            return nil;
    }else
        return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == TransitResultsTable) {
        if (![CategoryTable indexPathForSelectedRow].row) {
            if (Searching) {
                return nil;
            }else{
                UIView *BlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
                BlackView.backgroundColor = [UIColor grayColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
                label.text = [[[[BusSectionData objectAtIndex:section] objectAtIndex:0] objectAtIndex:3] substringToIndex:1];
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = [UIColor clearColor];
                [BlackView addSubview:label];
                return BlackView;
            }
        }else
            return nil;
    }else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == TransitResultsTable) {
        if (![CategoryTable indexPathForSelectedRow].row) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                SelectedRowPosition = [TransitResultsTable convertRect:[TransitResultsTable rectForRowAtIndexPath:indexPath] toView:self.superview.superview];
            }
            if (!Searching) {
                CLLocation *StopCoordinate = [[CLLocation alloc] initWithLatitude:[[[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:5] floatValue] longitude:[[[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:6] floatValue]];
                    [ShowBusDetailsDelegate ShowBusDetails:self AndBusData:
                     [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:3], [[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:7], StopCoordinate,[[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:4], NSLocalizedString([[[BusSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:0], nil),nil] forKeys:[[NSArray alloc]initWithObjects:@"BusName",@"Destination",@"StopCoordinate",@"StopName",@"StationName",nil]]];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    [TransitResultsTable deselectRowAtIndexPath:[TransitResultsTable indexPathForSelectedRow] animated:YES];
            }else{
                CLLocation *StopCoordinate = [[CLLocation alloc] initWithLatitude:[[[SearchResults objectAtIndex:indexPath.row] objectAtIndex:5] floatValue] longitude:[[[SearchResults objectAtIndex:indexPath.row] objectAtIndex:6] floatValue]];
                [ShowBusDetailsDelegate ShowBusDetails:self AndBusData:
                 [[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[SearchResults objectAtIndex:indexPath.row] objectAtIndex:3], [[SearchResults objectAtIndex:indexPath.row] objectAtIndex:7], StopCoordinate,[[SearchResults objectAtIndex:indexPath.row] objectAtIndex:4], NSLocalizedString( [[SearchResults objectAtIndex:indexPath.row] objectAtIndex:0], nil),nil] forKeys:[[NSArray alloc]initWithObjects:@"BusName",@"Destination",@"StopCoordinate",@"StopName",@"StationName",nil]]];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    [TransitResultsTable deselectRowAtIndexPath:[TransitResultsTable indexPathForSelectedRow] animated:YES];
            }
        }else{
            //YouBike select function
            NSString *StationNumberString = [NSString stringWithFormat:@"%i",StationNumber];
            [ShowYouBikeDataDelegate ShowYouBikeData:self AndYouBikeData:[[NSMutableDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:[YouBikeNameData objectAtIndex:indexPath.row], NSLocalizedString(StationNumberString, nil), [YouBikeTableSubtitleData objectAtIndex:indexPath.row],nil] forKeys:[[NSArray alloc] initWithObjects:@"StopName", @"MRTStationName", @"ExitName",nil]]];
            [TransitResultsTable deselectRowAtIndexPath:[TransitResultsTable indexPathForSelectedRow] animated:YES];
        }
    }else{
        switch (indexPath.row) {
            case 0:
                [self LeftSwipe];
                [self ShowBusInfo];
                break;
            default:
                [self LeftSwipe];
                [self ShowYouBikeInfo];
                break;
        }
    }
}

#pragma mark All about search closest exit

-(NSString *)SearchClosestExit:(CLLocationCoordinate2D)PlaceCoordinate
{
    NSString *ExitName;
    CLLocation *PlaceLocation = [[CLLocation alloc] initWithLatitude:PlaceCoordinate.latitude longitude:PlaceCoordinate.longitude];
    CLLocationDistance LastExitDistance;
    CLLocation *ComparedExitLocation;
    for (int i = 0; i < [ExitData count]; i++) {
        ComparedExitLocation = [[CLLocation alloc] initWithLatitude:[[[ExitData objectAtIndex:i] objectAtIndex:3]doubleValue] longitude:[[[ExitData objectAtIndex:i] objectAtIndex:4]doubleValue]];
        if ([CategoryTable indexPathForSelectedRow].row) {
            //YouBike
            if ([[[ExitData objectAtIndex:i] objectAtIndex:2] isEqualToString:@"0"]) {
                ExitName = [NSString stringWithFormat:NSLocalizedString(@"SingleExitWithMeter", nil), [ComparedExitLocation distanceFromLocation:PlaceLocation]];
            }else{
                if (i == 0) {
                    ExitName = [NSString stringWithFormat:NSLocalizedString(@"Exit", nil)];
                    LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
                    ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"ExitWithMeter", nil),[[ExitData objectAtIndex:i] objectAtIndex:2] ,LastExitDistance];
                }else{
                    if (LastExitDistance > [ComparedExitLocation distanceFromLocation:PlaceLocation]) {
                        ExitName = [NSString stringWithFormat:NSLocalizedString(@"Exit", nil)];
                        LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
                        ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"ExitWithMeter", nil),[[ExitData objectAtIndex:i] objectAtIndex:2] ,LastExitDistance];
                    }
                }
            }
        }else{
            //Bus
            if ([[[ExitData objectAtIndex:i] objectAtIndex:2] isEqualToString:@"0"]) {
                ExitName = [NSString stringWithFormat:NSLocalizedString(@"SingleExit", nil)];
            }else{
                if (i == 0) {
                    ExitName = [NSString stringWithFormat:NSLocalizedString(@"Exit", nil)];
                    LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
                    ExitName = [ExitName stringByAppendingFormat:@"%@",[[ExitData objectAtIndex:i] objectAtIndex:2]];
                }else{
                    if (LastExitDistance > [ComparedExitLocation distanceFromLocation:PlaceLocation]) {
                        ExitName = [NSString stringWithFormat:NSLocalizedString(@"Exit", nil)];
                        LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
                        ExitName = [ExitName stringByAppendingFormat:@"%@",[[ExitData objectAtIndex:i] objectAtIndex:2]];
                    }
                }
            }
        }
    }
    return ExitName;
}

#pragma mark - All search bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    Searching = YES;
    TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideKeyboard)];
    SearchResults = [NSMutableArray new];
    GrayView = nil;
    GrayView = [[UIView alloc] initWithFrame:CGRectMake(0, BusSearchBar.frame.size.height, self.frame.size.width, self.frame.size.height)];
    GrayView.backgroundColor = [UIColor grayColor];
    GrayView.alpha = 0.5;
    [GrayView addGestureRecognizer:TapGestureRecognizer];
    [self addSubview:GrayView];
    [BusSearchBar setShowsCancelButton:YES animated:YES];
    BusSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    BusSearchBar.showsCancelButton = NO;
    Searching = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self HideKeyboard];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length) {
        Searching = YES;
        [self SearchBus];
        [TransitResultsTable reloadData];
        [GrayView removeGestureRecognizer:TapGestureRecognizer];
        [GrayView removeFromSuperview];
    }else{
        [GrayView addGestureRecognizer:TapGestureRecognizer];
        [self addSubview:GrayView];
        Searching = NO;
        [TransitResultsTable reloadData];
    }
}

-(void)SearchBus{
    NSString *SearchText =  BusSearchBar.text;
    [SearchResults removeAllObjects];
    for (int i = 0; i < [BusData count]; i ++) {
        if ([[[BusData objectAtIndex:i] objectAtIndex:3]rangeOfString:SearchText options:NSAnchoredSearch].location != NSNotFound){
            [SearchResults addObject:[BusData objectAtIndex:i]];
        }
    }
}

-(void)HideKeyboard
{
    [BusSearchBar setShowsCancelButton:NO animated:YES];
    [BusSearchBar resignFirstResponder];
    BusSearchBar.text = @"";
    [TransitResultsTable reloadData];
    [GrayView removeFromSuperview];
    [GrayView removeGestureRecognizer:TapGestureRecognizer];
}

#pragma mark - All about gesture method

-(void)RightSwipe
{
    GrayView = nil;
    GrayView = [[UIView alloc] initWithFrame:CGRectMake(CategoryTable.bounds.size.width, 0, self.bounds.size.width-CategoryTable.bounds.size.width, self.bounds.size.height)];
    GrayView.backgroundColor = [UIColor grayColor];
    GrayView.alpha = 0;
    CategoryTable.alpha = 1;
    [self addSubview:GrayView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CategoryTable.frame = CGRectMake(0, 0, 120, self.bounds.size.height);
    TransitResultsTable.frame = CGRectMake(120, TransitResultsTable.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
    BusSearchBar.frame = CGRectMake(120, 0, 320, 44);
    NoDataLabel.center = CGPointMake(NoDataLabel.center.x+120, NoDataLabel.center.y);
    GrayView.alpha = 0.5;
    [UIView commitAnimations];
    [TransitResultsTable removeGestureRecognizer:RightSwipeRecognizer];
    [CategoryTable addGestureRecognizer:LeftSwipeRecognizer];
    [GrayView addGestureRecognizer:LeftSwipeRecognizer];
    [GrayView addGestureRecognizer:TapRecognizerForTableView];
}

-(void)LeftSwipe
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(HideCategoryTable)];
    CategoryTable.frame = CGRectMake(-120, 0, 120, self.bounds.size.height);
    TransitResultsTable.frame = CGRectMake(0, TransitResultsTable.frame.origin.y, self.bounds.size.width, self.bounds.size.height-44);
    BusSearchBar.frame = CGRectMake(0, 0, 320, 44);
    NoDataLabel.center = CGPointMake(NoDataLabel.center.x-120, NoDataLabel.center.y);
    GrayView.alpha = 0;
    [UIView commitAnimations];
    [TransitResultsTable addGestureRecognizer:RightSwipeRecognizer];
    [CategoryTable removeGestureRecognizer:LeftSwipeRecognizer];
    [GrayView removeGestureRecognizer:LeftSwipeRecognizer];
    [GrayView removeGestureRecognizer:TapRecognizerForTableView];
}

-(void)HideCategoryTable
{
    CategoryTable.alpha = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
