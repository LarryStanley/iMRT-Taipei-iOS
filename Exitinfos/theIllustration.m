//
//  theIllustration.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/7.
//
//

#import "theIllustration.h"
#import "theColor.h"

@implementation theIllustration
@synthesize PresentType,IllustrationLabel;
- (id)initWithFrame:(CGRect)frame AndType:(NSString *)Type
{
    self = [super initWithFrame:frame];
    if (self) {
        PresentType = Type;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [theColor WhiteGrayColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetStrokeColorWithColor(context, [theColor WhiteLine].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);

    [self AddIllustrationLabel];
}

-(void)AddIllustrationLabel
{
    IllustrationLabel = [UILabel new];
    if ([PresentType isEqualToString:@"MainViewIllustration"]){
        MainViewIllustrationWords = [[NSArray alloc] initWithObjects:NSLocalizedString(@"PinchZoomIn", nil),NSLocalizedString(@"TapGetInfos", nil),nil];
        IllustrationLabel.text = [MainViewIllustrationWords objectAtIndex:0];
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(MainViewrOtherIllustration:) userInfo:[NSNumber numberWithInt:1] repeats:NO];
    }else if ([PresentType isEqualToString:@"LocationSearchFail"]){
        MainViewIllustrationWords = [[NSArray alloc] initWithObjects:NSLocalizedString(@"LocatedFail", nil),NSLocalizedString(@"TryAgainLater", nil),nil];
        IllustrationLabel.text = [MainViewIllustrationWords objectAtIndex:0];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(MainViewrOtherIllustration:) userInfo:[NSNumber numberWithInt:1] repeats:NO];
    }else if ([PresentType isEqualToString:@"NoMRTNearby"]){
        MainViewIllustrationWords = [[NSArray alloc] initWithObjects:NSLocalizedString(@"NoStationHere", nil),NSLocalizedString(@"TryAgainLater", nil),nil];
        IllustrationLabel.text = [MainViewIllustrationWords objectAtIndex:0];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(MainViewrOtherIllustration:) userInfo:[NSNumber numberWithInt:1] repeats:NO];
    }else if ([PresentType isEqualToString:@"UpSwipeIllustration"]){
        MainViewIllustrationWords = [[NSArray alloc] initWithObjects:NSLocalizedString(@"UpSwipeToRoute", nil),nil];
        IllustrationLabel.text = [MainViewIllustrationWords objectAtIndex:0];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(DismissIllustration) userInfo:nil repeats:NO];
    }
    IllustrationLabel.backgroundColor = [UIColor clearColor];
    IllustrationLabel.textColor = [UIColor blackColor];
    IllustrationLabel.font = [UIFont systemFontOfSize:15];
    IllustrationLabel.textAlignment = UITextAlignmentCenter;
    [IllustrationLabel sizeToFit];
    IllustrationLabel.frame = CGRectMake(self.bounds.size.width/2-self.bounds.size.width/2, self.bounds.size.height/2-IllustrationLabel.frame.size.height/2, self.bounds.size.width, IllustrationLabel.frame.size.height);
    [self addSubview:IllustrationLabel];
}

-(void)MainViewrOtherIllustration:(NSTimer*)theTimer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.2];
    if (![[theTimer userInfo] intValue] == ([MainViewIllustrationWords count]-1)){
        IllustrationLabel.text = [MainViewIllustrationWords objectAtIndex:[[theTimer userInfo] intValue]];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(MainViewrOtherIllustration:) userInfo:[NSNumber numberWithInt:[[theTimer userInfo] intValue]+1] repeats:NO];
    }else
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(DismissIllustration) userInfo:nil repeats:NO];
    [UIView commitAnimations];
}

-(void)DismissIllustration
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.2];
    self.alpha = 0;
    [UIView commitAnimations];
}

@end
