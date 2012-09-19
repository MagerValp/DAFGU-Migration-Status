//
//  PollWatcher.h
//  DAFGU Migration Status
//
//  Created by Per Olofsson on 2012-02-07.
//  Copyright 2012 Göteborgs universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PollWatcher : NSObject {
    NSString *path;
    id target;
    SEL action;
    NSDate *lastMod;
    NSThread *watchThread;
}

@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSDate *lastMod;
@property (nonatomic, retain) NSThread *watchThread;

- (BOOL)watchFileAtPath:(NSString *)path target:(id)target action:(SEL)action;
- (void)stopWatching;

@end
