//
//  theArrowView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/8.
//
//

#import "theArrowView.h"
#import "theColor.h"
@implementation theArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [theColor WhiteBackground];

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, 0);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:126/255.0f green:128/255.0f blue:131/255.0f alpha:1.0].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
