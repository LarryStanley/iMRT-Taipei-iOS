//
//  theSQLite.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/17.
//
//

#import "theSQLite.h"
#import <sqlite3.h>

@implementation theSQLite

-(id)init
{
    if ([super init]) {
        SQLiteURL = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"MRTInfos.sqlite3"];
        database = nil;
        stm =nil;
    }
    return self;
}

-(int)ReturnRowsAmount:(NSString *)SQLCommand
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    int count = 0;
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK) {
            if (sqlite3_step(stm) == SQLITE_ROW)
                count = sqlite3_column_int(stm, 0);
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return count;
}

-(NSMutableArray *)ReturnTableData:(NSString *)SQLCommand andIndexOFColumn:(int)ColumnNumber
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *TableData = [NSMutableArray new];
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK){
            while (sqlite3_step(stm) == SQLITE_ROW)
                [TableData addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, ColumnNumber)]];
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return TableData;
}

-(NSMutableArray *)ReturnMultiRowsData:(NSString *)SQLCommand andIndexOFColumn:(CGPoint)Range
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *TableData = [NSMutableArray new];
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK){
            int j = 0;
            while (sqlite3_step(stm) == SQLITE_ROW){
                [TableData addObject:[NSMutableArray new]];
                for (int i = 0; i < (Range.y-Range.x+1); i++){
                    [[TableData objectAtIndex:j]addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, Range.x+i)]];
                }
                j++;
            }
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return TableData;
}

-(NSMutableArray *)ReturnMultiTableData:(NSString *)SQLCommand andIndexOFColumn:(CGPoint)Range
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *TableData = [NSMutableArray new];
    for (int i = 0; i < (Range.y-Range.x+1); i++)
        [TableData addObject:[NSMutableArray new]];
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK){
            while (sqlite3_step(stm) == SQLITE_ROW){
                for (int i = 0; i < (Range.y-Range.x+1); i++)
                    [[TableData objectAtIndex:i]addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, Range.x+i)]];
            }
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return TableData;
}

-(NSMutableArray *)ReturnPointData:(NSString *)SQLCommand andIndexOFColumn:(int)ColumnNumber
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *TableData = [NSMutableArray new];
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK){
            while (sqlite3_step(stm) == SQLITE_ROW){
                [TableData addObject:[NSValue valueWithCGPoint:CGPointMake([[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, ColumnNumber)] floatValue], [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, ColumnNumber +1)] floatValue])]];
            }
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return TableData;
}

-(NSDictionary *)ReturnSingleRowWithDictionary:(NSString *)SQLCommand
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *RowData;
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK){
            while (sqlite3_step(stm) == SQLITE_ROW){
                NSMutableArray *RowResult = [NSMutableArray new];
                NSMutableArray *ColumnName = [NSMutableArray new];
                for (int i = 0; i < sqlite3_column_count(stm); i++) {
                    [RowResult addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, i)]];
                    [ColumnName addObject:[[NSString alloc]initWithUTF8String:sqlite3_column_name(stm, i)]];
                }
                RowData = [[NSMutableDictionary alloc] initWithObjects:RowResult forKeys:ColumnName];
            }
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return RowData;
}

-(NSMutableArray *)ReturnSingleRow:(NSString *)SQLCommand
{
    const char *sql = [SQLCommand cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *RowData = [NSMutableArray new];
    if (sqlite3_open([SQLiteURL UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_prepare_v2(database, sql, -1, &stm, NULL) == SQLITE_OK){
            while (sqlite3_step(stm) == SQLITE_ROW){
                for (int i = 0; i < sqlite3_column_count(stm); i++)
                    [RowData addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, i)]];
            }
            sqlite3_finalize(stm);
        }
        sqlite3_close(database);
    }
    return RowData;
}

@end
