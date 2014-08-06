//
//  STHTTPRequestAsyncTests.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 06/08/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "STHTTPRequest.h"

@interface STHTTPRequestAsyncTests : SenTestCase

@end

// https://www.mikeash.com/pyblog/friday-qa-2011-07-22-writing-unit-tests.html
BOOL WaitFor(BOOL (^block)(void))
{
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while(!block() && [[NSProcessInfo processInfo] systemUptime] - start <= 10)
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    return block();
}

@implementation STHTTPRequestAsyncTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://www.perdu.com"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNotNil(body, @"failed to load body from URL");
    STAssertNil(error, @"got an error when loading URL");
}

- (void)testRedirect
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/redirect/6"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNotNil(body, @"failed to load body from URL");
    STAssertNil(error, @"got an error when loading URL");
}

- (void)testDelay
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/delay/2"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNotNil(body, @"failed to load body from URL");
    STAssertNil(error, @"got an error when loading URL");
}

- (void)testBasicAuthenticationSuccess
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/basic-auth/myuser/mypassword"];
    
    [r setUsername:@"myuser" password:@"mypassword"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNotNil(body, @"failed to load body from URL");
    STAssertNil(error, @"got an error when loading URL");
}

- (void)testBasicAuthenticationFailing
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/basic-auth/myuser/mypassword"];
    
    [r setUsername:@"myuser" password:@"badpassword"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNil(body, @"failed to load body from URL");
    STAssertNotNil(error, @"got an error when loading URL");
}

- (void)testDigestAuthenticationSuccess
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/basic-auth/myuser/mypassword"];
    
    [r setUsername:@"myuser" password:@"mypassword"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNotNil(body, @"failed to load body from URL");
    STAssertNil(error, @"got an error when loading URL");
}

- (void)testDigestAuthenticationFailing
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/digest-auth/auth/myuser/mypassword"];
    
    [r setUsername:@"myuser" password:@"badpassword"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertNil(body, @"failed to load body from URL");
    STAssertNotNil(error, @"got an error when loading URL");
}

- (void)testStatusCode
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    __block NSInteger responseStatus = 0;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/status/418"];
    __weak typeof(r) wr = r;
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
        responseStatus = wr.responseStatus;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    STAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    STAssertTrue(r.responseStatus == 418, @"bad response status");
}

@end
