//
//  theCurrentLocation.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/25.
//
//

#import "theCurrentLocation.h"
#import "theSQLite.h"

@implementation theCurrentLocation 
@synthesize CurrentLocationData,CurrentStationNumber,CurrentStationName,ShowCurrentLocationDelegate,LocationSearchFailDelegate,GetLocationCoordinateDelegate;

-(id)initAndType:(NSString *)Type
{
    if ([super init]) {
        SearchType = Type;
        LocationManager = [CLLocationManager new];
        LocationManager.delegate = self;
        LocationManager.distanceFilter = 10;
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [LocationManager startUpdatingLocation];
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    CurrentStationName = NSLocalizedString(@"LocatedFail", nil);
    [LocationSearchFailDelegate LocationSearchFail:self];
    [LocationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!CurrentLocationData || newLocation != oldLocation) {
        self.CurrentLocationData = newLocation;
        if ([SearchType isEqualToString:@"SearchStation"])
            [self GetStationName];
        else
            [GetLocationCoordinateDelegate LocationCoordinate:self];
    }
}

-(void)GetStationName
{
    theSQLite *SQLite = [[theSQLite alloc] init];
    CurrentStationNumber = -1;
    NSMutableArray *StationData = [[NSMutableArray alloc] initWithArray:[SQLite ReturnMultiTableData:@"select * from StationDataForStanley" andIndexOFColumn:CGPointMake(0, 3)]];
    for (int i = 0; i < [[StationData objectAtIndex:0] count]; i++) {
        CLLocation *SQLiteCoordinate = [[CLLocation alloc] initWithLatitude:[[[StationData objectAtIndex:2] objectAtIndex:i]doubleValue] longitude:[[[StationData objectAtIndex:3] objectAtIndex:i]doubleValue]];
        if ([SQLiteCoordinate distanceFromLocation:CurrentLocationData] < 400) {
            NSString *StationIndex = [NSString stringWithFormat:@"%i",i];
            CurrentStationName = NSLocalizedString(StationIndex, nil);
            CurrentStationNumber = [[[StationData objectAtIndex:0] objectAtIndex:i] intValue];
        }
    }
    if (CurrentStationName) {
        NSMutableArray *StationMapData = [SQLite ReturnSingleRow:[NSString stringWithFormat:@"select * from Map where StationNumber = %i",CurrentStationNumber]];
        [ShowCurrentLocationDelegate ShowCurrentLocation:self AndStationNameIndex:CurrentStationNumber AndStationName:CurrentStationName AndStationColor:[StationMapData objectAtIndex:18]];
        [LocationManager stopUpdatingLocation];
    }else{
        CurrentStationName = NSLocalizedString(@"NoStationHere", nil);
        [LocationSearchFailDelegate LocationSearchFail:self];
        [LocationManager stopUpdatingLocation];
    }
}

@end
