#import "STHTTPRequestTestResponseQueue.h"
#import "STHTTPRequestTestResponse.h"

static STHTTPRequestTestResponseQueue *sharedInstance = nil;

@implementation STHTTPRequestTestResponseQueue

+ (STHTTPRequestTestResponseQueue *)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[STHTTPRequestTestResponseQueue alloc] init];
    }
    return sharedInstance;
}

+ (void)reset {
    [sharedInstance release];
    sharedInstance= nil;
}

- (id)init {
    self = [super init];
    responses = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc {
    [responses release];
    [super dealloc];
}

/**/

- (NSUInteger)numberOfResponsesInQueue {
    return [responses count];
}

- (void)enqueue:(STHTTPRequestTestResponse *)response {
    NSAssert(response != nil, @"can't enqueue nil");

    [responses insertObject:response atIndex:0];
}

- (STHTTPRequestTestResponse *)dequeue {
    
    NSAssert([responses count] > 0, @"can't dequeue because queue is empty, count is %d", [responses count]);

    if([responses count] == 0) {
        return nil;
    }
    
    NSUInteger lastIndex = [responses count] - 1;
    
    STHTTPRequestTestResponse *response = [responses objectAtIndex:lastIndex];
    
    [responses removeObjectAtIndex:lastIndex];
    
    return response;
}

@end
