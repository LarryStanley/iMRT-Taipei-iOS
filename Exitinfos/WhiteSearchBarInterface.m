//
//  WhiteSearchBarInterface.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/5.
//
//

#import "WhiteSearchBarInterface.h"
#import "theColor.h"

@implementation WhiteSearchBarInterface

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")])
            [(UITextField *)subview setBackground:[UIImage imageNamed:@"SearchBarBackground.png"]];
    }
    [[[self subviews] objectAtIndex:0] setAlpha:0];
}
@end
