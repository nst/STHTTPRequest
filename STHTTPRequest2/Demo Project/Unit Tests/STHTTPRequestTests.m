//
//  STHTTPRequestDemoTests.m
//  STHTTPRequestDemoTests
//
//  Created by Nicolas Seriot on 8/10/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "STHTTPRequest.h"

#import "STHTTPRequestTestResponse.h"
#import "STHTTPRequestTestResponseQueue.h"

#import "STHTTPRequest+UnitTests.h"



@interface STHTTPRequestTests : XCTestCase

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
    
    XCTAssertTrue(numberOfReponsesLeft == 0, @"still %@ responses in queue", @(numberOfReponsesLeft));

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
    
    XCTAssertNil(r.error, @"error should be nil: %@", r.error);
    XCTAssertTrue(r.responseStatus == 200, @"bad response status: %@", @(r.responseStatus));
    XCTAssertEqualObjects(r.responseHeaders, @{ @"key" : @"value" }, @"bad headers: %@", [r responseHeaders]);
    XCTAssertEqualObjects(r.responseString, @"OK", @"bad response: %@", r.responseString);
}

- (void)testStreaming {
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://www.google.com"];
    
    r.downloadProgressBlock = ^(NSData *data, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive) {
        NSLog(@"-- %@", data);
    };
    
    r.errorBlock = ^(NSError *error) {
        // use error
    };
    
    [r startAsynchronous]; // will actually get executed sychronously for tests

    /**/
    
    [r unitTests_addDownloadProgressUTF8String:@"asd"];
    
    XCTAssertTrue([r.responseData length] == 3, @"");
}

- (void)testStringByAppendingGETParameters {
    NSString *s = @"http://www.test.com/x?b=1";
    
    NSDictionary *d = @{@"a":@"1", @"c":@"1"};
    
    NSString *s2 = [s st_stringByAppendingGETParameters:d doApplyURLEncoding:NO];
    
    XCTAssertTrue(s2, @"http://www.test.com/x?b=1&a=1&c=1");
}

@end
