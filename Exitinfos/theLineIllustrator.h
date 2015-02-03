//
//  theLineIllustrator.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/7/10.
//
//

#import <UIKit/UIKit.h>

@interface theLineIllustrator : UIView
{
    UILabel *IllustratorLabel;
    CGPoint FirstPoint;
}
- (id)initWithFrame:(CGRect)frame AndText:(NSString *)Text;
@end
