//
//  MRTMap.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/15.
//
//

#import "MRTMap.h"
#import "theColor.h"
#import "StationFunctionView.h"
#import "MainViewController.h"
#define NSLog(FORMAT, ...) fprintf( stderr, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String] );
@implementation MRTMap
@synthesize AllStationCoordinate,ShowFunctionDelegate,DismissFunctionDelegate,DoubleTapPoint;
- (id)initWithFrame:(CGRect)frame AndSuperView:(UIView *)theView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        SQLite = [theSQLite new];
        AllStationCoordinate = [[NSMutableArray alloc] initWithArray:[SQLite ReturnPointData:@"select * from Map" andIndexOFColumn:3]];
        AllStationType = [[NSMutableArray alloc] initWithArray:[SQLite ReturnTableData:@"select * from Map" andIndexOFColumn:2]];
        AllStationColor = [[NSMutableArray alloc]initWithArray:[SQLite ReturnTableData:@"select * from Map" andIndexOFColumn:18]];
        AllStationName = [[NSMutableArray alloc] initWithArray:[SQLite ReturnTableData:@"select * from Map" andIndexOFColumn:1]];
        AllStationLabelType = [[NSMutableArray alloc] initWithArray:[SQLite ReturnTableData:@"select * from Map" andIndexOFColumn:5]];
        AllMRTMapData = [[NSMutableArray alloc] initWithArray:[SQLite ReturnMultiRowsData:@"select * from Map" andIndexOFColumn:CGPointMake(6, 17)]];
        theSuperView = theView;
        FunctionViewIsShow = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i < [AllStationType count]; i++) {
        for (int j = 0; j < 10; j = j+3) {
            if ([[[AllMRTMapData objectAtIndex:i] objectAtIndex:j] intValue] == -1)
                break;
            else{
                if ([[[AllMRTMapData objectAtIndex:i] objectAtIndex:j] intValue] > i) {
                    if ([[AllStationType objectAtIndex:i] intValue] == 7)
                        [self DrawLine:[[[AllMRTMapData objectAtIndex:i] objectAtIndex:j+1] intValue] Color:[[AllMRTMapData objectAtIndex:i] objectAtIndex:j+2] Start:CGPointMake([[AllStationCoordinate objectAtIndex:i] CGPointValue].x-0.05656, [[AllStationCoordinate objectAtIndex:i] CGPointValue].y+0.05656)
                               Destiny:[[AllStationCoordinate objectAtIndex:[[[AllMRTMapData objectAtIndex:i] objectAtIndex:j] intValue]]CGPointValue]];
                    else
                        [self DrawLine:[[[AllMRTMapData objectAtIndex:i] objectAtIndex:j+1] intValue] Color:[[AllMRTMapData objectAtIndex:i] objectAtIndex:j+2] Start:[[AllStationCoordinate objectAtIndex:i] CGPointValue]
                           Destiny:[[AllStationCoordinate objectAtIndex:[[[AllMRTMapData objectAtIndex:i] objectAtIndex:j] intValue]]CGPointValue]];
                }
            }
        }
    }
    for (int i = 0; i < [AllStationType count]; i++) {
        [self DrawCircle:[[AllStationType objectAtIndex:i] intValue] Color:[AllStationColor objectAtIndex:i] Coordinate:[[AllStationCoordinate objectAtIndex:i] CGPointValue]];
        NSString *StationIndex = [NSString stringWithFormat:@"%i",i];
        [self AddLabel:[[AllStationLabelType objectAtIndex:i] intValue] Name:NSLocalizedString(StationIndex, nil) Coordinate:[[AllStationCoordinate objectAtIndex:i] CGPointValue] DrawCircleTyp:[[AllStationType objectAtIndex:i] intValue]];
    }
}

