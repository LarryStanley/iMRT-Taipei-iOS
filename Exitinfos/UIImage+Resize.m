//
//  UIImage+Resize.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/28.
//
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)
+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
