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


// We're watching this plist for status updates.
NSString * const plistPath = @"/tmp/DAFGUMigrationStatus.plist";


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
    self.hasWarnedNotExists = NO;
    [self setStatus:kDMStatusUnknown message:NSLocalizedString(@"Starting…", @"Starting…")];
    // Check once per second if the plist exists, and if so start watching for changes.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startWatching) userInfo:nil repeats:YES]; 
}

- (void)startWatching
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        // If the plist doesn't exist exit and try again.
        if (self.hasWarnedNotExists == NO) {
            NSLog(@"%@ does not exist", plistPath);
            self.hasWarnedNotExists = YES;
            [self setStatus:kDMStatusUnknown message:NSLocalizedString(@"Waiting…", @"Waiting…")];
        }
        return;
    }
    NSLog(@"Watching %@", plistPath);
    // Stop timer.
    [self.timer invalidate];
    // Read current status.
    [self readStatus];
    // Start watching plist for changes.
	//self.watcher = [[FileWatcher alloc] init];
    self.watcher = [[PollWatcher alloc] init];
    [self.watcher watchFileAtPath:plistPath target:self action:@selector(readStatus)];
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
        [self setStatus:kDMStatusUnknown message:@"status is not an integer"];
        return;
    }
    statusInt = [status integerValue];
    if (statusInt < kDMStatusMin || statusInt > kDMStatusMax) {
        [self setStatus:kDMStatusError message:@"illegal status value"];
        return;
    }
    
    msg = [plistDict objectForKey:@"DAFGUMigrationMessage"];
    if (![msg isKindOfClass:[NSString class]]) {
        [self setStatus:kDMStatusUnknown message:@"message is not a string"];
        return;
    }
    if ([msg length] > 100) {
        [self setStatus:kDMStatusError message:@"message is too long"];
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
