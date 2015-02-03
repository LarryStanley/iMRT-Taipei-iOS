//
//  StationFunctionView.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/4.
//
//

#import "StationFunctionView.h"
#import "theColor.h"
#import "theSQLite.h"
#import "CustomMRTMap.h"
#import "theShowStationInMapView.h"
#import "theGrayIllustratorView.h"
#import <QuartzCore/QuartzCore.h>
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

#define IconSizeHeight 100
#define IconSizeWidth 70
#define FunctionViewHeight 150

@implementation StationFunctionView
@synthesize PriceAndTimeIsShow,FunctionViewShowMoreDelegate,ChangeStatusBarColorDelegate,MoveMRTMapDelegate,ExitInfosView,SetExitDelegate,StartStationName,ArrowImage,SetTransferDelegate,TransferView,IllustratorGrayView;
- (id)initWithFrame:(CGRect)frame StationName:(NSString *)Name StationColor:(NSString *)Color AndStationNumber:(int)Number
{
    self = [super initWithFrame:frame];
    if (self) {
        FunctionViewIndex = -1;
        StartStationName = Name;
        StartStationColor = Color;
        StartStationNumber = Number;
        ExitInfosButton = [[UIButton alloc] initWithFrame:CGRectMake(20, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight)];
        TransferButton = [[UIButton alloc] initWithFrame:CGRectMake(90, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight)];
        ShowInMapButton = [[UIButton alloc] initWithFrame:CGRectMake(160, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight)];
        TimeButton = [[UIButton alloc] initWithFrame:CGRectMake(230, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight)];
        ButtonWhiteBackground = [UIView new];
        StartStationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DismissPriceAndTime)];
        DestinyStationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DestinyStationBecomeStartStation)];
        self.PriceAndTimeIsShow = NO;
        HigherViewIsShow = NO;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            StatusBarHeight = 20;
        }else
            StatusBarHeight = 0;

    }
    return self;
}

-(void)ChangeDestinyStation:(NSString *)Name AndStationColor:(NSString *)Color AndStationNumber:(int)Number
{
    if (DestinyStationNumber != Number && StartStationNumber != Number) {
        DestinyStationName = Name;
        DestinyStationColor = Color;
        DestinyStationNumber = Number;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(RemoveDestinyStationLabel)];
        DestinyStationLabel.alpha = 0;
        DestinyStationLabel.center = CGPointMake(self.frame.size.width+DestinyStationLabel.center.x, DestinyStationLabel.center.y);
        [UIView commitAnimations];
    }
}

-(void)RemoveDestinyStationLabel
{
    theSQLite *SQLite = [theSQLite new];
    NSMutableArray *PriceAndTimeResult = [[NSMutableArray alloc] initWithArray:[SQLite ReturnSingleRow:[[NSString alloc] initWithFormat:@"select * from PriceAndTime where StartStationNumber = %i and DestinyStationNumber = %i",StartStationNumber,DestinyStationNumber]]];
    NSUserDefaults *Setting = [NSUserDefaults standardUserDefaults];
    TimeLabel.text = [PriceAndTimeResult objectAtIndex:7];
    if ([[Setting stringForKey:@"CardType"] isEqualToString:@"EasyCard"])
        PriceLabel.text = [PriceAndTimeResult objectAtIndex:5];
    else if ([[Setting stringForKey:@"CardType"] isEqualToString:@"ElderCard"])
        PriceLabel.text = [PriceAndTimeResult objectAtIndex:6];
    else
        PriceLabel.text = [PriceAndTimeResult objectAtIndex:4];
    //設定標簽位置
    [PriceLabel sizeToFit];
    PriceLabel.frame = CGRectMake(10, FunctionViewHeight-PriceLabel.frame.size.height, PriceLabel.frame.size.width, PriceLabel.frame.size.height);
    [TimeLabel sizeToFit];
    TimeLabel.frame = CGRectMake(self.bounds.size.width/2+10, FunctionViewHeight-TimeLabel.frame.size.height, TimeLabel.frame.size.width, TimeLabel.frame.size.height);
    
    [DestinyStationLabel removeFromSuperview];
    DestinyStationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-[DestinyStationName length]*20, 10, 30*[DestinyStationName length], 30)];
    DestinyStationLabel.text = DestinyStationName;
    DestinyStationLabel.font = [UIFont systemFontOfSize:20];
    DestinyStationLabel.backgroundColor = [UIColor clearColor];
    DestinyStationLabel.textColor = [UIColor whiteColor];
    [DestinyStationLabel sizeToFit];
    if (DestinyStationLabel.frame.size.width + 25 > self.frame.size.width/2) {
        DestinyStationLabel.font = [UIFont systemFontOfSize:15];
        [DestinyStationLabel sizeToFit];
        if (DestinyStationLabel.frame.size.width + 25 < self.frame.size.width/2) {
            DestinyStationLabel.frame = CGRectMake(self.bounds.size.width, 25-DestinyStationLabel.frame.size.height/2, DestinyStationLabel.frame.size.width, DestinyStationLabel.frame.size.height);
        }else{
            DestinyStationLabel.numberOfLines = 0;
            DestinyStationLabel.lineBreakMode = UILineBreakModeTailTruncation;
            DestinyStationLabel.font = [UIFont systemFontOfSize:15];
            DestinyStationLabel.adjustsFontSizeToFitWidth = NO;
            DestinyStationLabel.textAlignment = UITextAlignmentRight;
            CGSize LabelSize = [DestinyStationName sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(self.frame.size.width/2-25, 40) lineBreakMode:NSLineBreakByTruncatingTail];
            DestinyStationLabel.frame = CGRectMake(self.bounds.size.width, 5, LabelSize.width, LabelSize.height);
        }
    }else{
        DestinyStationLabel.frame = CGRectMake(self.bounds.size.width, 10, DestinyStationLabel.frame.size.width, 30);
    }
    DestinyStationLabel.alpha = 0;
    [self addSubview:DestinyStationLabel];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    
    MinuteLabel.frame = CGRectMake(TimeLabel.frame.origin.x+TimeLabel.frame.size.width, FunctionViewHeight-MinuteLabel.frame.size.height-10, MinuteLabel.frame.size.width, MinuteLabel.frame.size.height);
    DollorLabel.frame = CGRectMake(PriceLabel.frame.origin.x+PriceLabel.frame.size.width, FunctionViewHeight-DollorLabel.frame.size.height-10, DollorLabel.frame.size.width, DollorLabel.frame.size.height);
    DestinyStationLabel.alpha = 1;
    DestinyStationLabel.frame = CGRectMake(self.bounds.size.width-10-DestinyStationLabel.frame.size.width, DestinyStationLabel.frame.origin.y, DestinyStationLabel.frame.size.width, DestinyStationLabel.frame.size.height);
    [UIView commitAnimations];
}

