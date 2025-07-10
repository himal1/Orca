//
//  ORRaspberryPiController.h
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

#import "ORValueBarGroupView.h"
#import "OrcaObjectController.h"
#import "ORTimedTextField.h"

#import <Cocoa/Cocoa.h>

@interface ORRaspberryPiController : OrcaObjectController
{
    //- (id) init;
    //- (NSWindow *)buildMainWindow;
    IBOutlet NSButton*                sendButton;
    IBOutlet NSTextField*           userNameField;
    IBOutlet NSTextField*           cmdPathField;
    IBOutlet NSTextField*           ipAddressField;
    IBOutlet NSTextField*           runCommandField;
}

#pragma mark ***Interface Management
- (void) userNameChanged:(NSNotification*)aNote;
- (void) ipAddressChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) userNameAction:(id)sender;
- (IBAction) cmdPathAction:(id)sender;
- (IBAction) ipAddressAction:(id)sender;
- (IBAction) runAction:(id)sender;
@end
