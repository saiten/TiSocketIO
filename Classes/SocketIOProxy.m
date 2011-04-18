//
//  SocketIOProxy.m
//  tisocketio
//
//  Created by saiten on 11/04/17.
//  Copyright 2011 iside. All rights reserved.
//

#import "SocketIOProxy.h"
#import "TiUtils.h"

@implementation SocketIOProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context args:(NSArray *)args
{
  ENSURE_ARG_COUNT(args, 2);
  if((self = [super _initWithPageContext:context])) {
    ENSURE_TYPE([args objectAtIndex:0], NSString);
    NSString *host = [args objectAtIndex:0];
    ENSURE_TYPE([args objectAtIndex:1], NSNumber);
    int port = [TiUtils intValue:[args objectAtIndex:1] def:80];

    _socketThread = nil;
    _client = [[SocketIoClient alloc] initWithHost:host port:port];
    _client.delegate = self;
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)_destroy
{
  if([_socketThread isExecuting])
    [self performSelector:@selector(disconnect) onThread:_socketThread withObject:nil waitUntilDone:YES];
    
  RELEASE_TO_NIL(_client);
  [super _destroy];
}

#pragma mark Listener Notifications

- (void)_listenerAdded:(NSString*)type count:(int)count
{  
}

- (void)_listenerRemoved:(NSString*)type count:(int)count
{
}

#pragma mark Properties

- (void)setConnectTimeout: (id)args
{
  ENSURE_SINGLE_ARG(args, NSNumber);
  _client.connectTimeout = [TiUtils doubleValue:[args objectAtIndex:0]];
}

- (id)connectTimeout
{
  return NUMDOUBLE(_client.connectTimeout);
}

- (void)setTryAgainOnConnectTimeout:(id)args
{
  ENSURE_SINGLE_ARG(args, NSNumber);
  _client.tryAgainOnConnectTimeout = [TiUtils boolValue:[args objectAtIndex:0]];
}

- (id)tryAgainOnConnectTimeout
{
  return NUMBOOL(_client.tryAgainOnConnectTimeout);
}

- (id)sessionId
{
  return _client.sessionId;
}

- (id)isConnecting
{
  return NUMBOOL(_client.isConnecting);
}

- (id)isConnected
{
  return NUMBOOL(_client.isConnected);
}

#pragma mark Private APIs

#define AUTORELEASE_LOOP 5
- (void)socketRunLoop
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [_socketThread setName:[NSString stringWithFormat:@"co.saiten.ti.socket.io (%x)", self]];
  int counter = 0;
  while((_client.isConnected || _client.isConnecting) &&
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
  {
    if(++counter == AUTORELEASE_LOOP) {
      [pool release];
      pool = [[NSAutoreleasePool alloc] init];
      counter = 0;
    }
  }
  _socketThread = nil;
  [pool release];
}

- (void)_connect
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  _socketThread = [NSThread currentThread];
  [_client connect];
  
  [self socketRunLoop];
  [pool release];
}

#pragma mark Public APIs

- (void)connect:(id)args
{
  if(_socketThread == nil) {
    [self performSelectorInBackground:@selector(_connect) withObject:nil];
  }
}

- (void)disconnect:(id)args
{
  if(_socketThread == nil)
    return;
  
  if([NSThread currentThread] != _socketThread) {
    [self performSelector:@selector(disconnect:) onThread:_socketThread withObject:args waitUntilDone:YES];
    return;
  }
  
  [_client disconnect];
}

- (void)send:(id)args
{
  if(_socketThread == nil)
    return;
  
  if([NSThread currentThread] != _socketThread) {
    [self performSelector:@selector(send:) onThread:_socketThread withObject:args waitUntilDone:YES];
    return;
  }

  ENSURE_ARG_COUNT(args, 2);
  ENSURE_TYPE([args objectAtIndex:0], NSString);
  NSString *data = [args objectAtIndex:0];
  ENSURE_TYPE([args objectAtIndex:1], NSNumber);
  BOOL isJSON = [TiUtils boolValue:[args objectAtIndex:1]];

  [_client send:data isJSON:isJSON];
}

#pragma mark SocketIoClientDelegate

- (void)socketIoClientDidConnect:(SocketIoClient *)client
{
  NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:client, @"client", nil];
  [self fireEvent:@"connect" withObject:dic];
}

- (void)socketIoClientDidDisconnect:(SocketIoClient *)client
{
  NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:client, @"client", nil];
  [self fireEvent:@"disconnect" withObject:dic];
}

- (void)socketIoClient:(SocketIoClient *)client didReceiveMessage:(NSString *)message isJSON:(BOOL)isJSON
{
  NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:client, @"client", message, @"message", isJSON, @"isJSON", nil];
  [self fireEvent:@"message" withObject:dic];
}

- (void)socketIoClient:(SocketIoClient *)client didSendMessage:(NSString *)message isJSON:(BOOL)isJSON
{
  NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:client, @"client", message, @"message", isJSON, @"isJSON", nil];
  [self fireEvent:@"sendmessage" withObject:dic];
}

@end
