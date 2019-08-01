#import "BetterSocketPlugin.h"
#import <SRWebSocket.h>


@interface BetterSocketPlugin()<SRWebSocketDelegate>
@property (nonatomic,strong) SRWebSocket *webSocket;
@property (nonatomic,copy)FlutterResult myResult;
@property (nonatomic,copy)FlutterResult sendResult;
@property (nonatomic,copy)FlutterResult closeResult;
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
        self.myResult = result;
    } else if ([@"sendMsg" isEqualToString:call.method]){
        NSDictionary *dict = call.arguments;
        [self.webSocket send:dict[@"msg"]];
        self.sendResult = result;
    } else if ([@"close" isEqualToString:call.method]) {
        [self.webSocket close];
        self.closeResult = result;
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    self.sendResult(message);
    NSLog(@"message –> %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
    self.myResult(@(YES));
}

//连接失败
-(void)webSocket:(SRWebSocket* )webSocket didFailWithError:(NSError* )error {
    NSLog(@"error --> %@", error);
    self.myResult(@(NO));
    self.webSocket = nil;
}

// 连接关闭
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Closed Reason:%@",reason);
    self.closeResult(@(YES));
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"%@",reply);
}
@end

