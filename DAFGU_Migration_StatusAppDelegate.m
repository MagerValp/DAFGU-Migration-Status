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
@synthesize listener;
@synthesize timer;
@synthesize currentStatus;


// Status updates are written to this plist.
NSString * const plistPath = @"/tmp/DAFGUMigrationStatus.plist";
// We also listen for status updates on a socket in this dir with this name.
NSString * const listenerDir = @"/tmp";
NSString * const listenerName = @"se.gu.it.dafgu_migration_status";
// The active status image is animated with this interval.
const NSTimeInterval activeToggleInterval = 0.1;

- (void)awakeFromNib
{
    int i;
    CGFloat fraction;
    NSSize statusSize = NSMakeSize(17, 17);
	
    statusImage[kDMStatusUnknown] = [self loadImage:@"StatusUnknown" withSize:statusSize];
    statusImage[kDMStatusOK] = [self loadImage:@"StatusOK" withSize:statusSize];
    statusImage[kDMStatusError] = [self loadImage:@"StatusError" withSize:statusSize];
	NSImage *active000 = [self loadImage:@"StatusActive0" withSize:statusSize];
	NSImage *active100 = [self loadImage:@"StatusActive1" withSize:statusSize];
	for (i = 0; i < kDMStatusAnimFrames; i++) {
        fraction = (CGFloat)i / ((CGFloat)kDMStatusAnimFrames / 2.0);
        if (fraction >= 1.0) {
            fraction = 2.0 - fraction;
        }
        statusImage[kDMStatusActive + i] = [self newBlendWithFraction:fraction image1:active000 image2:active100];
    }
    
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:statusImage[kDMStatusUnknown]];
	[statusItem setHighlightMode:YES];
}

- (NSImage *)loadImage:(NSString *)name withSize:(NSSize)size
{
	NSImage *sourceImage = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:name]] retain];
	NSImage *scaledImage = [[NSImage alloc] initWithSize:size];
	[scaledImage lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[sourceImage setSize:size];
	[sourceImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	[scaledImage unlockFocus];
	return scaledImage;
}

- (NSImage *)newBlendWithFraction:(CGFloat)fraction image1:(NSImage *)image1 image2:(NSImage *)image2
{
	NSImage *blendImage = [image1 copy];
	NSSize size = [blendImage size];
	NSRect rect = NSMakeRect(0, 0, size.width, size.height);
	[blendImage lockFocus];
	[image2 drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:fraction];
	[blendImage unlockFocus];
	
	return blendImage;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setStatus:kDMStatusUnknown message:NSLocalizedString(@"Starting…", @"Starting…")];
    // Initialize with cached status if it exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [self readStatus];
    }
    // Start listening for status updates.
    [self startListening];
    // Start timer to animate active image.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:activeToggleInterval target:self selector:@selector(toggleImageIfActive) userInfo:nil repeats:YES];
}

- (void)startListening
{
    self.listener = [[SocketListener alloc] init];
    [self.listener listenOnSocketInDir:listenerDir withName:listenerName target:self action:@selector(parseStatus:)];
}

- (void)readStatus
{
    NSDictionary *plistDict;
    plistDict = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:plistPath]
                                                 mutabilityOption:0
                                                           format:NULL
                                                 errorDescription:nil];
    [self parseStatus:plistDict];
}

- (void)parseStatus:(NSDictionary *)plistDict
{
    NSNumber *status;
    NSString *msg;
    int statusInt;
    
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
    self.currentStatus = status;
	[statusItem setImage:statusImage[status]];
    [[statusMenu itemAtIndex:0] setTitle:NSLocalizedString(msg, @"<DYNAMIC>")];
}

- (void)toggleImageIfActive {
    static unsigned int animFrame = 0;
    
    if (self.currentStatus == kDMStatusActive) {
        animFrame = (animFrame + 1) % kDMStatusAnimFrames;
        [statusItem setImage:statusImage[kDMStatusActive + animFrame]];
    }
}

@end
