//
//  main.m
//  cli
//
//  Created by Nicolas Seriot on 14/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STHTTPRequest.h"

#define SYNCHRONOUS 0

int main(int argc, const char * argv[])
{

    @autoreleasepool {

#if SYNCHRONOUS
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://perdu.com"];
        NSError *error = nil;
        [r startSynchronousWithError:&error];
        NSLog(@"--> %@", r.responseString);
#else
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://perdu.com"];
        
        r.completionBlock = ^(NSDictionary *headers, NSString *body) {
            NSLog(@"-- %@", body);
            exit(0);
        };
        
        r.errorBlock = ^(NSError *error) {
            NSLog(@"-- %@", error);
            exit(1);
        };
        
        [r startAsynchronous];
        
        [[NSRunLoop currentRunLoop] run];
#endif
        
    }
    return 0;
}

