//
//  theExitInfosView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/29.
//
//

#import "theExitInfosView.h"
#import "TableViewCellBackground.h"
#import "theColor.h"
#import "TableViewCellGrayBackground.h"
#import "TableViewCellGrayBackgroundSelected.h"
#import "theSQLite.h"
#import "theCheckInternet.h"
#import "theGrayIllustratorView.h"

#define KGOOGLE_API_KEY @"AIzaSyD_tisamtW-bgF19T4iHPP4yfp5dLfrIlI"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation theExitInfosView

@synthesize ShowPlaceDetailsDelegate,PlaceReference,PlaceExit,ExitInfosSwiping;

- (id)initWithFrame:(CGRect)frame AndStationNumber:(int)StationNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        theCheckInternet *CheckInternet = [theCheckInternet new];
        if (![CheckInternet isConnectionAvailable]) {
            UILabel *InternetFailLabel = [UILabel new];
            InternetFailLabel.textAlignment = UITextAlignmentCenter;
            InternetFailLabel.text = NSLocalizedString(@"CheckInternet", nil);
            InternetFailLabel.font = [UIFont systemFontOfSize:15];
            [InternetFailLabel sizeToFit];
            InternetFailLabel.backgroundColor = [UIColor clearColor];
            InternetFailLabel.center = CGPointMake(self.bounds.size.width/2, 70);
            [self addSubview:InternetFailLabel];
        }else{
            theSQLite *SQLite = [theSQLite new];
            NSMutableArray *StationData = [SQLite ReturnSingleRow:[[NSString alloc] initWithFormat:@"select * from StationDataForStanley where StationNumber = %i",StationNumber]];
            ExitData = [SQLite ReturnMultiRowsData:[[NSString alloc] initWithFormat:@"select * from ExitInfos where StationNumber = %i",StationNumber] andIndexOFColumn:CGPointMake(0, 4)];
            StationCoordinate = CGPointMake([[StationData objectAtIndex:2] floatValue], [[StationData objectAtIndex:3] floatValue]);
           
            //設置搜尋元件
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                PlaceSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            else
                PlaceSearchBar = [[WhiteSearchBarInterface alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            PlaceSearchBar.backgroundColor = [theColor WhiteGrayColor];
            PlaceSearchBar.placeholder = NSLocalizedString(@"SearchPlaceNearStationWithExample", nil);
            PlaceSearchBar.delegate = self;
           
            //設置種類表格
            CategoryTable = [[UITableView alloc] initWithFrame:CGRectMake(-120, 0, 120, self.bounds.size.height) style:UITableViewStylePlain];
            CategoryTable.dataSource = self;
            CategoryTable.delegate = self;
            CategoryTable.backgroundView = nil;
            CategoryTable.backgroundColor = [theColor GrayTableCellNormal];
            [CategoryTable setSeparatorColor:[theColor DarkGrayLine]];
            [CategoryTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];
           
            //設置結果表格
            PlaceResultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height-44) style:UITableViewStylePlain];
            PlaceResultTable.dataSource = self;
            PlaceResultTable.delegate = self;
            PlaceResultTable.backgroundView = nil;
            PlaceResultTable.backgroundColor = [UIColor clearColor];
            [PlaceResultTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            //設定手勢
            RightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(RightSwipe)];
            RightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            LeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(LeftSwipe)];
            LeftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            TapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LeftSwipe)];
            TapRecognizer.numberOfTapsRequired = 1;
            [PlaceResultTable addGestureRecognizer:RightSwipeRecognizer];
            
            //設定資料載入中
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
            PowerByGoogleLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white@2x.png"]];
            PowerByGoogleLogo.frame = CGRectMake(self.bounds.size.width/2-52, DataLoadingLabel.center.y+15, 104, 16);
            [self addSubview:PowerByGoogleLogo];
            [self queryGooglePlaces:@"restaurant" AndSearchType:@"CategorySearch"];
            
            ExitInfosSwiping = NO;
        }
    }
    return self;
}

