#import <Foundation/Foundation.h>
#import "STHTTPRequest2.h"

// placeholder to simulate server responses
// to be used in a STHTTPRequestTestResponseQueue

typedef void(^FillResponseBlock)(STHTTPRequest2 *r);

@interface STHTTPRequestTestResponse : NSObject

@property (nonatomic, copy) FillResponseBlock block;

+ (STHTTPRequestTestResponse *)testResponseWithBlock:(FillResponseBlock)block;

@end
