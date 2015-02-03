//
//  TableViewCellGrayBackground.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/30.
//
//

#import "TableViewCellGrayBackground.h"
#import "theColor.h"

@implementation TableViewCellGrayBackground

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
    CGContextSetFillColorWithColor(context, [theColor GrayTableCellNormal].CGColor);
    CGContextFillRect(context, self.bounds);
}

@end
