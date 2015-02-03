//
//  theOnlyTextButton.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/8.
//
//

#import "theOnlyTextButton.h"
#import "theColor.h"
@implementation theOnlyTextButton

- (id)initWithFrame:(CGRect)frame AndButtonText:(NSString *)ButtonString AndTextSize:(int)TextSize
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:ButtonString forState:UIControlStateNormal];
        [self setTitleColor:[theColor ButtonTextNormal] forState:UIControlStateNormal];
        [self setTitle:ButtonString forState:UIControlStateNormal];
        [self setTitleColor:[theColor ButtonTextSelected] forState:UIControlStateHighlighted];
        [self setTitle:ButtonString forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        self.titleLabel.font = [UIFont systemFontOfSize:TextSize];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.lineBreakMode = UILineBreakModeClip;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
