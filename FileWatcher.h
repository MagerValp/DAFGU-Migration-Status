//
//  FileWatcher.h
//  DAFGU Migration Status
//
//  Created by Per Olofsson on 2012-02-01.
//  Copyright (c) 2012 Göteborgs universitet. All rights reserved.
//


//#import <Foundation/Foundation.h>

@interface FileWatcher : NSObject {
    NSString *path;
    id target;
    SEL action;
    int fildes;
    int kq;
    NSThread *watchThread;
}

@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) int fildes;
@property (nonatomic, assign) int kq;
@property (nonatomic, retain) NSThread *watchThread;

- (BOOL)watchFileAtPath:(NSString *)path target:(id)target action:(SEL)action;
- (void)stopWatching;

@end
