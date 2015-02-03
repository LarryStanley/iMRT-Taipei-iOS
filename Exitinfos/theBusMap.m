//
//  theBusMap.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/6/11.
//
//

#import "theBusMap.h"
#import "theColor.h"

@implementation theBusMap

- (id)initWithFrame:(CGRect)frame AndRouteData:(NSArray *)RouteData AndCurrentStopName:(NSString *)StopName;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        BusRouteData = [[NSArray alloc] initWithArray:RouteData];
        CurrentStopName = StopName;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint CurrentPoint,NextPoint;
    CurrentPoint = CGPointMake(50, 25);
    NextPoint = CGPointMake(50, 65);
    for (int i = 0; i<[BusRouteData count]; i++) {
        if (i == [BusRouteData count] -1) {
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, CurrentPoint.x, CurrentPoint.y, 13, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:136/255.f blue:195/255.f alpha:1] CGColor]);
            CGContextDrawPath(context, kCGPathFillStroke);
        }else{
            //draw line
            CGContextSetLineWidth(context, 9);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, CurrentPoint.x, CurrentPoint.y);
            CGContextAddLineToPoint(context, NextPoint.x, NextPoint.y);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:136/255.f blue:195/255.f alpha:1] CGColor]);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextDrawPath(context, kCGPathFillStroke);
            //draw circle
            if (!i) {
                CGContextSetLineWidth(context, 0);
                CGContextBeginPath(context);
                CGContextAddArc(context, CurrentPoint.x, CurrentPoint.y, 13, 0, 2*M_PI, YES);
                CGContextClosePath(context);
                CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:136/255.f blue:195/255.f alpha:1] CGColor]);
                CGContextDrawPath(context, kCGPathFillStroke);
            }else{
                CGContextSetLineWidth(context, 1.5);
                CGContextBeginPath(context);
                CGContextAddArc(context, CurrentPoint.x, CurrentPoint.y, 5, 0, 2*M_PI, YES);
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:136/255.f blue:195/255.f alpha:1] CGColor]);
                CGContextSetFillColorWithColor(context, [[theColor WhiteBackground] CGColor]);
                CGContextDrawPath(context, kCGPathFillStroke);
            }
        }
        UILabel *StopNameLable = [[UILabel alloc] init];
        StopNameLable.backgroundColor = [UIColor clearColor];
        StopNameLable.text = [[BusRouteData objectAtIndex:i] objectAtIndex:3];
        if ([[[BusRouteData objectAtIndex:i] objectAtIndex:3] isEqualToString:CurrentStopName])
            StopNameLable.textColor = [UIColor redColor];
        StopNameLable.font = [UIFont systemFontOfSize:15];
        [StopNameLable sizeToFit];
        if (i == 0 || i == [BusRouteData count]-1)
            StopNameLable.frame = CGRectMake(65, CurrentPoint.y-StopNameLable.frame.size.height/2, StopNameLable.frame.size.width, StopNameLable.frame.size.height);
        else
            StopNameLable.frame = CGRectMake(60, CurrentPoint.y-StopNameLable.frame.size.height/2, StopNameLable.frame.size.width, StopNameLable.frame.size.height);
        [self addSubview:StopNameLable];
        CurrentPoint = NextPoint;
        NextPoint.y = NextPoint.y + 40;
    }
}

@end
