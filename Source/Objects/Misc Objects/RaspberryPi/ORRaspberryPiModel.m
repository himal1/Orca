//
//  ORRaspberryPiModel.m
//  Orca
//
//  Created by Mark Howe on 12/7/2022.
//  Copyright 2006 CENPA, University of Washington. All rights reserved.
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

#import "ORRaspberryPiModel.h"
#import "ORRaspberryPiController.h"
#import "ORSafeQueue.h"

NSString* ORRaspberryPiUserNameChanged  = @"ORRaspberryPiUserNameChanged";
NSString* ORRaspberryPiCmdPathChanged   = @"ORRaspberryPiCmdPathChanged";
NSString* ORRaspberryPiIPAddressChanged = @"ORRaspberryPiIPAddressChanged";
NSString* ORRaspberryPiRunCommandChanged = @"ORRaspberryPiRunCommandChanged";

@implementation ORRaspberryPiModel

#pragma mark ***Initialization

- (id) init
{
    self = [super init];
    return self;
}


- (void) wakeUp
{
    if(![self aWake]){
        //[self buildMainWindow];
        //[self setConnectionStatusOK];
        //[self connectionChanged];
        //[self _startAllPeriodicOperations];
        //[self registerNotificationObservers];
        //[self executeDBCmd:[ORRaspberryPiListOrgs    listOrgs]];
        //[self executeDBCmd:[ORRaspberryPiListBuckets listBuckets]];
    }
    [super wakeUp];
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    canceled = YES;
    [cmdQueue       release];
    [userName       release];
    [cmdPath        release];
    [super dealloc];
}

- (void) sleep
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super sleep];
}

- (void) makeMainController
{
    [self linkToController:@"ORRaspberryPiController"];
}

- (void) setUpImage {
    NSImage* image = [NSImage imageNamed:@"RaspberryPi"];
    [self setImage:image];
}

- (NSString*) ipAddress
{
    return ipAddress!=nil?ipAddress:@"";
}
- (void) setIPAddress:(NSString*)anIP
{
    if(!anIP)anIP = @"";
    [[[self undoManager] prepareWithInvocationTarget:self] setIPAddress:ipAddress];
    [ipAddress autorelease];
    ipAddress = [anIP copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORRaspberryPiIPAddressChanged object:self];
}

- (NSString*) userName
{
    return userName!=nil?userName:@"";
}

- (void) setUserName:(NSString*)aName
{
    if(!aName)aName = @"";
    [[[self undoManager] prepareWithInvocationTarget:self] setUserName:userName];
    [userName autorelease];
    userName = [aName copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORRaspberryPiUserNameChanged object:self];
}

- (NSString*) cmdPath
{
    return cmdPath!=nil?cmdPath:@"";
}

- (void) setCmdPath:(NSString*)aPath
{
    if(!aPath)aPath = @"";
    [[[self undoManager] prepareWithInvocationTarget:self] setCmdPath:cmdPath];
    [cmdPath autorelease];
    cmdPath = [aPath copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORRaspberryPiCmdPathChanged object:self];
}

- (NSString*) runCommand
{
    return runCommand!=nil?runCommand:@"";
}

- (void) setRunCommand:(NSString*)aPath
{
    if(!aPath)aPath = @"";
    [[[self undoManager] prepareWithInvocationTarget:self] setRunCommand:runCommand];
    [runCommand autorelease];
    runCommand = [aPath copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORRaspberryPiRunCommandChanged object:self];
}


#pragma mark ***Archival
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    
    [[self undoManager] disableUndoRegistration];
    [self setUserName:    [decoder decodeObjectForKey: @"userName"]];
    [self setCmdPath:     [decoder decodeObjectForKey: @"cmdPath"]];
    [self setIPAddress:   [decoder decodeObjectForKey: @"ipAddress"]];
    [self setRunCommand:   [decoder decodeObjectForKey: @"runCommand"]];
    [[self undoManager] enableUndoRegistration];
        
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:userName     forKey: @"userName"];
    [encoder encodeObject:cmdPath      forKey: @"cmdPath"];
    [encoder encodeObject:ipAddress    forKey: @"ipAddress"];
    [encoder encodeObject:runCommand   forKey: @"runCommand"];
}

- (void)runCommand:(NSString *)command
              path:(NSString *)path
              host:(NSString *)host
              user:(NSString *)user
        completion:(void (^)(NSString *output))completion {
    if (host.length == 0 || user.length == 0 || command.length == 0) {
        if (completion) completion(@"Missing host, user, or command.");
        return;
    }

    // Build SSH command
    NSString *remoteCommand = [NSString stringWithFormat:@"cd %@ && %@", path, command];
    NSString *sshCommand = [NSString stringWithFormat:@"%@@%@", user, host];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/ssh";
    task.arguments = @[sshCommand, remoteCommand];

    // Capture standard output
    NSPipe *outputPipe = [NSPipe pipe];
    task.standardOutput = outputPipe;

    // Capture standard error (important!)
    NSPipe *errorPipe = [NSPipe pipe];
    task.standardError = errorPipe;

    [task setTerminationHandler:^(NSTask *t) {
        NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        NSString *outputStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

        NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
        NSString *errorStr = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];

        // Combine or choose which to return
        NSString *finalOutput = @"";
        if (t.terminationStatus == 0) {
            finalOutput = outputStr;
        } else {
            finalOutput = [NSString stringWithFormat:@"SSH failed with error:\n%@", errorStr];
        }

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(finalOutput);
            });
        }
    }];

    @try {
        [task launch];
    } @catch (NSException *exception) {
        NSString *exceptionMsg = [NSString stringWithFormat:@"Failed to launch SSH task: %@", exception.reason];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(exceptionMsg);
            });
        }
    }
}

/*
- (void)runCommand:(NSString *)command
              path:(NSString *)path
             host:(NSString *)host
             user:(NSString *)user
        completion:(void (^)(NSString *output))completion
{
    if (host.length == 0 || user.length == 0 || command.length == 0) {
        if (completion) completion(@"Missing host, user, or command.");
        return;
    }

    NSString *fullCommand = [NSString stringWithFormat:@"ssh %@@%@ \"%@\"", user, host, command];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/bin/bash";
        task.arguments = @[@"-c", fullCommand];

        NSPipe *pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        task.standardError = pipe;

        NSFileHandle *file = pipe.fileHandleForReading;

        [task launch];
        [task waitUntilExit];

        NSData *data = [file readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(output);
        });
    });
}
*/


//- (void) makeConnectors
//{
//    ORConnector* aConnector = [[ORConnector alloc] initAt:NSMakePoint(0,[self frame].size.height/2-kConnectorSize/2) withGuardian:self withObjectLink:self];
//    [[self connectors] setObject:aConnector forKey:ORRaspberryPiModelInConnector];
//    [aConnector setOffColor:[NSColor brownColor]];
//    [aConnector setOnColor:[NSColor magentaColor]];
//    [aConnector setConnectorType: 'DB I' ];
//    [aConnector addRestrictedConnectionType: 'DB O' ]; //can only connect to DB outputs
//
//    [aConnector release];
//}

@end
