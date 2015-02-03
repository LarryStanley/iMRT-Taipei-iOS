//
//  TableVIewCellWhiteGrayBackground.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/8.
//
//

#import "TableVIewCellWhiteGrayBackground.h"
#import "theColor.h"
#define RGB 242
@implementation TableVIewCellWhiteGrayBackground

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
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:RGB/255.0f green:RGB/255.0f blue:RGB/255.0f alpha:1.0].CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:126/255.0f green:128/255.0f blue:131/255.0f alpha:1.0].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