-(void)DrawLine:(int)Type Color:(NSString *)ColorName Start:(CGPoint)StartCoordinate Destiny:(CGPoint)DestinyCoordinate
{
    UIBezierPath *CurvePath = [UIBezierPath bezierPath];
    StartCoordinate = [self ConvertStationCoordinate:StartCoordinate];
    DestinyCoordinate = [self ConvertStationCoordinate:DestinyCoordinate];
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (Type) {
        case 0:
            CGContextSetLineWidth(context, 9);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, StartCoordinate.x, StartCoordinate.y);
            CGContextAddLineToPoint(context, DestinyCoordinate.x, DestinyCoordinate.y);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[UIColor grayColor] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 1:
            if (!(StartCoordinate.x-DestinyCoordinate.x)) {
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x+6, StartCoordinate.y);
                CGContextAddLineToPoint(context, DestinyCoordinate.x+6, DestinyCoordinate.y);
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x-6, StartCoordinate.y);
                CGContextAddLineToPoint(context, DestinyCoordinate.x-6, DestinyCoordinate.y);
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
            }else if (!(StartCoordinate.y-DestinyCoordinate.y)){
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x, StartCoordinate.y+6);
                CGContextAddLineToPoint(context, DestinyCoordinate.x, DestinyCoordinate.y+6);
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x, StartCoordinate.y-6);
                CGContextAddLineToPoint(context, DestinyCoordinate.x, DestinyCoordinate.y-6);
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
            }else if (((StartCoordinate.y-DestinyCoordinate.y)/(StartCoordinate.x-DestinyCoordinate.x))<0){
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x-(3*sqrt(2)), StartCoordinate.y-(3*sqrt(2)));
                CGContextAddLineToPoint(context, DestinyCoordinate.x-(3*sqrt(2)), DestinyCoordinate.y-(3*sqrt(2)));
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x+(3*sqrt(2)), StartCoordinate.y+(3*sqrt(2)));
                CGContextAddLineToPoint(context, DestinyCoordinate.x+(3*sqrt(2)), DestinyCoordinate.y+(3*sqrt(2)));
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
            }else if (((StartCoordinate.y-DestinyCoordinate.y)/(StartCoordinate.x-DestinyCoordinate.x))>0){
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x+(3*sqrt(2)), StartCoordinate.y-(3*sqrt(2)));
                CGContextAddLineToPoint(context, DestinyCoordinate.x+(3*sqrt(2)), DestinyCoordinate.y-(3*sqrt(2)));
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextSetLineWidth(context, 9);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, StartCoordinate.x-(3*sqrt(2)), StartCoordinate.y+(3*sqrt(2)));
                CGContextAddLineToPoint(context, DestinyCoordinate.x-(3*sqrt(2)), DestinyCoordinate.y+(3*sqrt(2)));
                CGContextClosePath(context);
                CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
                [[UIColor grayColor] setFill];
                CGContextDrawPath(context, kCGPathFillStroke);
            }
            break;
        case 2:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            if (StartCoordinate.y < DestinyCoordinate.y)
                [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x ,DestinyCoordinate.y-6) controlPoint:CGPointMake(StartCoordinate.x+(DestinyCoordinate.x-StartCoordinate.x)/4, DestinyCoordinate.y-6)];
            else
                [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x ,DestinyCoordinate.y+6) controlPoint:CGPointMake(StartCoordinate.x+(DestinyCoordinate.x-StartCoordinate.x)/4, DestinyCoordinate.y+6)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 3:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(DestinyCoordinate.x, StartCoordinate.y)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 4:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(StartCoordinate.x, DestinyCoordinate.y)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 5:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x, StartCoordinate.y-6)];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x+6, DestinyCoordinate.y) controlPoint:CGPointMake(DestinyCoordinate.x+6, StartCoordinate.y-6)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x, StartCoordinate.y+6)];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x-6, DestinyCoordinate.y) controlPoint:CGPointMake(DestinyCoordinate.x-6, StartCoordinate.y+6)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 6:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addCurveToPoint:DestinyCoordinate controlPoint1:CGPointMake(StartCoordinate.x, (StartCoordinate.y+DestinyCoordinate.y)/2) controlPoint2:CGPointMake(DestinyCoordinate.x, (StartCoordinate.y+DestinyCoordinate.y)/2)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 7:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(StartCoordinate.x-(StartCoordinate.x-DestinyCoordinate.x)/4, DestinyCoordinate.y)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 8:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(StartCoordinate.x-3*(StartCoordinate.x-DestinyCoordinate.x)/4, StartCoordinate.y)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 9:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addLineToPoint:CGPointMake(StartCoordinate.x, StartCoordinate.y-(StartCoordinate.y-DestinyCoordinate.y)/2)];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(StartCoordinate.x, StartCoordinate.y-(StartCoordinate.y-DestinyCoordinate.y)/4*3)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 10:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x-6, StartCoordinate.y)];
            [CurvePath addLineToPoint:CGPointMake(StartCoordinate.x-6, StartCoordinate.y-(StartCoordinate.y-DestinyCoordinate.y)/2)];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x-3*sqrt(2), DestinyCoordinate.y-3*sqrt(2)) controlPoint:CGPointMake(StartCoordinate.x-7, StartCoordinate.y-(StartCoordinate.y-DestinyCoordinate.y)/4*3-2*sqrt(2))];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x+6, StartCoordinate.y)];
            [CurvePath addLineToPoint:CGPointMake(StartCoordinate.x+6, StartCoordinate.y-(StartCoordinate.y-DestinyCoordinate.y)/2)];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x+3*sqrt(2), DestinyCoordinate.y+3*sqrt(2)) controlPoint:CGPointMake(StartCoordinate.x+6, StartCoordinate.y-(StartCoordinate.y-DestinyCoordinate.y)/4*3)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 11:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(DestinyCoordinate.x, StartCoordinate.y+(DestinyCoordinate.y-StartCoordinate.y)/2)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 12:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:StartCoordinate];
            [CurvePath addLineToPoint:CGPointMake(StartCoordinate.x-(StartCoordinate.x-DestinyCoordinate.x)/4*3, StartCoordinate.y)];
            [CurvePath addQuadCurveToPoint:DestinyCoordinate controlPoint:CGPointMake(DestinyCoordinate.x, StartCoordinate.y)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 13:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x+3*sqrt(2), StartCoordinate.y-3*sqrt(2))];
            //[CurvePath addLineToPoint:CGPointMake(StartCoordinate.x+(DestinyCoordinate.x-StartCoordinate.x)/2+3*sqrt(2), StartCoordinate.y+(DestinyCoordinate.x-StartCoordinate.x)/2-3*sqrt(2))];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x+6, DestinyCoordinate.y) controlPoint:CGPointMake(DestinyCoordinate.x+7,StartCoordinate.y-3*sqrt(2)-(StartCoordinate.y-3*sqrt(2) - DestinyCoordinate.y)/6*5)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x-3*sqrt(2), StartCoordinate.y+3*sqrt(2))];
            //[CurvePath addLineToPoint:CGPointMake(StartCoordinate.x+(DestinyCoordinate.x-StartCoordinate.x)/2-3*sqrt(2), StartCoordinate.y+(DestinyCoordinate.x-StartCoordinate.x)/2+3*sqrt(2))];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x-6, DestinyCoordinate.y) controlPoint:CGPointMake(DestinyCoordinate.x-10,StartCoordinate.y+3*sqrt(2)-(StartCoordinate.y+3*sqrt(2) - DestinyCoordinate.y)/6*5)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        case 14:
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x-(3*sqrt(2)), StartCoordinate.y-(3*sqrt(2)))];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x-6, DestinyCoordinate.y) controlPoint:CGPointMake(DestinyCoordinate.x-6, StartCoordinate.y-(3*sqrt(2))+(DestinyCoordinate.y-StartCoordinate.y)/5*3)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            CurvePath.lineWidth = 9;
            [CurvePath moveToPoint:CGPointMake(StartCoordinate.x+(3*sqrt(2)), StartCoordinate.y+(3*sqrt(2)))];
            [CurvePath addQuadCurveToPoint:CGPointMake(DestinyCoordinate.x+6, DestinyCoordinate.y) controlPoint:CGPointMake(DestinyCoordinate.x+6, StartCoordinate.y+(3*sqrt(2))+(DestinyCoordinate.y-StartCoordinate.y)/5*3)];
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [CurvePath stroke];
            break;
        default:
            break;
    }
}

