//
//  TableViewCellBackground.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/4.
//
//

#import "TableViewCellBackground.h"
#import "theColor.h"

@implementation TableViewCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [theColor WhiteGrayColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetStrokeColorWithColor(context, [theColor GrayLine].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetStrokeColorWithColor(context, [theColor WhiteLine].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