#pragma mark - NSURLConnection delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    GoogleData = [NSMutableData new];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [GoogleData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UILabel *InternetFailLabel = [UILabel new];
    InternetFailLabel.textAlignment = UITextAlignmentCenter;
    InternetFailLabel.text = NSLocalizedString(@"FailToConnect", nil);
    InternetFailLabel.font = [UIFont systemFontOfSize:15];
    [InternetFailLabel sizeToFit];
    InternetFailLabel.backgroundColor = [UIColor clearColor];
    InternetFailLabel.center = CGPointMake(self.bounds.size.width/2, 70);
    InternetFailLabel.alpha = 0;
    [self addSubview:InternetFailLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    DataLoadingLabel.alpha = 0;
    DataLoadingIndicatorView.alpha = 0;
    PowerByGoogleLogo.alpha = 0;
    InternetFailLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(kBgQueue, ^{
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:GoogleData waitUntilDone:YES];
    });
}


#pragma makr All about table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == PlaceResultTable) {
        return [PlaceResults count];
    }else{
        return 9;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (tableView == PlaceResultTable)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    if (tableView == PlaceResultTable) {
        cell.backgroundView = [[TableViewCellBackground alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"CellSelectedBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
        cell.textLabel.text = [PlaceResults objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [PlaceExitResults objectAtIndex:indexPath.row];
    }else{
        cell.backgroundView = [[TableViewCellGrayBackground alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[TableViewCellGrayBackgroundSelected alloc] init];
        NSMutableArray *CategoryName = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"Restaurant", nil),NSLocalizedString(@"Cafe", nil),NSLocalizedString(@"Bakery", nil),NSLocalizedString(@"MovieTheater", nil),NSLocalizedString(@"DepartmentStore", nil),NSLocalizedString(@"BookStore", nil),NSLocalizedString(@"ConvenienceStore", nil),NSLocalizedString(@"Park", nil),NSLocalizedString(@"ATM", nil), nil];
        cell.textLabel.text = [CategoryName objectAtIndex:indexPath.row];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [theColor GrayTextColor];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == PlaceResultTable) {
        PlaceReference = [PlaceReferences objectAtIndex:indexPath.row];
        PlaceExit = [PlaceExitResults objectAtIndex:indexPath.row];
        [ShowPlaceDetailsDelegate ShowPlaceDetails:self];
        [PlaceResultTable deselectRowAtIndexPath:[PlaceResultTable indexPathForSelectedRow] animated:YES];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        PowerByGoogleLogo.alpha = 1;
        DataLoadingIndicatorView.alpha = 1;
        DataLoadingLabel.alpha = 1;
        PlaceResultTable.alpha = 0;
        PlaceSearchBar.alpha = 0;
        EmptyDataLabel.alpha = 0;
        [UIView commitAnimations];
        NSArray *CategoryInEnglish = [[NSArray alloc] initWithObjects:@"restaurant", @"cafe",@"bakery",@"movie_theater",@"department_store",@"book_store",@"convenience_store",@"park",@"atm",nil];
        [self queryGooglePlaces:[CategoryInEnglish objectAtIndex:indexPath.row] AndSearchType:@"CategorySearch"];
        [self LeftSwipe];
    }
}

#pragma mark All about google place api

-(void) queryGooglePlaces: (NSString *) googleType AndSearchType:(NSString *)SearchType
{
    NSString *url;
    if ([SearchType isEqualToString:@"DirectSearch"]) {
        NSString *URLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%i&name=%@&sensor=true&key=%@", StationCoordinate.x, StationCoordinate.y, 500, googleType, KGOOGLE_API_KEY];
        url = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%i&types=%@&sensor=true&key=%@", StationCoordinate.x, StationCoordinate.y, 500, googleType, KGOOGLE_API_KEY];
    }
    //NSLog(@"%@",url);
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:googleRequestURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    NSURLConnection *Connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
    [Connection start];
    // Retrieve the results of the URL.
    /*dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });*/
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    [self plotPositions:places];
}

-(void)plotPositions:(NSArray *)data {
    [PlaceResults removeAllObjects];
    [PlaceExitResults removeAllObjects];
    [PlaceReferences removeAllObjects];
    PlaceResults = [NSMutableArray new];
    PlaceReferences = [NSMutableArray new];
    PlaceExitResults = [NSMutableArray new];
    for (int i=0; i<[data count]; i++) {
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        // 3 - There is a specific NSDictionary object that gives us the location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        // Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        // 4 - Get your name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        // Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        // Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        [PlaceResults addObject:name];
        [PlaceExitResults addObject:[self SearchClosestExit:placeCoord]];
        // Storage place reference
        [PlaceReferences addObject:[place objectForKey:@"reference"]];
    }
    if ([PlaceResults count]) {
        [PlaceResultTable reloadData];
        [PlaceResultTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        PlaceResultTable.alpha = 0;
        PlaceSearchBar.alpha = 0;
        
        theGrayIllustratorView *IllustratorGrayView;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ExitIllustrator"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ExitIllustrator"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            IllustratorGrayView = [[theGrayIllustratorView alloc] initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];
            [IllustratorGrayView AddIllustratorImageAndTextInCenter:NSLocalizedString(@"SwipeRightIllustrator", nil) AndImageName:@"Swipe_Right.png"];
        }
        
        [self addSubview:PlaceResultTable];
        [self addSubview:CategoryTable];
        [self addSubview:PlaceSearchBar];
        if (IllustratorGrayView)
            [self.superview addSubview:IllustratorGrayView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        if (IllustratorGrayView) {
            [UIView setAnimationDelegate:IllustratorGrayView];
            [UIView setAnimationDidStopSelector:@selector(ShowClearly)];
        }
        DataLoadingLabel.alpha = 0;
        DataLoadingIndicatorView.alpha = 0;
        PowerByGoogleLogo.alpha = 0;
        PlaceResultTable.alpha = 1;
        PlaceSearchBar.alpha = 1;
        if (IllustratorGrayView)
            IllustratorGrayView.alpha = 0.7;
        [UIView commitAnimations];
    }else{
        [PlaceResultTable reloadData];
        [EmptyDataLabel removeFromSuperview];
        EmptyDataLabel = [UILabel new];
        EmptyDataLabel.text = NSLocalizedString(@"NoData", nil);
        EmptyDataLabel.font = [UIFont systemFontOfSize:15];
        EmptyDataLabel.backgroundColor = [UIColor clearColor];
        EmptyDataLabel.textAlignment = UITextAlignmentCenter;
        [EmptyDataLabel sizeToFit];
        EmptyDataLabel.center = CGPointMake(self.bounds.size.width/2, DataLoadingIndicatorView.center.y+25);
        EmptyDataLabel.alpha = 0;
        [self addSubview:EmptyDataLabel];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        DataLoadingLabel.alpha = 0;
        DataLoadingIndicatorView.alpha = 0;
        PowerByGoogleLogo.alpha = 0;
        EmptyDataLabel.alpha = 1;
        PlaceResultTable.alpha = 1;
        PlaceSearchBar.alpha = 1;
        [UIView commitAnimations];
    }
}

-(NSString *)SearchClosestExit:(CLLocationCoordinate2D)PlaceCoordinate
{
    NSString *ExitName;
    CLLocation *PlaceLocation = [[CLLocation alloc] initWithLatitude:PlaceCoordinate.latitude longitude:PlaceCoordinate.longitude];
    CLLocationDistance LastExitDistance;
    CLLocation *ComparedExitLocation;
    for (int i = 0; i < [ExitData count]; i++) {
        ComparedExitLocation = [[CLLocation alloc] initWithLatitude:[[[ExitData objectAtIndex:i] objectAtIndex:3]doubleValue] longitude:[[[ExitData objectAtIndex:i] objectAtIndex:4]doubleValue]];
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
    }
    return ExitName;
}

#pragma mark - All about search bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    GrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height)];
    GrayView.backgroundColor = [UIColor grayColor];
    GrayView.alpha = 0.5;
    [self addSubview:GrayView];
    [PlaceSearchBar setShowsCancelButton:YES animated:YES];
    TapRecognizerForSearchBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideKeyboard)];
    TapRecognizerForSearchBar.numberOfTapsRequired = 1;
    [GrayView addGestureRecognizer:TapRecognizerForSearchBar];
    PlaceSearchBar.placeholder =  NSLocalizedString(@"SearchPlaceNearStation", nil);
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self HideKeyboard];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self HideKeyboard];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [CategoryTable deselectRowAtIndexPath:[CategoryTable indexPathForSelectedRow] animated:YES];
    [self queryGooglePlaces:PlaceSearchBar.text AndSearchType:@"DirectSearch"];
    [self HideKeyboard];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    PowerByGoogleLogo.alpha = 1;
    DataLoadingIndicatorView.alpha = 1;
    DataLoadingLabel.alpha = 1;
    PlaceResultTable.alpha = 0;
    PlaceSearchBar.alpha = 0;
    EmptyDataLabel.alpha = 0;
    [UIView commitAnimations];
}

