//-------------------------------------------------------------------------
//  ORRaspberryPiModel.h
//
// Created by Mark Howe on 12/7/2022.

//  Copyright (c) 2006 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//Washington at the Center for Experimental Nuclear Physics and
//Astrophysics (CENPA) sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files
#import "OrcaObject.h"

@class ORRaspberryPi;
@class ORAlarm;
@class ORSafeQueue;

@interface ORRaspberryPiModel : OrcaObject
{
    NSString*           ipAddress;
    NSString*           userName;
    NSString*           cmdPath;
    //----queue thread--------
    bool                canceled;
    NSThread*           processThread;
    ORSafeQueue*        cmdQueue;
    
}
#pragma mark ***Accessors
- (NSString*) ipAddress;
- (void) setIPAddress:(NSString*)anIP;
- (NSString*) userName;
- (void) setUserName:(NSString*)aName;
- (NSString*) cmdPath;
- (void) setCmdPath:(NSString*)aPath;

#pragma mark ***Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;
- (void)runCommand:(NSString *)command
              path:(NSString *)path
              host:(NSString *)host
            user:(NSString *)user
        completion:(void (^)(NSString *output))completion;
@end

extern NSString* ORRaspberryPiIPAddressChanged;
extern NSString* ORRaspberryPiUserNameChanged;
extern NSString* ORRaspberryPiCmdPathChanged;
