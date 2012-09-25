//
//  SocketListener.m
//  DAFGU Migration Status
//
//  Created by Per Olofsson on 2012-09-24.
//  Copyright (c) 2012 Göteborgs universitet. All rights reserved.
//

#import "SocketListener.h"
#import <sys/socket.h>
#import <sys/un.h>

@implementation SocketListener

@synthesize target;
@synthesize action;
@synthesize watchThread;


- (BOOL)listenOnSocketInDir:(NSString *)dir withName:(NSString *)name target:(id)aTarget action:(SEL)anAction
{
    NSString *socketPath = [NSString stringWithFormat:@"%@/%@.%08x%08x", dir, name, arc4random(), arc4random()];
    self.target = aTarget;
    self.action = anAction;
    self.watchThread = [[NSThread alloc] initWithTarget:self selector:@selector(listenInBackground:) object:socketPath];
    [self.watchThread start];
    
    return YES;
}

- (void)stopListening
{
    [self.watchThread cancel];
}

- (void)listenInBackground:(NSString *)socketPath
{
    int sock;
    struct sockaddr_un sock_name;
    size_t len;
    NSMutableData *msgBuf = [NSMutableData dataWithLength:SL_MAX_MSG_SIZE];
    NSString *errorMsg;
    
    sock = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (sock < 0) {
        NSLog(@"Error opening datagram socket");
        return;
    }
    
    sock_name.sun_family = AF_UNIX;
    strlcpy(sock_name.sun_path, [socketPath cStringUsingEncoding:NSUTF8StringEncoding], sizeof(sock_name.sun_path));
    sock_name.sun_len = SUN_LEN(&sock_name);
    
    if (bind(sock, (struct sockaddr *) &sock_name, sizeof(struct sockaddr_un)) != 0) {
        NSLog(@"Error binding to datagram socket");
        return;
    }
    
    for (;;) {
        len = recv(sock, [msgBuf mutableBytes], [msgBuf length], MSG_WAITALL);
        if (len > 0) {
            NSDictionary *msg = [NSPropertyListSerialization propertyListFromData:msgBuf mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errorMsg];
            if (msg != nil) {
                if ([self.target respondsToSelector:self.action]) {
                    [self.target performSelectorOnMainThread:self.action withObject:msg waitUntilDone:YES];
                }
            }
        }
    }
}

@end
