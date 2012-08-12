#import <Foundation/Foundation.h>

@class STHTTPRequestTestResponse;

@interface STHTTPRequestTestResponseQueue : NSObject {
    NSMutableArray *responses;
}

+ (STHTTPRequestTestResponseQueue *)sharedInstance;
+ (void)reset;

- (void)enqueue:(STHTTPRequestTestResponse *)response;
- (STHTTPRequestTestResponse *)dequeue;

- (NSUInteger)numberOfResponsesInQueue;

@end
