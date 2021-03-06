//
//  DAFGU_Migration_StatusAppDelegate.h
//  DAFGU Migration Status
//
//  Created by Pelle on 2012-02-01.
//  Copyright 2012 Göteborgs universitet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "FileWatcher.h"
//#import "PollWatcher.h"
#import "SocketListener.h"


#define kDMStatusAnimFrames 32

@interface DAFGU_Migration_StatusAppDelegate : NSObject {
    NSWindow *window;
    NSMenu *statusMenu;
    NSStatusItem *statusItem;
    SocketListener *listener;
    NSTimer *timer;
    int currentStatus;
    
    NSImage *statusImage[kDMStatusAnimFrames + 3];
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) NSStatusItem *statusItem;
@property (assign) SocketListener *listener;
@property (assign) NSTimer *timer;
@property (assign) int currentStatus;

- (NSImage *)loadImage:(NSString *)name withSize:(NSSize)size;
- (NSImage *)newBlendWithFraction:(CGFloat)fraction image1:(NSImage *)image1 image2:(NSImage *)image2;
- (void)startListening;
- (void)readStatus;
- (void)parseStatus:(NSDictionary *)plistDict;
- (void)setStatus:(int)status message:(NSString *)msg;
- (void)toggleImageIfActive;

enum {
    kDMStatusUnknown = 0,
    kDMStatusOK,
    kDMStatusError,
    kDMStatusActive
};
#define kDMStatusMin kDMStatusUnknown
#define kDMStatusMax kDMStatusActive

@end