- (void)drawRect:(CGRect)rect
{
    //站的背景顏色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self RGBColor:StartStationColor]);
    CGContextFillRect(context, self.bounds);
    //標簽和按鈕分隔線
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, FunctionViewHeight/3);
    CGContextAddLineToPoint(context, self.bounds.size.width, FunctionViewHeight/3);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [theColor GrayLine].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    //標簽和按鈕分隔線
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, FunctionViewHeight/3+1);
    CGContextAddLineToPoint(context, self.bounds.size.width, FunctionViewHeight/3+1);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [theColor WhiteLine].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, FunctionViewHeight/3+1);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, FunctionViewHeight/3+1);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 0);
    CGContextSetFillColorWithColor(context, [self RGBColor:@"gray"]);
    CGContextDrawPath(context, kCGPathFillStroke);
    if ([ShowHigherViewType isEqualToString:@"PathFindingResults"] || ShowHigherViewType == nil) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, FunctionViewHeight+1);
        CGContextAddLineToPoint(context, self.bounds.size.width, FunctionViewHeight+1);
        CGContextClosePath(context);
        CGContextSetLineWidth(context, 0.5);
        CGContextSetStrokeColorWithColor(context, [theColor GrayLine].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, FunctionViewHeight+1.5);
        CGContextAddLineToPoint(context, self.bounds.size.width, FunctionViewHeight+1.5);
        CGContextClosePath(context);
        CGContextSetLineWidth(context, 0.5);
        CGContextSetStrokeColorWithColor(context, [theColor WhiteLine].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    if (![ShowHigherViewType isEqualToString:@"PathFindingResults"] && self.superview.frame.size.height-self.frame.origin.y != FunctionViewHeight) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, FunctionViewHeight);
        CGContextAddLineToPoint(context, self.bounds.size.width, FunctionViewHeight);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextAddLineToPoint(context, 0, self.bounds.size.height);
        CGContextClosePath(context);
        CGContextSetLineWidth(context, 0.5);
        CGContextSetStrokeColorWithColor(context, [theColor WhiteBackground].CGColor);
        CGContextSetFillColorWithColor(context, [theColor WhiteBackground].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.bounds.size.width, FunctionViewHeight/3);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextClosePath(context);
        CGContextSetLineWidth(context, 2);
        CGContextSetStrokeColorWithColor(context, [theColor GrayLine].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    [StationNameLabel removeFromSuperview];
    StationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 20, 30)];
    StationNameLabel.backgroundColor = [UIColor clearColor];
    StationNameLabel.font = [UIFont systemFontOfSize:20];
    StationNameLabel.text = StartStationName;
    [StationNameLabel sizeToFit];
    if (StationNameLabel.frame.size.width + 25 > self.frame.size.width/2) {
        StationNameLabel.font = [UIFont systemFontOfSize:15];
        [StationNameLabel sizeToFit];
        if (StationNameLabel.frame.size.width + 25 < self.frame.size.width/2) {
            StationNameLabel.frame = CGRectMake(10, 25-StationNameLabel.frame.size.height/2, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
        }else{
            StationNameLabel.numberOfLines = 0;
            StationNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
            StationNameLabel.font = [UIFont systemFontOfSize:15];
            StationNameLabel.adjustsFontSizeToFitWidth = NO;
            StationNameLabel.textAlignment = UITextAlignmentLeft;
            CGSize LabelSize = [StartStationName sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(self.frame.size.width/2-25, 40) lineBreakMode:NSLineBreakByTruncatingTail];
            StationNameLabel.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
        }
    }else{
        StationNameLabel.frame = CGRectMake(10, 10, StationNameLabel.frame.size.width, 30);
    }
    StationNameLabel.textColor = [UIColor whiteColor];
    StationNameLabel.alpha = 1;
    [self addSubview:StationNameLabel];
    
    //出口資訊按鈕
    [ExitInfosButton setImage:[UIImage imageNamed:@"ExitInfosButtonNormal@2x.png"] forState:UIControlStateNormal];
    [ExitInfosButton setImage:[UIImage imageNamed:@"ExitInfosButtonSelected@2x.png"] forState:UIControlStateHighlighted];
    [ExitInfosButton setImage:[UIImage imageNamed:@"ExitInfosButtonSelected@2x.png"] forState:UIControlStateSelected];
    [ExitInfosButton setImage:[UIImage imageNamed:@"ExitInfosButtonSelected@2x.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self addSubview:ExitInfosButton];
    [ExitInfosButton addTarget:self action:@selector(ExitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //路線規劃
    [TransferButton setImage:[UIImage imageNamed:@"TransferButtonNormal@2x.png"] forState:UIControlStateNormal];
    [TransferButton setImage:[UIImage imageNamed:@"TransferButtonSelected@2x.png"] forState:UIControlStateHighlighted];
    [TransferButton setImage:[UIImage imageNamed:@"TransferButtonSelected@2x.png"] forState:UIControlStateSelected];
    [TransferButton setImage:[UIImage imageNamed:@"TransferButtonSelected@2x.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [TransferButton addTarget:self action:@selector(TransferButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:TransferButton];
    //在地圖中顯示按鈕
    [ShowInMapButton setImage:[UIImage imageNamed:@"MapLocationButtonNormal@2x.png"] forState:UIControlStateNormal];
    [ShowInMapButton setImage:[UIImage imageNamed:@"MapLocationButtonSelected@2x.png"] forState:UIControlStateHighlighted];
    [ShowInMapButton setImage:[UIImage imageNamed:@"MapLocationButtonSelected@2x.png"] forState:UIControlStateSelected];
    [ShowInMapButton setImage:[UIImage imageNamed:@"MapLocationButtonSelected@2x.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [ShowInMapButton addTarget:self action:@selector(ShowInMapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ShowInMapButton];
    //首末班車時間
    [TimeButton setImage:[UIImage imageNamed:@"TimeButtonNormal@2x.png"] forState:UIControlStateNormal];
    [TimeButton setImage:[UIImage imageNamed:@"TimeButtonSelected@2x.png"] forState:UIControlStateHighlighted];
    [TimeButton setImage:[UIImage imageNamed:@"TimeButtonSelected@2x.png"] forState:UIControlStateSelected];
    [TimeButton setImage:[UIImage imageNamed:@"TimeButtonSelected@2x.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [TimeButton addTarget:self action:@selector(TimeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:TimeButton];
    ButtonWhiteBackground.backgroundColor = [theColor WhiteBackground];
    //腳踏車是否開放
    theSQLite *SQLite = [theSQLite new];
    NSMutableArray *OpenData = [SQLite ReturnSingleRow:[NSString stringWithFormat:@"select * from BicycleOpenData where StationNumber = %i",StartStationNumber]];
    if ([[OpenData objectAtIndex:2] boolValue] && !BicycleOpenImageview) {
        BicycleOpenImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BicycleImage@2x.png"]];
        BicycleOpenImageview.frame = CGRectMake(self.frame.size.width-60, 10, 50, 30);
        [self addSubview:BicycleOpenImageview];
    }
}

#pragma mark - All about color

-(CGColorRef)RGBColor:(NSString *)ColorName
{
    UIColor *Color;
    if ([ColorName isEqualToString:@"blue"])
        Color = [UIColor colorWithRed:108/255.f green:122/255.f blue:152/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"brown"])
        Color = [UIColor colorWithRed:152/255.f green:70/255.f blue:46/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"orange"])
        Color = [UIColor colorWithRed:220/255.f green:147/255.f blue:81/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"red"])
        Color = [UIColor colorWithRed:178/255.f green:51/255.f blue:59/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"dark green"])
        Color = [UIColor colorWithRed:66/255.f green:112/255.f blue:96/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"green"])
        Color = [UIColor colorWithRed:78/255.f green:166/255.f blue:112/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"pink"])
        Color = [UIColor colorWithRed:226/255.f green:109/255.f blue:124/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"gray"])
        Color = [UIColor colorWithRed:65/255.f green:65/255.f blue:65/255.f alpha:1.0];
    else
        Color = [UIColor colorWithRed:127/255.f green:127/255.f blue:127/255.f alpha:1.0];
    CGColorRef CGColor = CGColorRetain(Color.CGColor);
    Color = nil;
    return CGColor;
}

#pragma mark - All about show price and time

-(void)ShowPriceAndTime:(NSString *)Name AndStationColor:(NSString *)Color AndStationNumber:(int)Number
{
    if (StartStationNumber != Number) {
        DestinyStationName = Name;
        DestinyStationColor = Color;
        DestinyStationNumber = Number;
        theSQLite *SQLite = [theSQLite new];
        PriceLabel = [UILabel new];
        TimeLabel = [UILabel new];
        DollorLabel = [UILabel new];
        CardTypeLabel = [UILabel new];
        EstimateTimeLabel = [UILabel new];
        MinuteLabel = [UILabel new];
        NSMutableArray *PriceAndTimeResult = [[NSMutableArray alloc] initWithArray:[SQLite ReturnSingleRow:[[NSString alloc] initWithFormat:@"select * from PriceAndTime where StartStationNumber = %i and DestinyStationNumber = %i",StartStationNumber,DestinyStationNumber]]];
        NSUserDefaults *Setting = [NSUserDefaults standardUserDefaults];
        if ([[Setting stringForKey:@"CardType"] isEqualToString:@"EasyCard"]){
            PriceLabel.text = [PriceAndTimeResult objectAtIndex:5];
            CardTypeLabel.text = NSLocalizedString(@"EasyCard", nil);
        }else if ([[Setting stringForKey:@"CardType"] isEqualToString:@"ElderCard"]){
            PriceLabel.text = [PriceAndTimeResult objectAtIndex:6];
            CardTypeLabel.text = NSLocalizedString(@"Elder", nil);
        }else{
            PriceLabel.text = [PriceAndTimeResult objectAtIndex:4];
            CardTypeLabel.text = NSLocalizedString(@"Single Journal", nil);
        }
        
        //設定標簽內容
        DollorLabel.text = NSLocalizedString(@"NTD", nil);
        EstimateTimeLabel.text = NSLocalizedString(@"TravelTime", nil);
        MinuteLabel.text = NSLocalizedString(@"Minute", nil);
        TimeLabel.text = [PriceAndTimeResult objectAtIndex:7];
        
        //設定標簽字型大小
        PriceLabel.font = [UIFont systemFontOfSize:60];
        TimeLabel.font = [UIFont systemFontOfSize:60];
        DollorLabel.font = [UIFont systemFontOfSize:15];
        CardTypeLabel.font = [UIFont systemFontOfSize:15];
        EstimateTimeLabel.font = [UIFont systemFontOfSize:15];
        MinuteLabel.font = [UIFont systemFontOfSize:15];
        
        //去除標簽背景
        PriceLabel.backgroundColor = TimeLabel.backgroundColor = DollorLabel.backgroundColor = CardTypeLabel.backgroundColor = EstimateTimeLabel.backgroundColor = MinuteLabel.backgroundColor = [UIColor clearColor];
        
        //設定標簽字顏色
        PriceLabel.textColor = TimeLabel.textColor = [UIColor colorWithRed:55/255.f green:147/255.f blue:248/255.f alpha:1];
        DollorLabel.textColor = CardTypeLabel.textColor = EstimateTimeLabel.textColor = MinuteLabel.textColor = [UIColor whiteColor];
        
        //設定標簽位置
        [CardTypeLabel sizeToFit];
        CardTypeLabel.frame = CGRectMake(10, FunctionViewHeight/3+10, CardTypeLabel.frame.size.width, CardTypeLabel.frame.size.height);
        [PriceLabel sizeToFit];
        PriceLabel.frame = CGRectMake(10, FunctionViewHeight-PriceLabel.frame.size.height, PriceLabel.frame.size.width, PriceLabel.frame.size.height);
        [DollorLabel sizeToFit];
        DollorLabel.frame = CGRectMake(PriceLabel.frame.origin.x+PriceLabel.frame.size.width, FunctionViewHeight-DollorLabel.frame.size.height-10, DollorLabel.frame.size.width, DollorLabel.frame.size.height);
        [EstimateTimeLabel sizeToFit];
        EstimateTimeLabel.frame = CGRectMake(self.bounds.size.width/2+10, FunctionViewHeight/3+10, EstimateTimeLabel.frame.size.width, EstimateTimeLabel.frame.size.height);
        [TimeLabel sizeToFit];
        TimeLabel.frame = CGRectMake(self.bounds.size.width/2+10, FunctionViewHeight-TimeLabel.frame.size.height, TimeLabel.frame.size.width, TimeLabel.frame.size.height);
        [MinuteLabel sizeToFit];
        MinuteLabel.frame = CGRectMake(TimeLabel.frame.origin.x+TimeLabel.frame.size.width, FunctionViewHeight-MinuteLabel.frame.size.height-10, MinuteLabel.frame.size.width, MinuteLabel.frame.size.height);
        ShowHigherViewType = @"PathFindingResults";
        [self setNeedsDisplay];
        if (BicycleOpenImageview)
            [self HideBicycleImage];
        else
            [self AddArrow];
    }
    
}

-(void)HideBicycleImage
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddArrow)];
    BicycleOpenImageview.alpha = 0;
    [UIView commitAnimations];
}

