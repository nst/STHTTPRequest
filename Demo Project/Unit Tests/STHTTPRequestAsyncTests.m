//
//  STHTTPRequestAsyncTests.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 06/08/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "STHTTPRequest.h"

@interface STHTTPRequestAsyncTests : XCTestCase

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
    
    [STHTTPRequest deleteAllCredentials];
    [STHTTPRequest deleteAllCookiesFromSharedCookieStorage];
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(body, @"failed to load body from URL");
    XCTAssertNil(error, @"got an error when loading URL");
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(body, @"failed to load body from URL");
    XCTAssertNil(error, @"got an error when loading URL");
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(body, @"failed to load body from URL");
    XCTAssertNil(error, @"got an error when loading URL");
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(body, @"failed to load body from URL");
    XCTAssertNil(error, @"got an error when loading URL");
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(body, @"failed to load body from URL");
    XCTAssertNotNil(error, @"got an error when loading URL");
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(body, @"failed to load body from URL");
    XCTAssertNil(error, @"got an error when loading URL");
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(body, @"failed to load body from URL");
    XCTAssertNotNil(error, @"got an error when loading URL");
}

- (void)testStatusCodeError
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
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertTrue(r.responseStatus == 418, @"bad response status");
}

- (void)testStatusCodeOK
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    __block NSInteger responseStatus = 0;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/status/200"];
    __weak typeof(r) wr = r;
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
        responseStatus = wr.responseStatus;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(error, @"got an error when loading URL");
    XCTAssertTrue(r.responseStatus == 200, @"bad response status");
}

- (void)testStreaming
{
    __block NSData *data = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/stream-bytes/1024"];
    
    r.completionDataBlock = ^(NSDictionary *theHeaders, NSData *theData) {
        data = theData;
    };
    
    r.downloadProgressBlock = ^(NSData *data, NSUInteger totalBytesReceived, long long totalBytesExpectedToReceive) {
        
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return data || error; }), @"async URL loading failed");
    XCTAssertTrue([r.responseData length] == 1024, @"bad response data length");
}

- (void)testTimeout
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    __block NSInteger responseStatus = 0;

    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/delay/3"];
    r.timeoutSeconds = 6;
    __weak typeof(r) wr = r;
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        responseStatus = wr.responseStatus;
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(error, @"error");
    XCTAssertTrue(responseStatus == 200, @"bad response status");
}

- (void)testNoTimeout
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/delay/6"];
    r.timeoutSeconds = 4;
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        //
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(error, @"missed the timeout error");
    XCTAssertTrue([[error domain] isEqualToString:NSURLErrorDomain], @"bad error domain");
    XCTAssertTrue([error code] == -1001, @"bad error code");
}

- (void)testCookies
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies/set?name=value"];

    r.preventRedirections = YES;
    
    r.ignoreSharedCookiesStorage = YES;
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(error, @"error");
    
    // session cookie should be set
    XCTAssertEqual([[r sessionCookies] count], 1);
    
    // but shared cookies should be empty
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org"];
    NSArray *cookiesFromSharedCookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    XCTAssertEqual([cookiesFromSharedCookieStorage count], 0);
}

- (void)testStatusPUT
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/put"];
    
    r.HTTPMethod = @"PUT";
    
    r.POSTDictionary = @{@"asd":@"sdf"};

    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(error, @"got an error when loading URL");
    XCTAssertTrue(r.responseStatus == 200, @"bad response status");

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:r.responseData options:0 error:nil];
    
    XCTAssertTrue([json[@"form"] isEqualToDictionary:@{@"asd":@"sdf"}]);
}

@end
