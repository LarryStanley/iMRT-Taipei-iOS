//
//  theQueryDataFromGoogle.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/28.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class theQueryDataFromGoogle;

@protocol QueryGooglePlaceDelegate <NSObject>
-(void)ShowGoogleResult:(theQueryDataFromGoogle*)QueryGooglePlace;
@end

@interface theQueryDataFromGoogle : NSObject
{
    NSMutableData *GoogleData;
    NSMutableArray *PlaceResults,*PlaceExitResults,*PlaceReferences;
    NSURLConnection *Connection;
    id<QueryGooglePlaceDelegate> _QueryGoogleDelegate;
}

@property (nonatomic,strong) NSMutableArray *PlaceResults,*PlaceExitResults,*PlaceReferences;
@property (nonatomic,strong) NSURLConnection *Connection;
@property (nonatomic,assign) id<QueryGooglePlaceDelegate> QueryGoogleDelegate;

-(id)initAndQueryGooglePlaces:(NSString *)googleType AndSearchType:(NSString *)SearchType AndCoordinate:(CLLocationCoordinate2D)Coordinate AndRadius:(int)Radius;
-(void)fetchedData:(NSData *)responseData;

@end