-(void)AddArrow
{
    ArrowImage = nil;
    ArrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow.png"]];
    ArrowImage.frame = CGRectMake(self.bounds.size.width/2-45, 10, 30, 30);
    ArrowImage.alpha = 0;
    [self addSubview:ArrowImage];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddDestinyLabel)];
    ArrowImage.alpha = 1.0;
    ArrowImage.frame = CGRectMake(self.bounds.size.width/2-15, 10, 30, 30);
    [UIView commitAnimations];
}

-(void)AddDestinyLabel
{
    if (!DestinyStationLabel)
        DestinyStationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-[DestinyStationName length]*20, 10, 30*[DestinyStationName length], 30)];
    DestinyStationLabel.text = DestinyStationName;
    DestinyStationLabel.font = [UIFont systemFontOfSize:20];
    DestinyStationLabel.backgroundColor = [UIColor clearColor];
    DestinyStationLabel.textColor = [UIColor whiteColor];
    [DestinyStationLabel sizeToFit];
    if (DestinyStationLabel.frame.size.width + 25 > self.frame.size.width/2) {
        DestinyStationLabel.font = [UIFont systemFontOfSize:15];
        [DestinyStationLabel sizeToFit];
        if (DestinyStationLabel.frame.size.width + 25 < self.frame.size.width/2) {
            DestinyStationLabel.frame = CGRectMake(self.bounds.size.width-10-DestinyStationLabel.frame.size.width, 25-DestinyStationLabel.frame.size.height/2, DestinyStationLabel.frame.size.width, DestinyStationLabel.frame.size.height);
        }else{
            DestinyStationLabel.numberOfLines = 0;
            DestinyStationLabel.lineBreakMode = UILineBreakModeTailTruncation;
            DestinyStationLabel.font = [UIFont systemFontOfSize:15];
            DestinyStationLabel.adjustsFontSizeToFitWidth = NO;
            DestinyStationLabel.textAlignment = UITextAlignmentRight;
            CGSize LabelSize = [DestinyStationName sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(self.frame.size.width/2-25, 40) lineBreakMode:NSLineBreakByTruncatingTail];
            DestinyStationLabel.frame = CGRectMake(self.bounds.size.width-10-LabelSize.width, 5, LabelSize.width, LabelSize.height);
        }
    }else{
        DestinyStationLabel.frame = CGRectMake(self.bounds.size.width-10-DestinyStationLabel.frame.size.width, 10, DestinyStationLabel.frame.size.width, 30);
    }
    DestinyStationLabel.alpha = 0;
    [self addSubview:DestinyStationLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(DismissButtons)];
    [UIView setAnimationDuration:0.2];
    DestinyStationLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)AddButtonsAnimation
{
    [StationNameLabel removeGestureRecognizer:StartStationTap];
    [DestinyStationLabel removeGestureRecognizer:DestinyStationTap];

    [PriceLabel removeFromSuperview];
    [TimeLabel removeFromSuperview];
    [DollorLabel removeFromSuperview];
    [CardTypeLabel removeFromSuperview];
    [EstimateTimeLabel removeFromSuperview];
    [MinuteLabel removeFromSuperview];
    [ArrowImage removeFromSuperview];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    ExitInfosButton.frame = CGRectMake(20, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    TransferButton.frame = CGRectMake(90, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    ShowInMapButton.frame = CGRectMake(160, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    TimeButton.frame = CGRectMake(230, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    BicycleOpenImageview.alpha = 1;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        ButtonWhiteBackground.frame = CGRectMake(ButtonWhiteBackground.frame.origin.x-320, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    [UIView commitAnimations];
    [self setNeedsDisplay];
    [DestinyStationLabel removeFromSuperview];
    DestinyStationLabel = nil;
    PriceAndTimeIsShow = NO;
    
    ShowHigherViewType = @"Infos";
}

-(void)DismissPriceAndTime
{
    //[self removeGestureRecognizer:SwipeGestureRecognizerUp];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddButtonsAnimation)];
    [UIView setAnimationDuration:0.2];
    PriceLabel.alpha = 0;
    TimeLabel.alpha = 0;
    DollorLabel.alpha = 0;
    CardTypeLabel.alpha = 0;
    EstimateTimeLabel.alpha = 0;
    MinuteLabel.alpha = 0;
    ArrowImage.alpha = 0;
    DestinyStationLabel.alpha = 0;
    [UIView commitAnimations];
}

-(void)DismissButtons
{
    StationNameLabel.alpha = 1;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddCardTypeLabel)];
    [UIView setAnimationDuration:0.2];
    ExitInfosButton.frame = CGRectMake(20+320, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    TransferButton.frame = CGRectMake(90+320, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    ShowInMapButton.frame = CGRectMake(160+320, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    TimeButton.frame = CGRectMake(230+320, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        ButtonWhiteBackground.frame = CGRectMake(ButtonWhiteBackground.frame.origin.x+320, FunctionViewHeight/3, IconSizeWidth, IconSizeHeight);
    [UIView commitAnimations];
}

-(void)AddCardTypeLabel
{
    CardTypeLabel.alpha = 0;
    [self addSubview:CardTypeLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddPriceLabel)];
    [UIView setAnimationDuration:0.2];
    CardTypeLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)AddPriceLabel
{
    PriceLabel.alpha = 0;
    [self addSubview:PriceLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddDollorLabel)];
    [UIView setAnimationDuration:0.2];
    PriceLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)AddDollorLabel
{
    DollorLabel.alpha = 0;
    [self addSubview:DollorLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddEstimateTimeLabel)];
    [UIView setAnimationDuration:0.2];
    DollorLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)AddEstimateTimeLabel
{
    EstimateTimeLabel.alpha = 0;
    [self addSubview:EstimateTimeLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddTimeLabel)];
    [UIView setAnimationDuration:0.2];
    EstimateTimeLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)AddTimeLabel
{
    TimeLabel.alpha = 0;
    [self addSubview:TimeLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddMinuteLabel)];
    [UIView setAnimationDuration:0.2];
    TimeLabel.alpha = 1;
    [UIView commitAnimations];
}

-(void)AddMinuteLabel
{
    MinuteLabel.alpha = 0;
    [self addSubview:MinuteLabel];
    [UIView beginAnimations:nil context:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(HideStationInfoForiPad)];
    }
    [UIView setAnimationDuration:0.2];
    MinuteLabel.alpha = 1;
    [UIView commitAnimations];
    StationNameLabel.userInteractionEnabled = YES;
    [StationNameLabel addGestureRecognizer:StartStationTap];
    DestinyStationLabel.userInteractionEnabled = YES;
    [DestinyStationLabel addGestureRecognizer:DestinyStationTap];
    //[self addGestureRecognizer:SwipeGestureRecognizerUp];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"PathFindingIllustration"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PathFindingIllustration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        theGrayIllustratorView *GrayIllustrator = [[theGrayIllustratorView alloc] initWithFrame:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];
        [GrayIllustrator AddIllustratorImageAndText:NSLocalizedString(@"TapToBackFunction", nil) AndImageName:@"Single_Tap.png" AndImageCenter:CGPointMake(DestinyStationLabel.frame.origin.x, DestinyStationLabel.frame.origin.y+DestinyStationLabel.frame.size.height+self.frame.origin.y+10)];
        [GrayIllustrator AddIllustratorImageAndTextInCenter:NSLocalizedString(@"UpSwipeToRoute", nil) AndImageName:@"Swipe_Up.png"];
        [self.superview addSubview:GrayIllustrator];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:GrayIllustrator];
        [UIView setAnimationDidStopSelector:@selector(ShowClearly)];
        GrayIllustrator.alpha = 0.7;
        [UIView commitAnimations];
    }

}

