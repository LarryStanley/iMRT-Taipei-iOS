//
//  CustomMRTMap.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/4/15.
//
//

#import "CustomMRTMap.h"
#import "theColor.h"
#import "theLineIllustrator.h"

@implementation CustomMRTMap
@synthesize MapSize;

- (id)initWithFrame:(CGRect)frame AndPathFindingResults:(NSArray *)Results
{
    self = [super initWithFrame:frame];
    if (self) {
        PathFindingResults = [[NSMutableArray alloc] initWithArray:[[Results reverseObjectEnumerator] allObjects]];
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"BackgroundColor"] isEqualToString:@"WhiteBackground"])
            self.backgroundColor = [theColor WhiteBackground];
        else
            self.backgroundColor = [UIColor clearColor];
        SQLite = [theSQLite new];
        AllStationCoordinate = [[NSMutableArray alloc] initWithArray:[SQLite ReturnPointData:@"select * from Map order by StationNumber ASC" andIndexOFColumn:3]];
        AllStationType = [[NSMutableArray alloc] initWithArray:[SQLite ReturnTableData:@"select * from Map order by StationNumber ASC " andIndexOFColumn:2]];
        AllStationColor = [[NSMutableArray alloc]initWithArray:[SQLite ReturnTableData:@"select * from Map order by StationNumber ASC" andIndexOFColumn:18]];
        AllStationName = [[NSMutableArray alloc] initWithArray:[SQLite ReturnTableData:@"select * from Map order by StationNumber ASC" andIndexOFColumn:1]];
        AllStationLabelType = [[NSMutableArray alloc] initWithArray:[SQLite ReturnTableData:@"select * from Map order by StationNumber ASC" andIndexOFColumn:5]];
        AllMRTMapData = [[NSMutableArray alloc] initWithArray:[SQLite ReturnMultiRowsData:@"select * from Map order by StationNumber ASC" andIndexOFColumn:CGPointMake(6, 17)]];
        [self CalculateFirstPoint];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSMutableArray *allIllustrationData = [NSMutableArray new];
    for (int i = 0; i < [PathFindingResults count]; i++) {
        int CurrentStationNumber = [[PathFindingResults objectAtIndex:i] intValue];
        int NextStationNumber;
        NSString *StationIndex = [NSString stringWithFormat:@"%i",CurrentStationNumber];
        if (i == [PathFindingResults count]-1){
            [self DrawCircle:[[AllStationType objectAtIndex:CurrentStationNumber] intValue] Color:[AllStationColor objectAtIndex:CurrentStationNumber] Coordinate:CGPointMake(50, 30+80*i)];
            [self AddLabel:2 Name:NSLocalizedString(StationIndex, nil) Coordinate:CGPointMake(50, 30+80*i) DrawCircleTyp:[[AllStationType objectAtIndex:CurrentStationNumber] intValue]];
            CGSize StationLabelSize = [NSLocalizedString(StationIndex, nil) sizeWithFont:[UIFont systemFontOfSize:15]];
            theLineIllustrator *LineIllustrator = [[theLineIllustrator alloc] initWithFrame:CGRectMake(50+StationLabelSize.width+20, 30+80*i-20, 220-StationLabelSize.width, 40) AndText:NSLocalizedString(@"Destination", nil)];
            [self addSubview:LineIllustrator];
            break;
        }else
            NextStationNumber = [[PathFindingResults objectAtIndex:i+1] intValue];
        for (int j = 0; j < 10; j = j+3) {
            if ([[[AllMRTMapData objectAtIndex:CurrentStationNumber] objectAtIndex:j] intValue] == NextStationNumber){
                [self DrawLine:[[[AllMRTMapData objectAtIndex:CurrentStationNumber] objectAtIndex:j+1] intValue] Color:[[AllMRTMapData objectAtIndex:CurrentStationNumber] objectAtIndex:j+2] Start:CGPointMake(50, 30+80*i)
                           Destiny:CGPointMake(50, 110+80*i)];
                break;
            }
        }
        
        //關於轉乘、起點的注解
        if (i == 0) {
            CGSize StationLabelSize = [NSLocalizedString(StationIndex, nil) sizeWithFont:[UIFont systemFontOfSize:15]];
            NSMutableArray *DirectionData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from Direction where StationNumber = %i and ConnectStationNumber = %i",[[PathFindingResults objectAtIndex:0] intValue],[[PathFindingResults objectAtIndex:1] intValue]] andIndexOFColumn:CGPointMake(0, 4)];
            /*theLineIllustrator *LineIllustrator = [[theLineIllustrator alloc] initWithFrame:CGRectMake(50+StationLabelSize.width+20, 30+80*i-20, 220-StationLabelSize.width, 40) AndText:[NSString stringWithFormat:NSLocalizedString(@"MRTToward", nil),NSLocalizedString([[DirectionData objectAtIndex:0]objectAtIndex:3], nil)]];
            [self addSubview:LineIllustrator];*/
            NSLog(@"%@",[[DirectionData objectAtIndex:0]objectAtIndex:3]);
            [allIllustrationData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:CGRectMake(50+StationLabelSize.width+20, 30+80*i-20, 220-StationLabelSize.width, 40)], @"frame", [NSString stringWithFormat:NSLocalizedString(@"MRTToward", nil),NSLocalizedString([[DirectionData objectAtIndex:0]objectAtIndex:3], nil)], @"text",nil]];
        }else if (i != [PathFindingResults count]-1){
            NSMutableArray *CurrentDirectionData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from Direction where StationNumber = %i and ConnectStationNumber = %i",[[PathFindingResults objectAtIndex:i] intValue],[[PathFindingResults objectAtIndex:i+1] intValue]] andIndexOFColumn:CGPointMake(0, 4)];
            NSMutableArray *LastDirectionData = [SQLite ReturnMultiRowsData:[NSString stringWithFormat:@"select * from Direction where StationNumber = %i and ConnectStationNumber = %i",[[PathFindingResults objectAtIndex:i-1] intValue],[[PathFindingResults objectAtIndex:i] intValue]] andIndexOFColumn:CGPointMake(0, 4)];
            if (![[[LastDirectionData objectAtIndex:0]objectAtIndex:3] isEqual:[[CurrentDirectionData objectAtIndex:0]objectAtIndex:3]]) {
                BOOL havedChangeLastStation = NO;
                for (int j = 0; j < [CurrentDirectionData count]; j++) {
                    if ([[[allIllustrationData objectAtIndex:[allIllustrationData count]-1] objectForKey:@"text"] rangeOfString:[[CurrentDirectionData objectAtIndex:j]objectAtIndex:4]].location != NSNotFound) {
                        [allIllustrationData replaceObjectAtIndex:[allIllustrationData count]-1
                                                       withObject:[NSDictionary dictionaryWithObjectsAndKeys:[[allIllustrationData objectAtIndex:[allIllustrationData count]-1] objectForKey:@"frame"], @"frame",                                [NSString stringWithFormat:NSLocalizedString(@"MRTToward", nil),NSLocalizedString([[CurrentDirectionData objectAtIndex:j]objectAtIndex:4], nil)], @"text",nil]];
                        NSLog(@"%@,%@",NSLocalizedString(StationIndex, nil),[[CurrentDirectionData objectAtIndex:j]objectAtIndex:4]);
                        havedChangeLastStation = YES;
                        break;
                    }
                }
                if (!havedChangeLastStation){
                    CGSize StationLabelSize = [NSLocalizedString(StationIndex, nil) sizeWithFont:[UIFont systemFontOfSize:15]];
                    /*theLineIllustrator *LineIllustrator = [[theLineIllustrator alloc] initWithFrame:CGRectMake(50+StationLabelSize.width+20, 30+80*i-20, 220-StationLabelSize.width, 40) AndText:[NSString stringWithFormat:NSLocalizedString(@"MRTToward", nil),NSLocalizedString([[CurrentDirectionData objectAtIndex:0]objectAtIndex:3], nil)]];
                    [self addSubview:LineIllustrator];*/
                    [allIllustrationData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:CGRectMake(50+StationLabelSize.width+20, 30+80*i-20, 220-StationLabelSize.width, 40)], @"frame", [NSString stringWithFormat:NSLocalizedString(@"MRTToward", nil),NSLocalizedString([[CurrentDirectionData objectAtIndex:0]objectAtIndex:3], nil)], @"text",nil]];
                }
            }
        }
        
        [self DrawCircle:[[AllStationType objectAtIndex:CurrentStationNumber] intValue] Color:[AllStationColor objectAtIndex:CurrentStationNumber] Coordinate:CGPointMake(50, 30+80*i)];
        [self AddLabel:2 Name:NSLocalizedString(StationIndex, nil) Coordinate:CGPointMake(50, 30+80*i) DrawCircleTyp:[[AllStationType objectAtIndex:CurrentStationNumber] intValue]];
    }
    
    for (int i = 0; i < [allIllustrationData count]; i++) {
        NSDictionary *tempData = [allIllustrationData objectAtIndex:i];
        theLineIllustrator *lineIllustrator = [[theLineIllustrator alloc] initWithFrame:[[tempData objectForKey:@"frame"] CGRectValue] AndText:[tempData objectForKey:@"text"]];
        [self addSubview:lineIllustrator];
    }
}


