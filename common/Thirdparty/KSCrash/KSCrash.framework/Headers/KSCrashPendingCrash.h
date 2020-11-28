//
//  KSCrashPendingCrash.h
//
//  Created by zkai on 2017-06-01.
//
//  Custom api for retriving crash reports.
//


#import <Foundation/Foundation.h>
#import "KSCrashReportFilterAppleFmt.h"

extern NSString * const kKSCrashError;
extern NSString * const kKSCrashReport;
extern NSString * const kKSCrashSystemInfo; // KSCrashField_System中内容，参考KSCrashReportFields.h
extern NSString * const kKSCrashUserAddedInfo; // onCrash中添加的内容

@interface KSCrashPendingCrash : NSObject

+ (KSCrashPendingCrash*) sharedInstance;
- (NSArray<NSDictionary*>*) allReports;
- (void) deleteAllReports;

- (NSArray<NSDictionary *>*) allReportsFromAppGroupID:(NSString *)appGroupID extensionName:(NSString *)extensionName;
- (void)deleteAllReportsFromAppGroupID:(NSString *)appGroupID extensionName:(NSString *)extensionName;

@end