-(void)HideStationInfoForiPad
{
    [UIView beginAnimations:Nil context:Nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(ShowHigherView)];
    LastFunctionView.alpha = 0;
    [UIView commitAnimations];
}

#pragma mark - All about higher view

-(void)ShowHigherView
{
    if([ShowHigherViewType isEqualToString:@"PathFindingResults"]){
        AStar = [[theAStar alloc] initWithStartStationNumber:StartStationNumber AndDestinyStationNumber:DestinyStationNumber];
       // [self removeGestureRecognizer:SwipeGestureRecognizerUp];
        [StationNameLabel removeGestureRecognizer:StartStationTap];
        [DestinyStationLabel removeGestureRecognizer:DestinyStationTap];
        PathLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [PathLoadingIndicator startAnimating];
        PathLoadingIndicator.center = CGPointMake(self.bounds.size.width/2, FunctionViewHeight+50);
        [self addSubview:PathLoadingIndicator];
        PathLoadingLabel = [UILabel new];
        PathLoadingLabel.text = NSLocalizedString(@"PathFinding", nil);
        PathLoadingLabel.font = [UIFont systemFontOfSize:15];
        PathLoadingLabel.textColor = [UIColor whiteColor];
        PathLoadingLabel.backgroundColor = [UIColor clearColor];
        PathLoadingLabel.textAlignment = UITextAlignmentCenter;
        [PathLoadingLabel sizeToFit];
        PathLoadingLabel.center = CGPointMake(self.bounds.size.width/2-PathLoadingLabel.frame.size.width/2, PathLoadingIndicator.center.y+25);
        [self addSubview:PathLoadingLabel];
        [self AddCustomMRTMap];
        
        //Google Analytics
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Path Finding Result View"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    }else{
        //Illustration
        [ChangeStatusBarColorDelegate ChangeStatusBarColor:self AndColorName:StartStationColor];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowBackIllustration"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowBackIllustration"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ExitIllustrator"] && [ShowHigherViewType isEqualToString:@"ExitInfos"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ExitIllustrator"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                IllustratorGrayView = [[theGrayIllustratorView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height)];
                [IllustratorGrayView AddIllustratorImageAndText:NSLocalizedString(@"DownSwipeToMap", nil) AndImageName:@"Swipe_Down.png" AndImageCenter:CGPointMake(self.frame.size.width/2, 52)];
                [IllustratorGrayView AddIllustratorImageAndTextInCenter:NSLocalizedString(@"SwipeRightIllustrator", nil) AndImageName:@"Swipe_Right.png"];
                [self.superview addSubview:IllustratorGrayView];
            }else if(![[NSUserDefaults standardUserDefaults] boolForKey:@"YoubikeIllustration"] && [ShowHigherViewType isEqualToString:@"TransferInfos"]){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YoubikeIllustration"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                IllustratorGrayView = [[theGrayIllustratorView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height)];
                [IllustratorGrayView AddIllustratorImageAndText:NSLocalizedString(@"DownSwipeToMap", nil) AndImageName:@"Swipe_Down.png" AndImageCenter:CGPointMake(self.frame.size.width/2, 52)];
                [IllustratorGrayView AddIllustratorImageAndTextInCenter:NSLocalizedString(@"SwipeRightToTransfer", nil) AndImageName:@"Swipe_Right.png"];
                [self.superview addSubview:IllustratorGrayView];
            }else{
                IllustratorGrayView = [[theGrayIllustratorView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height)];
                [IllustratorGrayView AddIllustratorImageAndTextInCenter:NSLocalizedString(@"DownSwipeToMap", nil) AndImageName:@"Swipe_Down.png"];
                [self.superview addSubview:IllustratorGrayView];
            }
        }else{
            IllustrationLabel = [[theOnlyTextLabel alloc] initWithFrame:CGRectMake(10, 10, 10, 10) AndLabelText:NSLocalizedString(@"DownSwipeToMap", nil) AndTextSize:12];
            [IllustrationLabel sizeToFit];
            IllustrationLabel.textColor = [UIColor whiteColor];
            IllustrationLabel.center = CGPointMake(self.frame.size.width/2, IllustrationLabel.frame.size.height/2);
            IllustrationLabel.alpha = 0;
            [self addSubview:IllustrationLabel];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(DismissIllustrationLabel)];
            IllustrationLabel.alpha = 1;
            [UIView commitAnimations];
        }
        
        [FunctionViewShowMoreDelegate FunctionViewShowMore:self];
    }
    
    HigherViewIsShow = YES;
    //[self addGestureRecognizer:SwipeGestureRecognizerDown];
}

