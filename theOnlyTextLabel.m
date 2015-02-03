//
//  theOnlyTextLabel.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/15.
//
//

#import "theOnlyTextLabel.h"

@implementation theOnlyTextLabel

- (id)initWithFrame:(CGRect)frame AndLabelText:(NSString *)Text AndTextSize:(int)TextSize
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.text = Text;
        self.font = [UIFont systemFontOfSize:TextSize];
        [self sizeToFit];
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
