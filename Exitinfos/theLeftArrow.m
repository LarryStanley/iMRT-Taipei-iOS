//
//  theLeftArrow.m
//  iMRT Taipei
//
//  Created by Stanley on 2013/11/23.
//
//

#import "theLeftArrow.h"
#import "theColor.h"

@implementation theLeftArrow

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
    CGContextMoveToPoint(context, 0, self.bounds.size.height/2);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height/2);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 0);
    CGContextSetFillColorWithColor(context, [theColor WhiteBackground].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