-(void)AddCustomMRTMap
{
    [theCustomMap removeFromSuperview];
    [PathLoadingIndicator removeFromSuperview];
    [PathLoadingLabel removeFromSuperview];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"BackgroundColor"] isEqualToString:@"WhiteBackground"])
        CustomMapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, FunctionViewHeight+1, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-1)];
    else
        CustomMapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, FunctionViewHeight+9, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-9)];

    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"BackgroundColor"] isEqualToString:@"WhiteBackground"])
        CustomMapScrollView.backgroundColor = [theColor WhiteBackground];
    [self addSubview:CustomMapScrollView];
    CustomMapScrollView.delegate = self;
    theCustomMap = [[CustomMRTMap alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-1) AndPathFindingResults:AStar.PathFindingNumberResults];
    theCustomMap.frame = CGRectMake(self.bounds.size.width/2-theCustomMap.MapSize.x/2, 20, theCustomMap.MapSize.x, theCustomMap.MapSize.y);
    [CustomMapScrollView addSubview:theCustomMap];
    CustomMapScrollView.contentSize = theCustomMap.bounds.size;
    CustomMapScrollView.userInteractionEnabled = YES;
    CustomMapScrollView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [PathLoadingIndicator stopAnimating];
    PathLoadingLabel.alpha = 0;
    CustomMapScrollView.alpha = 1.0;
    [UIView commitAnimations];
}

