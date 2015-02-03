//
//  MapBluePin.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/28.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title,*subtitle;
}

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate;

@end
