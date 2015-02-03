//
//  theColor.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/5.
//
//

#import "theColor.h"

@implementation theColor
+(CGColorRef)MRTRed
{
    return [UIColor colorWithRed:226/255.0f green:3/255.0f blue:46/255.0f alpha:1.0].CGColor;
}

+(CGColorRef)MRTBlue
{
    return [UIColor colorWithRed:12/255.0f green:100/255.0f blue:180/255.0f alpha:1.0].CGColor;
}

+(CGColorRef)MRTBrown
{
    return [UIColor colorWithRed:173/255.0f green:109/255.0f blue:46/255.0f alpha:1.0].CGColor;
}

+(CGColorRef)MRTOrange
{
    return [UIColor colorWithRed:249/255.0f green:162/255.0f blue:41/255.0f alpha:1.0].CGColor;
}

+(CGColorRef)MRTDarkGreen
{
    return [UIColor colorWithRed:16/255.0f green:122/255.0f blue:27/255.0f alpha:1.0].CGColor;
}

+(CGColorRef)MRTGreen
{
    return [UIColor colorWithRed:208/255.0f green:220/255.0f blue:48/255.0f alpha:1.0].CGColor;
}

+(CGColorRef)MRTPink
{
    return [UIColor colorWithRed:242/255.0f green:140/255.0f blue:149/255.0f alpha:1.0].CGColor;
}

+(UIColor *)WhiteGrayColor
{
    return [UIColor colorWithRed:240/255.0f green:240/255.0f blue:242/255.0f alpha:1.0];
}

+(UIColor *)WhiteBackground
{
    return [UIColor colorWithRed:233/255.0f green:234/255.0f blue:235/255.0f alpha:1.0];
}

+(UIColor *)GrayLine
{
    return [UIColor colorWithRed:219/255.0f green:219/255.0f blue:222/255.0f alpha:1.0];
}

+(UIColor *)WhiteLine
{
    return [UIColor colorWithRed:247/255.0f green:247/255.0f blue:248/255.0f alpha:1.0];
}

+(UIColor *)ButtonTextNormal
{
    return [UIColor colorWithRed:62/255.0f green:63/255.0f blue:66/255.0f alpha:1.0];
}

+(UIColor *)ButtonTextSelected
{
    return [UIColor colorWithRed:94/255.0f green:95/255.0f blue:99/255.0f alpha:1.0];
}

+(UIColor *)GrayBackground
{
    return [UIColor colorWithRed:46/255.f green:46/255.f blue:51/255.f alpha:1.0];
}

+(UIColor *)GrayTableCellNormal
{
    return [UIColor colorWithRed:33/255.f green:34/255.f blue:38/255.f alpha:1.0];
}

+(UIColor *)GrayTableCellSelected
{
    return [UIColor colorWithRed:42/255.f green:42/255.f blue:47/255.f alpha:1.0];
}

+(UIColor *)GrayTextColor
{
    return [UIColor colorWithRed:187/255.f green:187/255.f blue:187/255.f alpha:1.0];
}

+(UIColor *)DarkGrayLine
{
    return [UIColor colorWithRed:42/255.f green:42/255.f blue:47/255.f alpha:1.0];
}

+(UIColor *)ClassicGrayBackground
{
    //return [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"MRTBackground.jpg"]];
    return [UIColor colorWithRed:65/255.f green:65/255.f blue:65/255.f alpha:1.0];
}
@end
