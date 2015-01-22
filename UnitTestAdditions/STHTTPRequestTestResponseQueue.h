#import <Foundation/Foundation.h>

@class STHTTPRequestTestResponse;

@interface STHTTPRequestTestResponseQueue : NSObject

@property (nonatomic, retain) NSMutableArray *responses;

+ (instancetype)sharedInstance;

- (void)enqueue:(STHTTPRequestTestResponse *)response;
- (STHTTPRequestTestResponse *)dequeue;

@end
