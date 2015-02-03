//
//  theBusMap.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/6/11.
//
//

#import <UIKit/UIKit.h>

@interface theBusMap : UIView
{
    NSArray *BusRouteData;
    NSString *CurrentStopName;
}

- (id)initWithFrame:(CGRect)frame AndRouteData:(NSArray *)RouteData AndCurrentStopName:(NSString *)StopName;

@end