-(void)DismissHigherView
{
    StationNameLabel.userInteractionEnabled = YES;
    [StationNameLabel addGestureRecognizer:StartStationTap];
    DestinyStationLabel.userInteractionEnabled = YES;
    [DestinyStationLabel addGestureRecognizer:DestinyStationTap];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    ExitInfosButton.selected = NO;
    ExitInfosButton.highlighted = NO;
    TransferButton.selected = NO;
    TransferButton.highlighted = NO;
    ShowInMapButton.selected = NO;
    ShowInMapButton.highlighted = NO;
    TimeButton.selected = NO;
    TimeButton.highlighted = NO;
    HigherViewIsShow = NO;
    [UIView commitAnimations];
    FunctionViewIndex = -1;
    [ButtonWhiteBackground removeFromSuperview];
    [self RemoveFunctionView];
}

-(void)RemoveFunctionView
{
    [self setNeedsDisplay];
    [LastFunctionView removeFromSuperview];
}

-(void)DestinyStationBecomeStartStation
{
    [StationNameLabel removeGestureRecognizer:StartStationTap];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(AddButtonsAnimation)];
    [UIView setAnimationDuration:0.2];
    PriceLabel.alpha = 0;
    TimeLabel.alpha = 0;
    DollorLabel.alpha = 0;
    CardTypeLabel.alpha = 0;
    EstimateTimeLabel.alpha = 0;
    MinuteLabel.alpha = 0;
    ArrowImage.alpha = 0;
    StationNameLabel.alpha = 0;
    DestinyStationLabel.frame = CGRectMake(10, DestinyStationLabel.frame.origin.y, DestinyStationLabel.frame.size.width, DestinyStationLabel.frame.size.height);
    [UIView commitAnimations];
    StartStationNumber = DestinyStationNumber;
    StartStationName = DestinyStationName;
    StartStationColor = DestinyStationColor;
}

