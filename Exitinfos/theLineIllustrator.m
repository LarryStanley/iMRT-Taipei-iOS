//
//  theLineIllustrator.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/10.
//
//

#import "theLineIllustrator.h"

@implementation theLineIllustrator

- (id)initWithFrame:(CGRect)frame AndText:(NSString *)Text
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        FirstPoint = frame.origin;
        IllustratorLabel = [UILabel new];
        IllustratorLabel.backgroundColor = [UIColor clearColor];
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"BackgroundColor"] isEqualToString:@"WhiteBackground"])
            IllustratorLabel.textColor = [UIColor blackColor];
        else
            IllustratorLabel.textColor = [UIColor whiteColor];
        IllustratorLabel.text = Text;
        IllustratorLabel.font = [UIFont systemFontOfSize:12];
        [IllustratorLabel sizeToFit];
        IllustratorLabel.frame = CGRectMake(self.bounds.size.width-IllustratorLabel.bounds.size.width, self.bounds.size.height/2-IllustratorLabel.frame.size.height/2, IllustratorLabel.frame.size.width, IllustratorLabel.frame.size.height);
        [self addSubview:IllustratorLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (IllustratorLabel.frame.size.width > self.frame.size.width) {
        self.frame = CGRectMake(self.superview.frame.size.width-65-IllustratorLabel.frame.size.width, self.frame.origin.y+30, IllustratorLabel.frame.size.width+35, self.frame.size.height);
        IllustratorLabel.frame = CGRectMake(self.bounds.size.width-IllustratorLabel.bounds.size.width, self.bounds.size.height/2-IllustratorLabel.frame.size.height/2, IllustratorLabel.frame.size.width, IllustratorLabel.frame.size.height);
        if (self.frame.origin.x < 50) {

        }else{
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, 0, 0);
            CGContextAddLineToPoint(context, 5, self.bounds.size.height/2);
            CGContextAddLineToPoint(context, self.bounds.size.width-IllustratorLabel.bounds.size.width-10, self.bounds.size.height/2);
            CGContextAddLineToPoint(context, 5, self.bounds.size.height/2);
            CGContextMoveToPoint(context, 0, 0);
            CGContextClosePath(context);
            CGContextSetLineWidth(context, 1.5);
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:46/255.0f green:148/255.0f blue:226/255.0f alpha:1.0].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, self.bounds.size.height/2);
        CGContextAddLineToPoint(context, self.bounds.size.width-IllustratorLabel.bounds.size.width-5, self.bounds.size.height/2);
        CGContextClosePath(context);
        CGContextSetLineWidth(context, 1.5);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:46/255.0f green:148/255.0f blue:226/255.0f alpha:1.0].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

@end
