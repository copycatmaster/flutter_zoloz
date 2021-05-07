#import "FlutterZolozPlugin.h"

#import <hummer/ZLZFacade.h>
#import <hummer/ZLZRequest.h>
#import <hummer/ZLZResponse.h>
#import <hummer/ZLZHummerFacade.h>


@protocol ZolozkitViewControllerDelegate
- (void)onResult:(BOOL)isSuccess withInfo:(NSDictionary *)info;
@end

//临时构造的 viewcontroller 外部把参数全都传进去
@interface ZolozkitViewController : UIViewController
@property(nonatomic,assign) int callId;
@property(nonatomic, copy) NSString *clientCfg;
@property(nonatomic, copy) NSDictionary *bizCfg;
@property(nullable, nonatomic, weak) id <ZolozkitViewControllerDelegate> delegate;
@end

@implementation ZolozkitViewController
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"ZolozkitViewController viewWillAppear");
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    NSLog(@"ZolozkitViewController viewDidLoad");
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self startZoloz];
}

- (void)startZoloz {
    //NSLog(@"ZolozkitViewController startZoloz");
    //NSLog(@"ZolozkitViewController params %@ %@",self.clientCfg,self.bizCfg);
    ZLZRequest *request = [[ZLZRequest alloc] initWithzlzConfig:self.clientCfg bizConfig:self.bizCfg];
    
    __weak typeof(self) weakSelf = self;
    [[ZLZFacade sharedInstance]
            startWithRequest:request
            completeCallback:^(ZLZResponse *response) {
                NSLog(@"Zolozkit  startWithRequest completeCallback !!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf) {
                        [weakSelf dismissViewControllerAnimated:NO completion:^{
                            [weakSelf.delegate onResult:YES withInfo:@{
                                @"callId":[NSNumber numberWithInt:weakSelf.callId],
                                @"retcode":response.retcode,
                                @"extInfo":response.extInfo
                            }];
                        }];
                    }

                });
            }
           interruptCallback:^(ZLZResponse *response) {
        NSLog(@"Zolozkit  startWithRequest interruptCallback !!");
               dispatch_async(dispatch_get_main_queue(), ^{
                   if (weakSelf) {
                       [weakSelf dismissViewControllerAnimated:NO completion:^{
                           [weakSelf.delegate onResult:NO withInfo:@{
                               @"callId":[NSNumber numberWithInt:weakSelf.callId],
                               @"retcode":response.retcode,
                               @"extInfo":response.extInfo
                           }];
                       }];
                   }
               });
           }];
    NSLog(@"Zolozkit  startWithRequest called!!");
}

@end

@interface FlutterZolozPlugin ()
    <ZolozkitViewControllerDelegate>
@end


@implementation FlutterZolozPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zoloz"
            binaryMessenger:[registrar messenger]];
  FlutterZolozPlugin* instance = [[FlutterZolozPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSLog(@"handleMethodCall: %@",[call description]);
  if ([@"getMetaInfo" isEqualToString:call.method]) {
    result(@{@"code":@"ok",@"msg":@"ok",@"data":@{
                     @"metaInfo":[ZLZFacade getMetaInfo]
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
    if ([call.arguments objectForKey:@"locale"] != nil) {
      NSLog(@"locale: %@",[[call.arguments objectForKey:@"locale"] description]);
    } else {
        result(@{@"code":@"param_error",@"msg":@"no locale",@"data":@{}});
        return;
    }
    if ([call.arguments objectForKey:@"publicKey"] != nil) {
      NSLog(@"publicKey: %@",[[call.arguments objectForKey:@"publicKey"] description]);
    } else {
        result(@{@"code":@"param_error",@"msg":@"no publicKey",@"data":@{}});
        return;
    }
    NSString * publicKey = [call.arguments objectForKey:@"publicKey"];
    NSString * locale = [call.arguments objectForKey:@"locale"];
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
      
    ZolozkitViewController *viewController = [[ZolozkitViewController alloc] init];
    viewController.clientCfg = [call.arguments objectForKey:@"clientCfg"];
    
    NSMutableDictionary *bizConfig = [[NSMutableDictionary alloc] init];
    [bizConfig setObject:viewController forKey:kZLZCurrentViewControllerKey];
    [bizConfig setObject:publicKey forKey:kZLZPubkey];
    [bizConfig setObject:locale forKey:kZLZLocaleKey];
      NSLog(@"!!!!kZLZCurrentViewControllerKey is %@",kZLZCurrentViewControllerKey);
      NSLog(@"!!!!kZLZPubkey is %@",kZLZPubkey);
      NSLog(@"!!!!kZLZLocaleKey is %@",kZLZLocaleKey);
      
    viewController.bizCfg = bizConfig;
    viewController.callId =[[call.arguments objectForKey:@"callId"] intValue];
    viewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
      NSLog(@"show UINavigationController now ");
      [rootViewController presentViewController:navigationController animated:NO completion:nil];
      NSLog(@"show UINavigationController now done");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onResult:(BOOL)isSuccess withInfo:(NSDictionary *)info {
    [self.channel invokeMethod:@"VerifyFinish" arguments:info result: ^(id _Nullable result) {
        NSLog(@"result: %@",[result description]);
    }];
}
 

@end
