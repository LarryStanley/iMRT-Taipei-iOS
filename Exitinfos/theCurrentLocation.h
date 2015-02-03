//
//  theCurrentLocation.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/25.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class theCurrentLocation;

@protocol theShowCurrentLocationDelegate <NSObject>
-(void)ShowCurrentLocation:(theCurrentLocation *)CLocation AndStationNameIndex:(int)i AndStationName:(NSString *)Name AndStationColor:(NSString*)Color;
@end

@protocol theLocationSearchFailDelegate <NSObject>

-(void)LocationSearchFail:(theCurrentLocation *)CLocation;

@end

@protocol theLocationCoordinateDelegate <NSObject>

-(void)LocationCoordinate:(theCurrentLocation *)CLocation;

@end

@interface theCurrentLocation : NSObject <CLLocationManagerDelegate>

{
    CLLocationManager *LocationManager;
    id<theShowCurrentLocationDelegate> _ShowCurrentLocationDelegate;
    id<theLocationSearchFailDelegate> _LocationSearchFailDelegate;
    id<theLocationCoordinateDelegate> _GetLocationCoordinateDelegate;
    NSString *SearchType;
}

@property (nonatomic,strong) CLLocation *CurrentLocationData;
@property (nonatomic,strong) NSString *CurrentStationName;
@property (nonatomic,assign) id<theShowCurrentLocationDelegate> ShowCurrentLocationDelegate;
@property (nonatomic,assign) id<theLocationSearchFailDelegate> LocationSearchFailDelegate;
@property (nonatomic,assign) id<theLocationCoordinateDelegate> GetLocationCoordinateDelegate;
@property int CurrentStationNumber;

-(id)initAndType:(NSString *)Type;
-(void)GetStationName;

@end
