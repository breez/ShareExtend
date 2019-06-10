#import "ShareExtendPlugin.h"

@implementation FLTShareExtendPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* shareChannel = [FlutterMethodChannel
                                          methodChannelWithName:@"share_extend"
                                          binaryMessenger:[registrar messenger]];
    
    [shareChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"share" isEqualToString:call.method]) {
            NSDictionary *arguments = [call arguments];
            NSString *shareText = arguments[@"text"];
            NSString *shareType = arguments[@"type"];
            
            if (shareText.length == 0) {
                result(
                       [FlutterError errorWithCode:@"error" message:@"Non-empty text expected" details:nil]);
                return;
            }
            
            NSNumber *originX = arguments[@"originX"];
            NSNumber *originY = arguments[@"originY"];
            NSNumber *originWidth = arguments[@"originWidth"];
            NSNumber *originHeight = arguments[@"originHeight"];
            
            CGRect originRect;
            if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
                originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                        [originWidth doubleValue], [originHeight doubleValue]);
            }
        
            if ([shareType isEqualToString:@"text"]) {
                [self share:shareText atSource:originRect withResult:result];
            }  else if ([shareType isEqualToString:@"image"]) {
                UIImage *image = [UIImage imageWithContentsOfFile:shareText];
                [self share:image atSource:originRect withResult:result];
            } else {
                NSURL *url = [NSURL fileURLWithPath:shareText];
                [self share:url atSource:originRect withResult:result];
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

+ (void)share:(id)sharedItems atSource:(CGRect)origin withResult: (FlutterResult) result {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sharedItems] applicationActivities:nil];
    
    UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
    
    activityViewController.popoverPresentationController.sourceView = controller.view;
    if (!CGRectIsEmpty(origin)) {
        activityViewController.popoverPresentationController.sourceRect = origin;
    }
    [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        result(@(completed));
    }];
    [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end