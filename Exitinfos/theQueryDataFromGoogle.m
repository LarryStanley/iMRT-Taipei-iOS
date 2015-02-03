//
//  theQueryDataFromGoogle.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/28.
//
//

#import "theQueryDataFromGoogle.h"
#import "theSQLite.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define KGOOGLE_API_KEY @"AIzaSyD_tisamtW-bgF19T4iHPP4yfp5dLfrIlI"

@implementation theQueryDataFromGoogle
@synthesize PlaceExitResults,PlaceReferences,PlaceResults,Connection,QueryGoogleDelegate;
-(id)initAndQueryGooglePlaces:(NSString *)googleType AndSearchType:(NSString *)SearchType AndCoordinate:(CLLocationCoordinate2D)Coordinate AndRadius:(int)Radius;
{
    if ([super init]) {
        NSString *url;
        if ([SearchType isEqualToString:@"DirectSearch"]) {
            NSString *URLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%i&name=%@&sensor=true&key=%@", Coordinate.latitude, Coordinate.longitude, Radius, googleType, KGOOGLE_API_KEY];
            url = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }else{
            url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%i&types=%@&sensor=true&key=%@", Coordinate.latitude, Coordinate.longitude, Radius, googleType, KGOOGLE_API_KEY];
        }
        //NSLog(@"%@",url);
        NSURL *googleRequestURL=[NSURL URLWithString:url];
        NSURLRequest *URLRequest = [NSURLRequest requestWithURL:googleRequestURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        Connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
        [Connection start];
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

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(kBgQueue, ^{
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:GoogleData waitUntilDone:YES];
    });
}

#pragma mark All about google place api

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
    
    CLLocation *TaipeiLocation = [[CLLocation alloc] initWithLatitude:25.09123 longitude:121.56007];
    
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
        CLLocation *CurrentLocation = [[CLLocation alloc] initWithLatitude:placeCoord.latitude longitude:placeCoord.longitude];
        if ([TaipeiLocation distanceFromLocation:CurrentLocation] < 20000) {
            [PlaceResults addObject:name];
            [PlaceExitResults addObject:[self SearchClosestExit:placeCoord]];
            // Storage place reference
            [PlaceReferences addObject:[place objectForKey:@"reference"]];
        }
    }
    [QueryGoogleDelegate ShowGoogleResult:self];
}

-(NSString *)SearchClosestExit:(CLLocationCoordinate2D)PlaceCoordinate
{
    theSQLite *SQLite = [theSQLite new];
    NSMutableArray *ExitData = [SQLite ReturnMultiRowsData:@"select * from ExitInfos" andIndexOFColumn:CGPointMake(0, 4)];
    NSString *ExitName;
    CLLocation *PlaceLocation = [[CLLocation alloc] initWithLatitude:PlaceCoordinate.latitude longitude:PlaceCoordinate.longitude];
    CLLocationDistance LastExitDistance;
    CLLocation *ComparedExitLocation;
    for (int i = 0; i < [ExitData count]; i++) {
        ComparedExitLocation = [[CLLocation alloc] initWithLatitude:[[[ExitData objectAtIndex:i] objectAtIndex:3]doubleValue] longitude:[[[ExitData objectAtIndex:i] objectAtIndex:4]doubleValue]];
        if (i == 0) {
            NSString *StationIndex = [[ExitData objectAtIndex:i] objectAtIndex:0];
            ExitName = [NSString stringWithFormat:@"%@ ",NSLocalizedString(StationIndex, nil)];
            ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"Exit", nil)];
            LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
            ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"ExitWithMeter", nil),[[ExitData objectAtIndex:i] objectAtIndex:2] ,LastExitDistance];
        }else{
            if (LastExitDistance > [ComparedExitLocation distanceFromLocation:PlaceLocation]) {
                if ([[[ExitData objectAtIndex:i] objectAtIndex:2] isEqualToString:@"0"]) {
                    NSString *StationIndex = [[ExitData objectAtIndex:i] objectAtIndex:0];
                    ExitName = [NSString stringWithFormat:@"%@ ",NSLocalizedString(StationIndex, nil)];
                    ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"SingleExitWithMeter", nil), [ComparedExitLocation distanceFromLocation:PlaceLocation]];
                    LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
                }else{
                    NSString *StationIndex = [[ExitData objectAtIndex:i] objectAtIndex:0];
                    ExitName = [NSString stringWithFormat:@"%@ ",NSLocalizedString(StationIndex, nil)];
                    ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"Exit", nil)];
                    LastExitDistance = [ComparedExitLocation distanceFromLocation:PlaceLocation];
                    ExitName = [ExitName stringByAppendingFormat:NSLocalizedString(@"ExitWithMeter", nil),[[ExitData objectAtIndex:i] objectAtIndex:2] ,LastExitDistance];
                }
            }
        }
    }
    return ExitName;
}


@end
