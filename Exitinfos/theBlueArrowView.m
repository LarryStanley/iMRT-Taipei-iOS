//
//  theArrowView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/8.
//
//

#import "theBlueArrowView.h"
#import "theColor.h"
@implementation theBlueArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height/4*3);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height/4*3);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, self.bounds.size.height/4);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:55/255.f green:147/255.f blue:248/255.f alpha:1].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
