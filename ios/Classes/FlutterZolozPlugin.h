#import <Flutter/Flutter.h>

@interface FlutterZolozPlugin : NSObject<FlutterPlugin>
{
    
}
@property (nonatomic,retain) FlutterMethodChannel * channel;
@property (nonatomic,retain) NSString * metainfo;
@end
