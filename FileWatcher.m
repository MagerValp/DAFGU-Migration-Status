//
//  FileWatcher.m
//  DAFGU Migration Status
//
//  Created by Per Olofsson on 2012-02-01.
//  Copyright (c) 2012 Göteborgs universitet. All rights reserved.
//

#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#import "FileWatcher.h"


@implementation FileWatcher

@synthesize path;
@synthesize target;
@synthesize action;
@synthesize fildes;
@synthesize kq;
@synthesize watchThread;

- (BOOL)watchFileAtPath:(NSString*)aPath target:(id)aTarget action:(SEL)anAction
{
    self.path = aPath;
    self.target = aTarget;
    self.action = anAction;
    
    self.fildes = open([self.path UTF8String], O_EVTONLY);
    if (self.fildes <= 0) {
        return NO;
    }
    self.kq = kqueue();
    
    self.watchThread = [[NSThread alloc] initWithTarget:self selector:@selector(watchInBackground) object:nil];
    [self.watchThread start];
    
    return YES;
}

- (void)stopWatching
{
    close(self.kq);
    close(self.fildes);
    [self.watchThread cancel];
}

- (void)watchInBackground
{
    int status = 1;
    struct kevent change;
    struct kevent event;
    EV_SET(&change,                                                 // &kev,
           self.fildes,                                             // ident
           EVFILT_VNODE,                                            // filter
           EV_ADD | EV_ENABLE | EV_ONESHOT,                         // flags
           NOTE_DELETE | NOTE_EXTEND | NOTE_WRITE | NOTE_ATTRIB,    // fflags
           0,                                                       // data
           0);                                                      // udata
    
    while (status > 0) {
        NSLog(@"waiting for kevent()");
        status = kevent(self.kq,    // int kq
                        &change,    // const struct kevent *changelist
                        1,          // int nchanges
                        &event,     // struct kevent *eventlist
                        1,          // int nevents
                        NULL);      // const struct timespec *timeout
        NSLog(@"kevent() returned %d", status);
        
        if (status > 0) {
            if ([self.target respondsToSelector:self.action]) {
                [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:YES];
            }
        }
    }
    
    NSLog(@"done watching");
    close(self.kq);
    close(self.fildes);
}

@end
