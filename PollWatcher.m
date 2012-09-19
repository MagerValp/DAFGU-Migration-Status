//
//  PollWatcher.m
//  DAFGU Migration Status
//
//  Created by Per Olofsson on 2012-02-07.
//  Copyright 2012 Göteborgs universitet. All rights reserved.
//

#import "PollWatcher.h"

@implementation PollWatcher

@synthesize path;
@synthesize target;
@synthesize action;
@synthesize lastMod;
@synthesize watchThread;

- (BOOL)watchFileAtPath:(NSString*)aPath target:(id)aTarget action:(SEL)anAction
{
    self.path = aPath;
    self.target = aTarget;
    self.action = anAction;
    
    self.lastMod = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:nil] fileModificationDate];
    
    self.watchThread = [[NSThread alloc] initWithTarget:self selector:@selector(watchInBackground) object:nil];
    [self.watchThread start];
    
    return YES;
}

- (void)stopWatching
{
    [self.watchThread cancel];
}

- (void)watchInBackground
{
    NSDate *checkMod;
    
    for (;;) {
        
        checkMod = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:nil] fileModificationDate];
        
        if ([self.lastMod isEqualToDate:checkMod]) {
        
            usleep(250);
            
        } else {
            
            self.lastMod = checkMod;
            if ([self.target respondsToSelector:self.action]) {
                [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:YES];
            }
            
        }
    
    }

}

@end
