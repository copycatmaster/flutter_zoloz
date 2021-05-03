#import "FlutterZolozPlugin.h"

#import <zolozkit/ZLZFacade.h>
#import <zolozkit/ZLZRequest.h>
#import <zolozkit/ZLZResponse.h>


@protocol ZolozkitViewControllerDelegate
- (void)onResult:(BOOL)isSuccess withInfo:(NSDictionary *)info;
@end

//临时构造的 viewcontroller 外部把参数全都传进去
@interface ZolozkitViewController : UIViewController
@property(nonatomic,assign) int callId;
@property(nonatomic, strong) NSString *clientCfg;
@property(nonatomic, strong) NSDictionary *bizCfg;
@property(nullable, nonatomic, weak) id <ZolozkitViewControllerDelegate> delegate;
@end

@implementation ZolozkitViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self startZoloz];
}

- (void)startZoloz {
    ZLZRequest *request = [[ZLZRequest alloc] initWithzlzConfig:self.clientCfg bizConfig:self.bizCfg];
    __weak typeof(self) weakSelf = self;
    [[ZLZFacade sharedInstance]
            startWithRequest:request
            completeCallback:^(ZLZResponse *response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:NO completion:^{
                        [weakSelf.delegate onResult:YES withInfo:@{
                            @"callId":[NSNumber numberWithInt:weakSelf.callId],
                            @"retcode":response.retcode,
                            @"extInfo":response.extInfo
                        }];
                    }];
                });
            }
           interruptCallback:^(ZLZResponse *response) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [weakSelf dismissViewControllerAnimated:NO completion:^{
                       [weakSelf.delegate onResult:NO withInfo:@{
                           @"callId":[NSNumber numberWithInt:weakSelf.callId],
                           @"retcode":response.retcode,
                           @"extInfo":response.extInfo
                       }];
                   }];
               });
           }];
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
  [registrar addMethodCallDelegate:instance channel:channel];
  instance.metainfo = [ZLZFacade getMetaInfo];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  __weak typeof(self) weakSelf = self;
  NSLog(@"handleMethodCall: %@",[call description]);
  if ([@"getMetaInfo" isEqualToString:call.method]) {
    result(@{@"code":@"ok",@"msg":@"ok",@"data":@{
                     @"metaInfo":weakSelf.metainfo
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
    viewController.bizCfg = bizConfig;
    viewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootViewController presentViewController:navigationController animated:NO completion:nil];

  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onResult:(BOOL)isSuccess info:(NSDictionary *)info {
    [self.channel invokeMethod:@"VerifyFinish" arguments:info result: ^(id _Nullable result) {
        NSLog(@"result: %@",[result description]);
    }];
}

@end
