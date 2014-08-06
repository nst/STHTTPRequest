//
//  STHTTPRequestDemoTests.m
//  STHTTPRequestDemoTests
//
//  Created by Nicolas Seriot on 8/10/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "STHTTPRequest.h"

#import "STHTTPRequestTestResponse.h"
#import "STHTTPRequestTestResponseQueue.h"

#import "STHTTPRequest+UnitTests.h"

@interface STHTTPRequestTests : SenTestCase

@end

@implementation STHTTPRequestTests

- (void)setUp {
    [super setUp];
        
    // Set-up code here.

    [STHTTPRequestTestResponseQueue sharedInstance].responses = [NSMutableArray array];
}

- (void)tearDown {
    // Tear-down code here.
    
    NSUInteger numberOfReponsesLeft = [[STHTTPRequestTestResponseQueue sharedInstance].responses count];
    
    STAssertTrue(numberOfReponsesLeft == 0, @"still %d responses in queue", numberOfReponsesLeft);

    [super tearDown];
}

- (void)testExample {
    
    STHTTPRequestTestResponseQueue *queue = [STHTTPRequestTestResponseQueue sharedInstance];

    STHTTPRequestTestResponse *tr = [STHTTPRequestTestResponse testResponseWithBlock:^(STHTTPRequest *r) {
        r.responseStatus = 200; // by default
        r.responseHeaders = @{ @"key" : @"value" };
        r.responseString = @"OK";
        
        // r.error = [NSError errorWithDomain:@"MyDomain" code:0 userInfo:nil]; // to simulate errors
    }];
    
    [queue enqueue:tr];
    
    /**/
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://www.google.com"];
    
    r.completionBlock = ^(NSDictionary *headers, NSString *responseString) {
        // use response
    };

    r.errorBlock = ^(NSError *error) {
        // use error
    };

    [r startAsynchronous]; // will actually get executed sychronously for tests
    
    STAssertTrue(r.error == nil, [NSString stringWithFormat:@"error should be nil: %@", r.error]);
    STAssertTrue(r.responseStatus == 200, @"bad response status: %@", @(r.responseStatus));
    STAssertEqualObjects(r.responseHeaders, @{ @"key" : @"value" }, [NSString stringWithFormat:@"bad headers: %@", [r responseHeaders]]);
    STAssertEqualObjects(r.responseString, @"OK", [NSString stringWithFormat:@"bad response: %@", r.responseString]);
}

- (void)testStreaming {
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://www.google.com"];
    
    r.downloadProgressBlock = ^(NSData *data, NSUInteger totalBytesReceived, long long totalBytesExpectedToReceive) {
        NSLog(@"-- %@", data);
    };
    
    r.errorBlock = ^(NSError *error) {
        // use error
    };
    
    [r startAsynchronous]; // will actually get executed sychronously for tests

    /**/
    
    [r unitTests_addDownloadProgressUTF8String:@"asd"];
    
    STAssertTrue([r.responseData length] == 3, @"");
}

@end
