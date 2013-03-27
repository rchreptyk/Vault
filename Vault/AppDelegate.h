//
//  AppDelegate.h
//  Vault
//
//  Created by Russell Chreptyk on 2013-03-22.
//  Copyright (c) 2013 Russell Chreptyk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSSecureTextFieldCell *passwordField;
@property (assign) IBOutlet NSWindow *window;
- (IBAction)EnterClicked:(id)sender;
- (IBAction)CancelClicked:(id)sender;
- (BOOL) attemptVaultMountWithPassword: (NSString *) password;
- (NSString *) hash:(NSString *) str;

@end
