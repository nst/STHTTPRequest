//
//  STHTTPRequest+UnitTests.m
//
//  Created by Nicolas Seriot on 8/8/12.
//
//

#import "STHTTPRequest+UnitTests.h"
#import "STHTTPRequestTestResponse.h"
#import "STHTTPRequestTestResponseQueue.h"

#import <objc/runtime.h>
#import <objc/message.h>

void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@implementation STHTTPRequest (UnitTests)

@dynamic responseStatus;
@dynamic responseString;
@dynamic responseHeaders;
@dynamic reponseData;
@dynamic error;

+ (void)initialize {
    Swizzle([STHTTPRequest class], @selector(startAsynchronous), @selector(unitTests_startAsynchronous));
    Swizzle([STHTTPRequest class], @selector(unitTests_startSynchronousWithError:), @selector(startSynchronousWithError:));
}

- (void)unitTests_startAsynchronous {

    STHTTPRequestTestResponse *tr = [[STHTTPRequestTestResponseQueue sharedInstance] dequeue];
    
    NSAssert(tr.block != nil, @"block needed");
    
    tr.block(self);
}

- (NSString *)unitTests_startSynchronousWithError:(NSError **)error {
    
    STHTTPRequestTestResponse *tr = [[STHTTPRequestTestResponseQueue sharedInstance] dequeue];
    
    NSAssert(tr.block != nil, @"block needed");
    
    tr.block(self);

    if(error) {
        *error = self.error;
    }

    return self.responseString;
}

@end