-(void)AddButtonWhiteBackground:(UIButton *)theButton
{
    if ([ButtonWhiteBackground superview] !=nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        ButtonWhiteBackground.center = theButton.center;
        [UIView commitAnimations];
    }else{
        ButtonWhiteBackground.frame = CGRectMake(theButton.frame.origin.x, theButton.frame.origin.y, IconSizeWidth, IconSizeHeight);
        [self addSubview:ButtonWhiteBackground];
    }
}

-(void)DismissIllustrationLabel
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:2];
    [UIView setAnimationDuration:0.4];
    IllustrationLabel.alpha = 0;
    [UIView commitAnimations];
}

#pragma mark - All about button touch method

-(void)ExitButtonPressed
{
    if (FunctionViewIndex != 0) {
        [CustomMapScrollView removeFromSuperview];
        [ExitInfosView removeFromSuperview];
        ExitInfosButton.selected = YES;
        ExitInfosButton.highlighted = YES;
        TransferButton.selected = NO;
        TransferButton.highlighted = NO;
        ShowInMapButton.selected = NO;
        ShowInMapButton.highlighted = NO;
        TimeButton.selected = NO;
        TimeButton.highlighted = NO;
        ShowHigherViewType = @"ExitInfos";
        if (!HigherViewIsShow) {
            ExitInfosView = [[theExitInfosView alloc] initWithFrame:CGRectMake(0, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-StatusBarHeight) AndStationNumber:StartStationNumber];
            [self addSubview:ExitInfosView];
            [self ShowHigherView];
            [self setNeedsDisplay];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                [MoveMRTMapDelegate MoveMRTMapScrollView:self];
        }else{
            ExitInfosView = [[theExitInfosView alloc] initWithFrame:CGRectMake(-self.bounds.size.width, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight) AndStationNumber:StartStationNumber];
            [self addSubview:ExitInfosView];
            [self SwitchFunction:ExitInfosView AndFunctionViewIndex:0];
        }
        [ExitInfosView setAutoresizesSubviews:YES];
        [ExitInfosView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        FunctionViewIndex = 0;
        LastFunctionView = ExitInfosView;
        [SetExitDelegate SetExitInfosView:self];
        [self AddButtonWhiteBackground:ExitInfosButton];
    }
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Station Function View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Exit Info Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

-(void)TransferButtonPressed
{
    if (FunctionViewIndex != 1) {
        [CustomMapScrollView removeFromSuperview];
        [TransferView removeFromSuperview];
        TransferButton.selected = YES;
        TransferButton.highlighted = YES;
        ExitInfosButton.selected = NO;
        ExitInfosButton.highlighted = NO;
        ShowInMapButton.selected = NO;
        ShowInMapButton.highlighted = NO;
        TimeButton.selected = NO;
        TimeButton.highlighted = NO;
        ShowHigherViewType = @"TransferInfos";
        if (!HigherViewIsShow) {
            TransferView = [[theTransferView alloc] initWithFrame:CGRectMake(0, FunctionViewHeight,self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-StatusBarHeight) AndStationNumber:StartStationNumber];
            [self addSubview:TransferView];
            [self ShowHigherView];
            [self setNeedsDisplay];
        }else{
            if (FunctionViewIndex - 1 > 0) {
                TransferView = [[theTransferView alloc] initWithFrame:CGRectMake(-self.bounds.size.width, FunctionViewHeight,self.bounds.size.width, self.bounds.size.height-FunctionViewHeight) AndStationNumber:StartStationNumber];
            }else{
                TransferView = [[theTransferView alloc] initWithFrame:CGRectMake(self.bounds.size.width, FunctionViewHeight,self.bounds.size.width, self.bounds.size.height-FunctionViewHeight) AndStationNumber:StartStationNumber];
            }
            [self addSubview:TransferView];
            [self SwitchFunction:TransferView AndFunctionViewIndex:1];
        }
        FunctionViewIndex = 1;
        LastFunctionView = TransferView;
        [SetTransferDelegate SetTransferView:self];
        [self AddButtonWhiteBackground:TransferButton];
    }
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Station Function View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Transfer Info Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

-(void)ShowInMapButtonPressed
{
    if (FunctionViewIndex != 2) {
        [CustomMapScrollView removeFromSuperview];
        [ShowInMapScrollView removeFromSuperview];
        ShowInMapButton.selected = YES;
        ShowInMapButton.highlighted = YES;
        ExitInfosButton.selected = NO;
        ExitInfosButton.highlighted = NO;
        TransferButton.selected = NO;
        TransferButton.highlighted = NO;
        TimeButton.selected = NO;
        TimeButton.highlighted = NO;
        ShowHigherViewType = @"ShowInMap";
        if (!HigherViewIsShow) {
            ShowInMapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-StatusBarHeight)];
            [self addSubview:ShowInMapScrollView];
            theShowStationInMapView *ShowStationInMapView = [[theShowStationInMapView alloc] initWithFrame:CGRectMake(0, 0, ShowInMapScrollView.bounds.size.width, ShowInMapScrollView.bounds.size.height+50) AndStationNumber:StartStationNumber];
            [ShowInMapScrollView addSubview:ShowStationInMapView];
            ShowInMapScrollView.contentSize = ShowStationInMapView.bounds.size;
            [self ShowHigherView];
            [self setNeedsDisplay];
        }else{
            if (FunctionViewIndex - 2 > 0) {
                ShowInMapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-self.bounds.size.width, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight)];
            }else{
                ShowInMapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.size.width, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight)];
            }
            [self addSubview:ShowInMapScrollView];
            theShowStationInMapView *ShowStationInMapView = [[theShowStationInMapView alloc] initWithFrame:CGRectMake(0, 0, ShowInMapScrollView.bounds.size.width, ShowInMapScrollView.bounds.size.height+50) AndStationNumber:StartStationNumber];
            [ShowInMapScrollView addSubview:ShowStationInMapView];
            ShowInMapScrollView.contentSize = ShowStationInMapView.bounds.size;
            [self SwitchFunction:ShowInMapScrollView AndFunctionViewIndex:2];
        }
        FunctionViewIndex = 2;
        LastFunctionView = ShowInMapScrollView;
        [self AddButtonWhiteBackground:ShowInMapButton];
    }
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Station Function View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Show In Map Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

