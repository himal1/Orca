//
//  ORRaspberryPiController.m
//  Orca
//
// Created by Mark Howe on 12/7/2022.
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

#import "ORRaspberryPiController.h"
#import "ORRaspberryPiModel.h"

@implementation ORRaspberryPiController

-(id)init
{
    self = [super initWithWindowNibName:@"RaspberryPi"];
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) awakeFromNib
{
    [self registerNotificationObservers];
    //[statusTable reloadData];
    //[self reloadDataTables:nil];
    [super awakeFromNib];
}
- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    
    [super registerNotificationObservers];
    
    [notifyCenter addObserver : self
                     selector : @selector(userNameChanged:)
                         name : ORRaspberryPiUserNameChanged
                        object: model];
    
    [notifyCenter addObserver : self
                     selector : @selector(cmdPathChanged:)
                         name : ORRaspberryPiCmdPathChanged
                        object: model];
    
    [notifyCenter addObserver : self
                     selector : @selector(ipAddressChanged:)
                         name : ORRaspberryPiIPAddressChanged
                        object: model];
    
    [notifyCenter addObserver : self
                     selector : @selector(runCommandChanged:)
                         name : ORRaspberryPiRunCommandChanged
                        object: model];
}

- (void) updateWindow
{
    [super updateWindow];
    [self userNameChanged:nil];
    [self cmdPathChanged:nil];
    [self ipAddressChanged:nil];
    [self runCommandChanged:nil];
}

- (void) setModel:(id)aModel
{
    [super setModel:aModel];
}

- (NSString*) windowNibName
{
    return @"RaspberryPi";
}
#pragma mark •••Notifications
- (void) userNameChanged:(NSNotification*)aNote
{
    [userNameField setStringValue:[model userName]];
}

- (void) cmdPathChanged:(NSNotification*)aNote
{
    [cmdPathField setStringValue:[model cmdPath]];
}

- (void) ipAddressChanged:(NSNotification*)aNote
{
    [ipAddressField setStringValue:[model ipAddress]];
}
- (void) runCommandChanged:(NSNotification*)aNote
{
    [runCommandField setStringValue:[model runCommand]];
}


#pragma mark •••Actions
- (IBAction) userNameAction:(id)sender
{
    [model setUserName:[userNameField stringValue]];
}

- (IBAction) cmdPathAction:(id)sender
{
    [model setCmdPath:[cmdPathField stringValue]];
}

- (IBAction) ipAddressAction:(id)sender
{
    [model setIPAddress:[ipAddressField stringValue]];
}
- (IBAction) runCommandAction:(id)sender
{
    [model setRunCommand:[runCommandField stringValue]];
}


- (IBAction) runAction:(id)sender
{
    [model runCommand:[runCommandField stringValue]
                path:[cmdPathField stringValue]
                host:[ipAddressField stringValue]
                user:[userNameField stringValue]
           completion:^(NSString *output_out) {
        NSString *output = [NSString stringWithFormat:@"The IP address is: %@\nThe username is: %@\nThe path is: %@\nThe command is: %@ \n The output is :%@",
                            [ipAddressField stringValue],
                            [userNameField stringValue],
                            [cmdPathField stringValue],
                            [runCommandField stringValue], output_out];
        //NSLog(@"Command output: %@", output);
        [outputField setStringValue:output];
    }];
}

@end

