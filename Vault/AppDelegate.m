//
//  AppDelegate.m
//  Vault
//
//  Created by Russell Chreptyk on 2013-03-22.
//  Copyright (c) 2013 Russell Chreptyk. All rights reserved.
//

#import "AppDelegate.h"
#import "NSStrinAdditions.h"
#import "ImageSnap.h"
#include <CommonCrypto/CommonDigest.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)EnterClicked:(id)sender {
    NSString * password = [_passwordField stringValue];
    
    for (int i = 1; i <= 1000; i++) {
        password = [self hash:[password stringByAppendingFormat:@"%d", i]];
    }
    
    if(![self attemptVaultMountWithPassword: password])
    {
        
        NSDateFormatter *formatter;
        NSString        *dateString;
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        
        dateString = [formatter stringFromDate:[NSDate date]];
        dateString = [dateString stringByAppendingPathExtension:@"jpg"];
        
        NSString * path = [@"/Users/russell/Library/Application Support/.fconfig/log" stringByAppendingPathComponent:dateString];
        
        NSFileManager * manager = [NSFileManager new];
        [manager createDirectoryAtPath:@"/Users/russell/Library/Application Support/.fconfig/log" withIntermediateDirectories:YES attributes:nil error:nil];
        
        [ImageSnap saveSingleSnapshotFrom:[ImageSnap defaultVideoDevice] toFile:path];
        
        NSAlert * alert = [NSAlert new];
        [alert setMessageText:@"Incorrect Password"];
        [alert runModal];
    }
    else
    {
        [_window close];
    }

}

- (IBAction)CancelClicked:(id)sender {
    [_window close];
}

- (BOOL) attemptVaultMountWithPassword: (NSString *) password
{
    password = [password stringByAppendingString:@"\0"];
    NSFileManager * manager = [NSFileManager new];
    NSError * error = nil;
    NSArray * files = [manager contentsOfDirectoryAtPath:@"/Users/russell/Library/Application Support/.fconfig" error:&error];
    
    if(error)
    {
        NSAlert * alert = [NSAlert new];
        [alert setMessageText:@"Directory not found -- failure"];
        [alert runModal];
        return NO;
    }
    
    for (int file = 0; file < [files count]; file++)
    {
        NSString * fullPath = [@"/Users/russell/Library/Application Support/.fconfig" stringByAppendingPathComponent:files[file]];
        if([[fullPath pathExtension] isLike:@"sparseimage"])
        {
            NSLog(@"Going to try opening %@ with %@", fullPath, password);
            NSArray * args = [NSArray arrayWithObjects:@"attach", @"-stdinpass", fullPath , nil];
            
            NSPipe * pipe = [NSPipe pipe];
            
            NSTask * exec = [NSTask new];
            [exec setLaunchPath:@"/usr/bin/hdiutil"];
            [exec setArguments:args];
            [exec setStandardInput:pipe];
            [exec launch];
            
            NSData * passData = [password dataUsingEncoding:NSASCIIStringEncoding];
            [[pipe fileHandleForWriting] writeData:passData];
            [[pipe fileHandleForWriting] closeFile];
            
            [exec waitUntilExit];
            
            if([exec terminationStatus] == 0)
                return YES;
            
        }
    }
    
    return NO;
}

- (NSString *) hash:(NSString *) str
{
    NSData* input = [str dataUsingEncoding: NSISOLatin1StringEncoding]; // Could use UTF16 or other if you like
    unsigned char passwordDgstchar[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512([input bytes],
              (unsigned int)[input length],
              passwordDgstchar);
    
    NSData * data = [[NSData alloc] initWithBytes:passwordDgstchar length:CC_SHA512_DIGEST_LENGTH];
    
    return [[NSString base64StringFromData:data length:(int)[input length]] stringByReplacingOccurrencesOfString:@"==" withString:@""];
}

@end
