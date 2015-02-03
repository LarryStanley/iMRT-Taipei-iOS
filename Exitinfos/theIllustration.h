//
//  theIllustration.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/7.
//
//

#import <UIKit/UIKit.h>

@interface theIllustration : UIView
{
    UILabel *IllustrationLabel;
    NSArray *MainViewIllustrationWords;
}
@property NSString *PresentType;
@property (nonatomic,strong) UILabel *IllustrationLabel;
- (id)initWithFrame:(CGRect)frame AndType:(NSString *)Type;
-(void)AddIllustrationLabel;
-(void)MainViewrOtherIllustration:(NSTimer*)theTimer;
-(void)DismissIllustration;
@end
