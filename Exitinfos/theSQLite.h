//
//  theSQLite.h
//  iMRT Taipei
//
//  Created by LarryStanley on 13/2/17.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface theSQLite : NSObject
{
    NSString *SQLiteURL;
    sqlite3 *database;
    sqlite3_stmt *stm;
}

-(int)ReturnRowsAmount:(NSString *)SQLCommand;
-(NSMutableArray *)ReturnTableData:(NSString *)SQLCommand andIndexOFColumn:(int)ColumnNumber;
-(NSMutableArray *)ReturnMultiTableData:(NSString *)SQLCommand andIndexOFColumn:(CGPoint)Range;
-(NSMutableArray *)ReturnMultiRowsData:(NSString *)SQLCommand andIndexOFColumn:(CGPoint)Range;
-(NSMutableArray *)ReturnPointData:(NSString *)SQLCommand andIndexOFColumn:(int)ColumnNumber;
-(NSDictionary *)ReturnSingleRowWithDictionary:(NSString *)SQLCommand;
-(NSMutableArray *)ReturnSingleRow:(NSString *)SQLCommand;
@end
