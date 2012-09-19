//
//  DAFGU_Migration_StatusAppDelegate.h
//  DAFGU Migration Status
//
//  Created by Pelle on 2012-02-01.
//  Copyright 2012 Göteborgs universitet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "FileWatcher.h"
#import "PollWatcher.h"


@interface DAFGU_Migration_StatusAppDelegate : NSObject {
    NSWindow *window;
    NSMenu *statusMenu;
    NSStatusItem *statusItem;
    //FileWatcher *watcher;
    PollWatcher *watcher;
    NSTimer *timer;
    BOOL hasWarnedNotExists;
    
    NSImage *statusImage[5];
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) NSStatusItem *statusItem;
//@property (assign) FileWatcher *watcher;
@property (assign) PollWatcher *watcher;
@property (assign) NSTimer *timer;
@property (assign) BOOL hasWarnedNotExists;

- (void)startListening;
- (void)readStatus;
- (void)setStatus:(int)status message:(NSString *)msg;

enum {
    kDMStatusUnknown = 0,
    kDMStatusOK,
    kDMStatusError,
    kDMStatusActive
};
#define kDMStatusMin kDMStatusUnknown
#define kDMStatusMax kDMStatusActive

@end
