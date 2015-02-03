//
//  theGrayIllustratorView.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/27.
//
//

#import <UIKit/UIKit.h>
#import "theGrayButton.h"

@interface theGrayIllustratorView : UIView
{
    NSMutableArray *Lables,*Images;
    theGrayButton *IllustratorOKButton;
}
-(void)AddIllustratorImageAndTextInCenter:(NSString *)Text AndImageName:(NSString *)ImageName;
-(void)AddIllustratorImageAndText:(NSString *)Text AndImageName:(NSString *)ImageName AndImageCenter:(CGPoint)Center;
-(void)DismissIllustratorView;
-(void)RemoveIllustratorView;
-(void)ShowClearly;
@end