-(void)DrawLine:(int)Type Color:(NSString *)ColorName Start:(CGPoint)StartCoordinate Destiny:(CGPoint)DestinyCoordinate
{
    StartCoordinate = [self ConvertStationCoordinate:StartCoordinate];
    DestinyCoordinate = [self ConvertStationCoordinate:DestinyCoordinate];
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (Type) {
        default:
            CGContextSetLineWidth(context, 9);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, StartCoordinate.x, StartCoordinate.y);
            CGContextAddLineToPoint(context, DestinyCoordinate.x, DestinyCoordinate.y);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            [[UIColor grayColor] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
    }
}

-(void)DrawCircle:(int)Type Color:(NSString *)ColorName Coordinate:(CGPoint)StationCoordinate
{
    UIColor *theGray = [UIColor colorWithRed:66/255.f green:72/255.f blue:76/255.f alpha:1.0];
    StationCoordinate = [self ConvertStationCoordinate:StationCoordinate];
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (Type) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
            CGContextSetLineWidth(context, 1.5);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 5, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            CGContextSetStrokeColorWithColor(context, [self RGBColor:ColorName]);
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"BackgroundColor"] isEqualToString:@"WhiteBackground"])
                [[theColor WhiteBackground] setFill];
            else
                [theGray setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case 5:
        case 9:
            CGContextSetLineWidth(context, 3);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 15, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            [[UIColor blackColor] setStroke];
            [[theColor WhiteBackground] setFill];
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
            [[UIColor blackColor] setStroke];
            [[theColor WhiteBackground] setFill];
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
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 15, 0, 2*M_PI, YES);
            CGContextClosePath(context);
            [[UIColor blackColor] setStroke];
            [[theColor WhiteBackground] setFill];
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextSetLineWidth(context, 0);
            CGContextBeginPath(context);
            CGContextAddArc(context, StationCoordinate.x, StationCoordinate.y, 8, 0, 2*M_PI, YES);
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
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"BackgroundColor"] isEqualToString:@"WhiteBackground"])
        StationNameLabel.textColor = [UIColor blackColor];
    else
        StationNameLabel.textColor = [UIColor whiteColor];
    StationNameLabel.font = [UIFont systemFontOfSize:15];
    StationNameLabel.text = StationName;
    [StationNameLabel sizeToFit];
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

#pragma mark - All about compute

-(CGPoint)ConvertStationCoordinate:(CGPoint)OriginalCoordinate
{
    return OriginalCoordinate;
}

-(void)CalculateFirstPoint
{
    MapSize = CGPointMake(320, [PathFindingResults count]*80+40);
}

@end