-(void)TimeButtonPressed
{
    if (FunctionViewIndex != 3) {
        [CustomMapScrollView removeFromSuperview];
        [MRTTimeView removeFromSuperview];
        TimeButton.selected = YES;
        TimeButton.highlighted = YES;
        ExitInfosButton.selected = NO;
        ExitInfosButton.highlighted = NO;
        TransferButton.selected = NO;
        TransferButton.highlighted = NO;
        ShowInMapButton.selected = NO;
        ShowInMapButton.highlighted = NO;
        ShowHigherViewType = @"ShowTime";
        if (!HigherViewIsShow) {
            MRTTimeView = [[theMRTTime alloc] initWithFrame:CGRectMake(0, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight-StatusBarHeight) AndStationNumber:StartStationNumber];
            [self addSubview:MRTTimeView];
            [self ShowHigherView];
            [self setNeedsDisplay];
        }else{
            MRTTimeView = [[theMRTTime alloc] initWithFrame:CGRectMake(self.bounds.size.width, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight) AndStationNumber:StartStationNumber];
            [self addSubview:MRTTimeView];
            [self SwitchFunction:MRTTimeView AndFunctionViewIndex:3];
        }
        FunctionViewIndex = 3;
        LastFunctionView = MRTTimeView;
        [self AddButtonWhiteBackground:TimeButton];
    }
    
    //Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Station Function View"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"Pressed"
                                                           label:@"Time Table Button"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

-(void)SwitchFunction:(UIView *)SelectedFunctionView AndFunctionViewIndex:(int)Index
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [MoveMRTMapDelegate MoveMRTMapScrollView:self];
    [ExitInfosView LeftSwipe];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (Index - FunctionViewIndex > 0) {
        SelectedFunctionView.frame = CGRectMake(0, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight);
        LastFunctionView.center = CGPointMake(-LastFunctionView.frame.size.width/2, LastFunctionView.center.y);
    }else{
        SelectedFunctionView.frame = CGRectMake(0, FunctionViewHeight, self.bounds.size.width, self.bounds.size.height-FunctionViewHeight);
        LastFunctionView.center = CGPointMake(self.frame.size.width+LastFunctionView.frame.size.width/2, LastFunctionView.center.y);
    }
    [UIView commitAnimations];
}

#pragma mark - All about touch method

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    TouchBeganPoint = [[touches anyObject] locationInView:self.superview];
    TouchDistanceToOrigin = fabsf(self.frame.origin.y - TouchBeganPoint.y);
    TouchBeganTimeStamp = event.timestamp;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (TouchBeganPoint.y-[[touches anyObject] locationInView:self.superview].y>StatusBarHeight && [ShowHigherViewType isEqualToString:@"PathFindingResults"]) {
            //up
            if (!HigherViewIsShow)
                [self ShowHigherView];
            if ([[touches anyObject] locationInView:self.superview].y-TouchDistanceToOrigin > StatusBarHeight)
                self.frame = CGRectMake(0, [[touches anyObject] locationInView:self.superview].y-TouchDistanceToOrigin, self.frame.size.width, self.frame.size.height);
            else
                self.frame = CGRectMake(0, StatusBarHeight, self.frame.size.width, self.frame.size.height);
        }else{
            //down
            if (self.frame.origin.y < self.superview.frame.size.height-FunctionViewHeight){
                if ([[touches anyObject] locationInView:self.superview].y-TouchDistanceToOrigin > StatusBarHeight){
                    self.frame = CGRectMake(0, [[touches anyObject] locationInView:self.superview].y-TouchDistanceToOrigin, self.frame.size.width, self.frame.size.height);
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                        [ChangeStatusBarColorDelegate ChangeStatusBarColor:self AndColorName:@"dark gray"];
                }else{
                    self.frame = CGRectMake(0, StatusBarHeight, self.frame.size.width, self.frame.size.height);
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                        [ChangeStatusBarColorDelegate ChangeStatusBarColor:self AndColorName:StartStationColor];
                }
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (TouchBeganPoint.y-[[touches anyObject] locationInView:self.superview].y> StatusBarHeight) {
            //up
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            if (self.frame.origin.y > self.superview.frame.size.height/2)
                self.frame = CGRectMake(0, self.superview.frame.size.height-FunctionViewHeight, self.frame.size.width, self.frame.size.height);
            else{
                self.frame = CGRectMake(0, StatusBarHeight, self.frame.size.width, self.frame.size.height);
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                    [ChangeStatusBarColorDelegate ChangeStatusBarColor:self AndColorName:StartStationColor];
            }
            [UIView commitAnimations];
        }else{
            //down
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            if (self.frame.origin.y < self.superview.frame.size.height/4){
                self.frame = CGRectMake(0, StatusBarHeight, self.frame.size.width, self.frame.size.height);
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                    [ChangeStatusBarColorDelegate ChangeStatusBarColor:self AndColorName:StartStationColor];
            }else{
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(DismissHigherView)];
                self.frame = CGRectMake(0, self.superview.frame.size.height-FunctionViewHeight, self.frame.size.width, self.frame.size.height);
            }
            [UIView commitAnimations];
        }
    }
}

@end
