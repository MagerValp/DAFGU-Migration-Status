//
//  DAFGU_Migration_StatusAppDelegate.m
//  DAFGU Migration Status
//
//  Created by Pelle on 2012-02-01.
//  Copyright 2012 Göteborgs universitet. All rights reserved.
//

#import "DAFGU_Migration_StatusAppDelegate.h"

@implementation DAFGU_Migration_StatusAppDelegate

@synthesize window;
@synthesize statusMenu;
@synthesize statusItem;
@synthesize watcher;
@synthesize timer;
@synthesize hasWarnedNotExists;


// Status updates are written to this plist.
NSString * const plistPath = @"/tmp/DAFGUMigrationStatus.plist";
// We also listen for status updates to a shared object registered with this name.
NSString * const listenerName = @"se.gu.it.dafgu_migration_status";


- (void)awakeFromNib
{
    int i;
    
    statusImage[kDMStatusUnknown] = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"StatusUnknown"]];
    statusImage[kDMStatusOK] = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"StatusOK"]];
    statusImage[kDMStatusError] = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"StatusError"]];
    statusImage[kDMStatusActive + 0] = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"StatusActive0"]];
    statusImage[kDMStatusActive + 1] = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"StatusActive1"]];
    
    for (i = 0; i < sizeof(statusImage) / sizeof(statusImage[0]); ++i) {
        //setScalesWhenResized
        [statusImage[i] setSize:NSMakeSize(17, 17)];
    }
    
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:statusImage[kDMStatusUnknown]];
	//[statusItem setImage:my_image];
	//[statusItem setAlternateImage:my_alt_image];
	[statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setStatus:kDMStatusUnknown message:NSLocalizedString(@"Starting…", @"Starting…")];
    // Initialize with cached status if it exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [self readStatus];
    }
    // Start listening for status updates.
    [self startListening];
}

- (void)startListening
{
    NSConnection *conn = [NSConnection defaultConnection];
    [conn setRootObject:self];
    if ([conn registerName:listenerName] == false) {
        NSLog(@"Can't register connection object with name %@", listenerName);
        [self setStatus:kDMStatusError message:@"Listener failed"];
    }
}

- (void)readStatus
{
    NSDictionary *plistDict;
    NSNumber *status;
    NSString *msg;
    int statusInt;
    
    plistDict = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:plistPath]
                                                 mutabilityOption:0
                                                           format:NULL
                                                 errorDescription:nil];
    if (plistDict == nil) {
        [self setStatus:kDMStatusUnknown message:@"Can't read plist"];
        return;
    }
    
    if (![plistDict isKindOfClass:[NSDictionary class]]) {
        [self setStatus:kDMStatusUnknown message:@"plist is not a dictionary"];
        return;
    }
    
    status = [plistDict objectForKey:@"DAFGUMigrationStatus"];
    if (![status isKindOfClass:[NSNumber class]]) {
        [self setStatus:kDMStatusUnknown message:@"Status is not an integer"];
        return;
    }
    statusInt = [status integerValue];
    if (statusInt < kDMStatusMin || statusInt > kDMStatusMax) {
        [self setStatus:kDMStatusError message:@"Illegal status value"];
        return;
    }
    
    msg = [plistDict objectForKey:@"DAFGUMigrationMessage"];
    if (![msg isKindOfClass:[NSString class]]) {
        [self setStatus:kDMStatusUnknown message:@"Message is not a string"];
        return;
    }
    if ([msg length] > 100) {
        [self setStatus:kDMStatusError message:@"Message is too long"];
        return;
    }
    
    [self setStatus:statusInt message:msg];
}

- (void)setStatus:(int)status message:(NSString *)msg {
    //NSLog(@"setStatus:%d message:%@", status, msg);
	[statusItem setImage:statusImage[status]];
    [[statusMenu itemAtIndex:0] setTitle:NSLocalizedString(msg, @"<DYNAMIC>")];
}

@end
