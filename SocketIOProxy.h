//
//  SocketIOProxy.h
//  tisocketio
//
//  Created by saiten on 11/04/17.
//  Copyright 2011 iside. All rights reserved.
//

#import "TiProxy.h"
#import "SocketIoClient.h"

@interface SocketIOProxy : TiProxy <SocketIoClientDelegate> {
  NSThread *_socketThread;
  SocketIoClient *_client;
}

@property (nonatomic, readwrite, assign) NSNumber *connectTimeout;
@property (nonatomic, readwrite, assign) NSNumber *tryAgainOnConnectTimeout;
@property (nonatomic, readonly) NSString *sessionId;
@property (nonatomic, readonly) NSNumber *isConnected;
@property (nonatomic, readonly) NSNumber *isConnecting;

- (void)connect:(id)args;
- (void)disconnect:(id)args;
- (void)send: (id)args;

@end
