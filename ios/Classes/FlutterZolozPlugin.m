#import "FlutterZolozPlugin.h"

#import <hummer/ZLZFacade.h>
#import <hummer/ZLZRequest.h>
#import <hummer/ZLZResponse.h>

@implementation FlutterZolozPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zoloz"
            binaryMessenger:[registrar messenger]];
  FlutterZolozPlugin* instance = [[FlutterZolozPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  instance.metainfo = [ZLZFacade getMetaInfo];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  __weak typeof(self) weakSelf = self;
  NSLog(@"handleMethodCall: %@",[call description]);
  if ([@"getMetaInfo" isEqualToString:call.method]) {
    result(@{@"code":@"ok",@"msg":@"ok",@"data":@{
      "metaInfo":weakSelf.metaInfo
    }});
  } else if ([@"startAuthWithConfig" isEqualToString:call.method]) {
    if ([call.arguments objectForKey:@"clientCfg"] != nil) {
      NSLog(@"clientCfg: %@",[[call.arguments objectForKey:@"clientCfg"] description]);
    } else {
        result(@{@"code":@"param_error",@"msg":@"no clientCfg",@"data":@{}});
        return;
    }
    if ([call.arguments objectForKey:@"callId"] != nil) {
      NSLog(@"callId: %@",[[call.arguments objectForKey:@"callId"] description]);
    } else {
        result(@{@"code":@"param_error",@"msg":@"no callId",@"data":@{}});
        return;
    }
    if ([call.arguments objectForKey:@"locate"] != nil) {
      NSLog(@"locate: %@",[[call.arguments objectForKey:@"locate"] description]);
    } else {
        result(@{@"code":@"param_error",@"msg":@"no locate",@"data":@{}});
        return;
    }
    if ([call.arguments objectForKey:@"publicKey"] != nil) {
      NSLog(@"publicKey: %@",[[call.arguments objectForKey:@"publicKey"] description]);
    } else {
        result(@{@"code":@"param_error",@"msg":@"no publicKey",@"data":@{}});
        return;
    }
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
       NSMutableDictionary *bizConfig = [NSMutableDictionary dictionary];
      [bizConfig setObject:rootViewController forKey:kZLZCurrentViewControllerKey];
      //.pass the public key to bizConfig
      [bizConfig setObject:publicKey forKey:kZLZPubkey];
      //.pass the locale to bizConfig
      [bizConfig setObject:locale forKey:kZLZLocaleKey]
      ZLZRequest *request = [[ZLZRequest alloc] initWithzlzConfig:[[call.arguments objectForKey:@"clientCfg"] toString] bizConfig:[[call.arguments objectForKey:@"clientCfg"] toString]];

      [[ZLZFacade sharedInstance] startWithRequest:request completeCallback:^(ZLZResponse *response) {
          NSLog(@"认证结果成功:%@", response);
          dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.channel invokeMethod: @"VerifyFinish" arguments:@{
                @"callId":call.arguments[@"callId"],
                @"clientCfg":call.arguments[@"clientCfg"],
                } result: ^(id _Nullable result) {
                          NSLog(@"result: %@",[result description]);
                      }];
            });
          
          NSLog(@"try call VerifyFinish from native");
      } interruptCallback:^(ZLZResponse *interrupt){
          NSLog(@"认证结果失败:%@", interrupt);

      }];


  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
