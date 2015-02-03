//
//  UIImage+Resize.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/28.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (Resize)
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
