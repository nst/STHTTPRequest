#import <Foundation/Foundation.h>
#import "STHTTPRequest.h"

// placeholder to simulate server responses
// to be used in a SQServerTestResponseQueue

typedef void(^MyBlock)(STHTTPRequest *r);

@interface STHTTPRequestTestResponse : NSObject

@property (nonatomic, copy) MyBlock block;

+ (STHTTPRequestTestResponse *)testResponseWithBlock:(MyBlock)block;

@end
