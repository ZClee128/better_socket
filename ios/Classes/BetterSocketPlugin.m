#import "BetterSocketPlugin.h"
#import <SRWebSocket.h>


@interface BetterSocketPlugin()<SRWebSocketDelegate>
@property (nonatomic,strong) SRWebSocket *webSocket;

@end

@implementation BetterSocketPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"better_socket"
            binaryMessenger:[registrar messenger]];
  BetterSocketPlugin* instance = [[BetterSocketPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"connentSocket" isEqualToString:call.method]) {
      NSDictionary *dict = call.arguments;
      self.webSocket.delegate = nil;
      [self.webSocket close];
      self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dict[@"path"]]]];
      self.webSocket.delegate = self;
      [self.webSocket open];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"message –> %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
}

//连接失败
-(void)webSocket:(SRWebSocket* )webSocket didFailWithError:(NSError* )error {
    NSLog(@"error --> %@", error);
    self.webSocket = nil;
}

// 连接关闭
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Closed Reason:%@",reason);
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"%@",reply);
}
@end

