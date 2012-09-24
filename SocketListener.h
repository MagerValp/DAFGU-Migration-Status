//
//  SocketListener.h
//  DAFGU Migration Status
//
//  Created by Per Olofsson on 2012-09-24.
//  Copyright (c) 2012 Göteborgs universitet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SocketListener : NSObject {
    id target;
    SEL action;
    NSThread *watchThread;

}

#define SL_MAX_MSG_SIZE 65536

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSThread *watchThread;

- (BOOL)listenOnSocketInDir:(NSString *)dir withName:(NSString *)name target:(id)aTarget action:(SEL)anAction;
- (void)stopListening;
- (void)listenInBackground:(NSString *)socketPath;

@end
