//
//  theGrayIllustratorView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/27.
//
//

#import "theGrayIllustratorView.h"
#import "theOnlyTextLabel.h"

@implementation theGrayIllustratorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0;
        Lables = [[NSMutableArray alloc] init];
        Images = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)AddIllustratorImageAndTextInCenter:(NSString *)Text AndImageName:(NSString *)ImageName
{
    UIImageView *Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ImageName]];
    Image.frame = CGRectMake(self.frame.size.width/2-32, self.frame.size.height/2-32, 64, 64);
    [self addSubview:Image];
    theOnlyTextLabel *IllustratorLabel = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) AndLabelText:Text AndTextSize:15];
    IllustratorLabel.center = CGPointMake(self.frame.size.width/2, Image.frame.origin.y+74);
    IllustratorLabel.textColor = [UIColor whiteColor];
    [self addSubview:IllustratorLabel];
    
    IllustratorOKButton = [[theGrayButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2-49, IllustratorLabel.frame.origin.y + IllustratorLabel.frame.size.height+10, 98, 33) AndButtonText:NSLocalizedString(@"OK", nil)];
    [self addSubview:IllustratorOKButton];
    [IllustratorOKButton addTarget:self action:@selector(DismissIllustratorView) forControlEvents:UIControlEventTouchUpInside];
    
    [Lables addObject:IllustratorLabel];
    [Images addObject:Image];
}

-(void)AddIllustratorImageAndText:(NSString *)Text AndImageName:(NSString *)ImageName AndImageCenter:(CGPoint)Center
{
    UIImageView *Image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ImageName]];
    Image.frame = CGRectMake(Center.x-32, Center.y-32, 64, 64);
    [self addSubview:Image];
    theOnlyTextLabel *IllustratorLabel = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) AndLabelText:Text AndTextSize:15];
    IllustratorLabel.center = CGPointMake(self.frame.size.width/2, Image.frame.origin.y+74);
    IllustratorLabel.textColor = [UIColor whiteColor];
    [self addSubview:IllustratorLabel];
    
    [Lables addObject:IllustratorLabel];
    [Images addObject:Image];
}

-(void)ShowClearly
{
    for (theOnlyTextLabel *IllustratorLable in Lables)
        IllustratorLable.alpha = 1;
    
    for (UIImageView *IllustratorImage in Images) 
        IllustratorImage.alpha = 1;
    
    IllustratorOKButton.alpha = 1;
}

-(void)DismissIllustratorView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(RemoveIllustratorView)];
    self.alpha = 0;
    [UIView commitAnimations];
}

-(void)RemoveIllustratorView
{
    [self removeFromSuperview];
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