-(void)DrawCircle:(int)Type Color:(NSString *)ColorName Coordinate:(CGPoint)StationCoordinate
{
    StationCoordinate = [self ConvertStationCoordinate:StationCoordinate];
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (Type) {
        case 0:
            CGContextSetLineWidth(context, 1.5);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 5, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[theColor ClassicGrayBackground] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 1:
            CGContextSetLineWidth(context, 1.5);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x+5, StationCoordinate.y, 5, 3*M_PI/2, M_PI/2, 0);
            CGContextAddArc(context, StationCoordinate.x-5, StationCoordinate.y, 5, M_PI/2, 3*M_PI/2, 0);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[theColor ClassicGrayBackground] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 2:
            CGContextSetLineWidth(context, 1.5);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x+5/sqrt(2), StationCoordinate.y-5/sqrt(2), 5, -3*M_PI/4, -7*M_PI/4, 0);
            CGContextAddArc(context, StationCoordinate.x-5/sqrt(2), StationCoordinate.y+5/sqrt(2), 5, -7*M_PI/4, -3*M_PI/4, 0);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[theColor ClassicGrayBackground] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 3:
            CGContextSetLineWidth(context, 1.5);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x-5/sqrt(2), StationCoordinate.y-5/sqrt(2), 5, -M_PI/4, -5*M_PI/4, 1);
            CGContextAddArc(context, StationCoordinate.x+5/sqrt(2), StationCoordinate.y+5/sqrt(2), 5, -5*M_PI/4, -M_PI/4, 1);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[theColor ClassicGrayBackground] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 4:
            CGContextSetLineWidth(context, 1.5);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y-5, 5, 0, M_PI, 1);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y+5, 5, M_PI, 0, 1);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[theColor ClassicGrayBackground] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 5:
            CGContextSetLineWidth(context, 3);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 15, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            [[UIColor blackColor] setStroke];
            [[UIColor whiteColor] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 8, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            [[UIColor blackColor] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 6:
            CGContextSetLineWidth(context, 3);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y-10, 10, 0, M_PI, 1);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y+10, 10, M_PI, 0, 1);
            CGContextClosePath(context);
            [[UIColor whiteColor] setFill];
            [[UIColor blackColor] setStroke];
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y-10, 5, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, [self RGBColor:@"brown"]);
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y+10, 5, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, [self RGBColor:@"blue"]);
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 7:
            CGContextSetLineWidth(context, 3);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x+10/sqrt(2), StationCoordinate.y-10/sqrt(2), 10, -3*M_PI/4, -7*M_PI/4, 0);
            CGContextAddArc(context, StationCoordinate.x-10/sqrt(2), StationCoordinate.y+10/sqrt(2), 10, -7*M_PI/4, -3*M_PI/4, 0);
            CGContextClosePath(context);
            [[UIColor whiteColor] setFill];
            [[UIColor blackColor] setStroke];
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x+10/sqrt(2), StationCoordinate.y-10/sqrt(2), 5, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, [self RGBColor:@"dark green"]);
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 8:
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 13, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetFillColorWithColor(context, [self RGBColor:ColorName]);
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        default:
            break;
    }
}

