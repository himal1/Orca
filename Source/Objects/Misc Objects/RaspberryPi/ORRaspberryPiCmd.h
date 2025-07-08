//-------------------------------------------------------------------------
//  ORRaspberryPiCmd.h
//
// Created by Mark Howe on 12/30/2022.

//  Copyright (c) 2022 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//North Carolina sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//Washington reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the use of this software.
//-------------------------------------------------------------


NS_ASSUME_NONNULL_BEGIN
@class ORRaspberryPiModel;
enum {
    kFluxMeasurement,
    kFluxLineMode,
    kFluxCreateBucket,
    kFluxDeleteBucket,
    kFluxListBuckets,
    kFluxDeleteData,
    kFluxListOrgs,
    kFluxDelay,
};

//----------------------------------------------------------------
//  Base Class
//----------------------------------------------------------------
@interface ORRaspberryPiCmd : NSObject
{
    int cmdType;
    long requestSize;
}
+ (ORRaspberryPiCmd*) inFluxDBCmd:(int)aType;
- (id) init:(int)aType;
- (void) dealloc;
- (int)  cmdType;
- (long) requestSize;
- (NSMutableURLRequest*) requestFrom:(ORRaspberryPiModel*)delegate;
- (void) executeCmd:(ORRaspberryPiModel*)aSender;
- (void) logResult:(id)aResult code:(int)aCode delegate:(ORRaspberryPiModel*)delegate;
@end

//----------------------------------------------------------------
//  Delay Command
//----------------------------------------------------------------
@interface ORRaspberryPiDelayCmd : ORRaspberryPiCmd
{
    int delayTime;
}
+ (ORRaspberryPiDelayCmd*) delay:(int)seconds;
- (id) init:(int)aType delay:(int)seconds;
- (int) delayTime;
@end

//----------------------------------------------------------------
//  Delete bucket
//----------------------------------------------------------------
@interface ORRaspberryPiDeleteBucket : ORRaspberryPiCmd
{
    NSString* bucketId;
}
+ (ORRaspberryPiDeleteBucket*) deleteBucket;
- (void) dealloc;
- (void) setBucketId:(NSString*) anId;
@end

//----------------------------------------------------------------
//  List buckets
//----------------------------------------------------------------
@interface ORRaspberryPiListBuckets : ORRaspberryPiCmd
+ (ORRaspberryPiListBuckets*) listBuckets;
@end

//----------------------------------------------------------------
//  List Orgs
//----------------------------------------------------------------
@interface ORRaspberryPiListOrgs : ORRaspberryPiCmd
+ (ORRaspberryPiListOrgs*) listOrgs;
@end

//----------------------------------------------------------------
//  create bucket
//----------------------------------------------------------------
@interface ORRaspberryPiCreateBucket : ORRaspberryPiCmd
{
    NSString* bucket;
    NSString* orgId;
    long      expireTime;
}
+ (ORRaspberryPiCreateBucket*) createBucket:(NSString*)aName orgId:(NSString*)anId expireTime:(long)seconds;
- (id) init:(int)aType bucket:(NSString*) aBucket orgId:(NSString*)anId expireTime:(long)seconds;
@end

//----------------------------------------------------------------
//  Measurements
//----------------------------------------------------------------
@interface ORRaspberryPiMeasurement : ORRaspberryPiCmd
{
    NSMutableArray* tags;
    NSMutableArray* measurements;
    NSString*       measurement;
    NSString*       bucket;
    NSString*       org;
    double          timeStamp;
}
+ (ORRaspberryPiMeasurement*)measurementForBucket:(NSString*)aBucket org:(NSString*)anOrg;
- (id) init:(int)aType bucket:(NSString*)aBucket org:(NSString*)anOrg;
- (void) setTimeStamp:(double)aTimeStamp;
- (NSString*) bucket;
- (NSString*) org;
- (NSString*) cmdLine;
- (void) start:(NSString*)section withTags:(NSString*)someTags;
- (void) start:(NSString*)section;

- (void) addTag:(NSString*)aLabel withBoolean:(BOOL)aValue;
- (void) addTag:(NSString*)aLabel withLong:(long)aValue;
- (void) addTag:(NSString*)aLabel withDouble:(double)aValue;
- (void) addTag:(NSString*)aLabel withString:(NSString*)aValue;

- (void) addField:(NSString*)aLabel withBoolean:(BOOL)aValue;
- (void) addField:(NSString*)aValueName withLong:(long)aValue;
- (void) addField:(NSString*)aValueName withDouble:(double)aValue;
- (void) addField:(NSString*)aValueName withString:(NSString*)aValue;
@end

@interface ORRaspberryPiCmdLineMode : ORRaspberryPiCmd
{
    NSMutableString*    line;
    NSString*           bucket;
    NSString*           org;
}
+ (ORRaspberryPiCmdLineMode*)lineModeForBucket:(NSString*)aBucket org:(NSString*)anOrg;
- (id) init:(int)aType bucket:(NSString*)aBucket org:(NSString*)anOrg;
- (void) appendLine:(NSString*)aLine;
@end


//----------------------------------------------------------------
//  Delete All Data
//----------------------------------------------------------------
@interface ORRaspberryPiDeleteAllData : ORRaspberryPiCmd
{
    NSString* start;
    NSString* stop;
    NSString* bucket;
    NSString* org;
}
+ (ORRaspberryPiDeleteAllData*)inFluxDBDeleteAllData:(NSString*)aBucket org:(NSString*)anOrg start:(NSString*)aStart  stop:(NSString*)aStop;
- (id) init:(int)aType bucket:(NSString*)aBucket org:(NSString*)anOrg start:(NSString*)aStart  stop:(NSString*)aStop;
@end

//----------------------------------------------------------------
//  Delete Data using a predicate
//----------------------------------------------------------------
@interface ORRaspberryPiDeleteSelectedData : ORRaspberryPiDeleteAllData
{
    NSString* predicate;
}
+ (ORRaspberryPiDeleteSelectedData*)deleteSelectedData:(NSString*)aBucket org:(NSString*)anOrg start:(NSString*)aStart stop:(NSString*)aStop predicate:(NSString*)aPredicate;
- (id) init:(int)aType bucket:(NSString*)aBucket org:(NSString*)anOrg start:(NSString*)aStart stop:(NSString*)aStop predicate:(NSString*)aPredicate;
@end
NS_ASSUME_NONNULL_END