-(void)HideKeyboard
{
    [PlaceSearchBar setShowsCancelButton:NO animated:YES];
    [PlaceSearchBar resignFirstResponder];
    PlaceSearchBar.text = @"";
    [GrayView removeFromSuperview];
    [GrayView removeGestureRecognizer:TapRecognizerForSearchBar];
    PlaceSearchBar.placeholder = NSLocalizedString(@"SearchPlaceNearStationWithExample", nil);
}


#pragma mark - All about gesture

-(void)RightSwipe
{
    [GrayView removeFromSuperview];
    GrayView = [[UIView alloc] initWithFrame:CGRectMake(CategoryTable.bounds.size.width, 0, self.bounds.size.width-CategoryTable.bounds.size.width, self.bounds.size.height)];
    GrayView.backgroundColor = [UIColor grayColor];
    GrayView.alpha = 0;
    [self addSubview:GrayView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CategoryTable.frame = CGRectMake(0, 0, 120, self.bounds.size.height);
    PlaceResultTable.frame = CGRectMake(120, 44, self.bounds.size.width, self.bounds.size.height);
    PlaceSearchBar.frame = CGRectMake(120, 0, 320, 44);
    GrayView.alpha = 0.5;
    EmptyDataLabel.center = CGPointMake(self.bounds.size.width/2+120, DataLoadingIndicatorView.center.y+25);
    [UIView commitAnimations];
    [PlaceResultTable removeGestureRecognizer:RightSwipeRecognizer];
    [CategoryTable addGestureRecognizer:LeftSwipeRecognizer];
    [GrayView addGestureRecognizer:LeftSwipeRecognizer];
    [GrayView addGestureRecognizer:TapRecognizer];
}

-(void)LeftSwipe
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CategoryTable.frame = CGRectMake(-120, 0, 120, self.bounds.size.height);
    PlaceResultTable.frame = CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height-44);
    PlaceSearchBar.frame = CGRectMake(0, 0, 320, 44);
    GrayView.alpha = 0;
    EmptyDataLabel.center = CGPointMake(self.bounds.size.width/2, DataLoadingIndicatorView.center.y+25);
    [UIView commitAnimations];
    [PlaceResultTable addGestureRecognizer:RightSwipeRecognizer];
    [CategoryTable removeGestureRecognizer:LeftSwipeRecognizer];
    [GrayView removeGestureRecognizer:LeftSwipeRecognizer];
    [GrayView removeGestureRecognizer:TapRecognizer];
}

#pragma mark - All about touch methid

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ExitInfosSwiping = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ExitInfosSwiping = NO;
}
@end