-(void)AddLabel:(int)Type Name:(NSString *)StationName Coordinate:(CGPoint)StationCoordinate DrawCircleTyp:(int)CircleType
{
    UILabel *StationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15*[StationName length], 15)];
    StationNameLabel.backgroundColor = [UIColor clearColor];
    StationNameLabel.textColor = [UIColor whiteColor];
    StationNameLabel.font = [UIFont systemFontOfSize:15];
    StationNameLabel.text = StationName;
    [StationNameLabel sizeToFit];
    if (StationNameLabel.frame.size.width>80) {
        StationNameLabel.numberOfLines = 0;
        StationNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        StationNameLabel.adjustsFontSizeToFitWidth = NO;
        switch (Type) {
            case 1:
            case 2:
            case 3:
                StationNameLabel.textAlignment = UITextAlignmentLeft;
                break;
            case 5:
            case 6:
            case 7:
                StationNameLabel.textAlignment = UITextAlignmentRight;
                break;
            default:
                StationNameLabel.textAlignment = UITextAlignmentCenter;
                break;
        }
        CGSize LabelSize;
        if ([StationName isEqualToString:@"Taipei Nangang Exhibition Center"] || [StationName isEqualToString:@"Sanchong Elementary School"] || [StationName isEqualToString:@"Zhongshan Elementary School"] || [StationName isEqualToString:@"Zhongshan Junior High School"])
            LabelSize = [StationName sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(130, 40) lineBreakMode:NSLineBreakByTruncatingTail];
        else
            LabelSize = [StationName sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(115, 40) lineBreakMode:NSLineBreakByTruncatingTail];
        StationNameLabel.frame = CGRectMake(self.bounds.size.width, 5, LabelSize.width, LabelSize.height);
        StationNameLabel.adjustsFontSizeToFitWidth = YES;
    }
    StationCoordinate = [self ConvertStationCoordinate:StationCoordinate];
    switch (Type) {
        case 0:
            if (CircleType < 5)
                StationNameLabel.center = CGPointMake(StationCoordinate.x, StationCoordinate.y-StationNameLabel.frame.size.height/2-10);
            else
                StationNameLabel.center = CGPointMake(StationCoordinate.x, StationCoordinate.y-StationNameLabel.frame.size.height/2-15);
            if ([StationName isEqualToString:@"古亭"] || [StationName isEqualToString:@"Guting"])
                StationNameLabel.center = CGPointMake(StationCoordinate.x, StationCoordinate.y-StationNameLabel.frame.size.height/2-25);
            break;
        case 1:
            if (CircleType < 5)
                StationNameLabel.frame = CGRectMake(StationCoordinate.x+5, StationCoordinate.y-StationNameLabel.frame.size.height-10, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            else
                StationNameLabel.frame = CGRectMake(StationCoordinate.x+15, StationCoordinate.y-StationNameLabel.frame.size.height-15, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            break;
        case 2:
            if (CircleType < 5)
                StationNameLabel.center = CGPointMake(StationCoordinate.x+15+StationNameLabel.frame.size.width/2, StationCoordinate.y);
            else
                StationNameLabel.center = CGPointMake(StationCoordinate.x+20+StationNameLabel.frame.size.width/2, StationCoordinate.y);
            break;
        case 3:
            if (CircleType < 5)
                StationNameLabel.frame = CGRectMake(StationCoordinate.x+5, StationCoordinate.y+10, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            else
                StationNameLabel.frame = CGRectMake(StationCoordinate.x+15, StationCoordinate.y+15, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            break;
        case 4:
            if (CircleType < 5)
                StationNameLabel.center = CGPointMake(StationCoordinate.x, StationCoordinate.y+StationNameLabel.frame.size.height/2+10);
            else
                StationNameLabel.center = CGPointMake(StationCoordinate.x, StationCoordinate.y+StationNameLabel.frame.size.height/2+20);
            break;
        case 5:
            if (CircleType < 5)
                StationNameLabel.frame = CGRectMake(StationCoordinate.x-StationNameLabel.frame.size.width-5, StationCoordinate.y+10, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            else
                StationNameLabel.frame = CGRectMake(StationCoordinate.x-StationNameLabel.frame.size.width-15, StationCoordinate.y+10, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            break;
        case 6:
            StationNameLabel.center = CGPointMake(StationCoordinate.x-15-StationNameLabel.frame.size.width/2, StationCoordinate.y);
            break;
        case 7:
            if (CircleType < 5)
                StationNameLabel.frame = CGRectMake(StationCoordinate.x-StationNameLabel.frame.size.width-5, StationCoordinate.y-StationNameLabel.frame.size.height-10, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            else
                StationNameLabel.frame = CGRectMake(StationCoordinate.x-StationNameLabel.frame.size.width-15, StationCoordinate.y-StationNameLabel.frame.size.height-15, StationNameLabel.frame.size.width, StationNameLabel.frame.size.height);
            break;
        default:
            break;
    }
    [self addSubview:StationNameLabel];
}

-(CGColorRef)RGBColor:(NSString *)ColorName
{
    UIColor *Color;
    if ([ColorName isEqualToString:@"blue"])
        Color = [UIColor colorWithRed:12/255.f green:100/255.f blue:175/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"brown"])
        Color = [UIColor colorWithRed:173/255.f green:109/255.f blue:46/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"orange"])
        Color = [UIColor colorWithRed:249/255.f green:162/255.f blue:41/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"red"])
        Color = [UIColor colorWithRed:226/255.f green:3/255.f blue:46/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"dark green"])
        Color = [UIColor colorWithRed:16/255.f green:122/255.f blue:27/255.f alpha:1.0];
    else if ([ColorName isEqualToString:@"green"])
        Color = [UIColor colorWithRed:208/255.f green:220/255.f blue:48/255.f alpha:1.0];
    else //pink
        Color = [UIColor colorWithRed:242/255.f green:140/255.f blue:149/255.f alpha:1.0];
    CGColorRef CGColor = CGColorRetain(Color.CGColor);
    Color = nil;
    return CGColor;
    CGColorRelease(CGColor);
}

#pragma mark All about touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint TouchLoaction = [touch locationInView:self];
    DoubleTapPoint = TouchLoaction;
    for (int i = 0; i < [AllStationCoordinate count]; i++) {
        if ([self ComputeDistance:TouchLoaction andDestiny:[self ConvertStationCoordinate:[[AllStationCoordinate objectAtIndex:i] CGPointValue]]] < 40) {
            NSString *StationIndex = [NSString stringWithFormat:@"%i",i];
            [ShowFunctionDelegate ShowFunctionView:self AndStationNameIndex:i AndStationName:NSLocalizedString(StationIndex, nil) AndStationColor:[AllStationColor objectAtIndex:i]];
            break;
        }
        if (i == [AllStationCoordinate count]-1) {
            [DismissFunctionDelegate DismissFunctionView:self];
        }
    }
}

#pragma mark All about compute

-(CGPoint)ConvertStationCoordinate:(CGPoint)OriginalCoordinate
{
    return CGPointMake((OriginalCoordinate.x+6.5)*75 + 160, (OriginalCoordinate.y+12.5)*75+ 240);
}

-(float)ComputeDistance:(CGPoint)StartCoordinate andDestiny:(CGPoint)DestinyCoordinate
{
    float Distance = 10000;
    Distance = sqrt(pow((StartCoordinate.x - DestinyCoordinate.x),2) + pow((StartCoordinate.y - DestinyCoordinate.y),2));
    return Distance;
}

@end
