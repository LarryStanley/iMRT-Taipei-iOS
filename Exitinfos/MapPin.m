//
//  MapBluePin.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/28.
//
//

#import "MapPin.h"

@implementation MapPin
@synthesize coordinate,title,subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate
{
    if ([super init]) {
        coordinate = theCoordinate;
    }
    return self;
}

@end
