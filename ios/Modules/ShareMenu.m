#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(ShareMenu, RCTEventEmitter)

RCT_EXTERN_METHOD(getSharedText:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(donateShareIntent:(NSDictionary*)options
                            resolve:(RCTPromiseResolveBlock)resolver
                             reject:(RCTPromiseRejectBlock)rejecter)

@end
