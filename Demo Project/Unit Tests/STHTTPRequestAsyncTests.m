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
    [STHTTPRequest deleteAllCookiesFromLocalCookieStorage];
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageLocal];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://www.perdu.com"];
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        NSAssert([NSThread currentThread] == [NSThread mainThread], @"not on main thread");
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        NSAssert([NSThread currentThread] == [NSThread mainThread], @"not on main thread");
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNotNil(body, @"failed to load body from URL");
    XCTAssertNil(error, @"got an error when loading URL");
}

- (NSArray *)cookiesSentBySTHTTPRequestAfterNSURLConnection {
    // 1. set cookie a=b with NSURLConnection directly
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.org/cookies/set?a=b"]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    XCTAssert(data);
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"-- %@", s);
    
    // 2. ensure that shared cookies contains a=b
    
    NSArray *sharedCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    XCTAssertEqual([sharedCookies count], 1);
    NSHTTPCookie *cookie = [sharedCookies lastObject];
    XCTAssertEqualObjects(cookie.properties[NSHTTPCookieName], @"a");
    XCTAssertEqualObjects(cookie.properties[NSHTTPCookieValue], @"b");
    
    // 3. new request with c=d
    
    STHTTPRequest *r3 = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies"];
    [r3 addCookieWithName:@"c" value:@"d"];
    NSError *error3 = nil;
    [r3 startSynchronousWithError:&error3];
    
    // 4. new request with c=e
    
    STHTTPRequest *r4 = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies"];
    [r4 addCookieWithName:@"c" value:@"e"];
    NSError *error4 = nil;
    [r4 startSynchronousWithError:&error4];
    
    return [r4 requestCookies];
}

- (void)testCookiesStorageShared {
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageShared];
    
    NSArray *cookies = [self cookiesSentBySTHTTPRequestAfterNSURLConnection];
    XCTAssertEqual([cookies count], 2);
    
    BOOL cookieABExists = NO;
    BOOL cookieCDExists = NO;
    BOOL cookieCEExists = NO;

    for(NSHTTPCookie *c in cookies) {
        NSDictionary *properties = [c properties];
        NSString *name = properties[NSHTTPCookieName];
        NSString *value = properties[NSHTTPCookieValue];
        if([name isEqualToString:@"a"] && [value isEqualToString:@"b"]) cookieABExists = YES;
        if([name isEqualToString:@"c"] && [value isEqualToString:@"d"]) cookieCDExists = YES;
        if([name isEqualToString:@"c"] && [value isEqualToString:@"e"]) cookieCEExists = YES;
    }
    
    XCTAssertTrue(cookieABExists); // AB is sent
    XCTAssertFalse(cookieCDExists); // CD is NOT sent - it was replaced by CE
    XCTAssertTrue(cookieCEExists); // CE is sent
}

- (void)testCookiesStorageLocal {
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageLocal];
    
    NSArray *cookies = [self cookiesSentBySTHTTPRequestAfterNSURLConnection];
    XCTAssertEqual([cookies count], 2);
    
    BOOL cookieABExists = NO;
    BOOL cookieCDExists = NO;
    BOOL cookieCEExists = NO;
    
    for(NSHTTPCookie *c in cookies) {
        NSDictionary *properties = [c properties];
        NSString *name = properties[NSHTTPCookieName];
        NSString *value = properties[NSHTTPCookieValue];
        if([name isEqualToString:@"a"] && [value isEqualToString:@"b"]) cookieABExists = YES;
        if([name isEqualToString:@"c"] && [value isEqualToString:@"d"]) cookieCDExists = YES;
        if([name isEqualToString:@"c"] && [value isEqualToString:@"e"]) cookieCEExists = YES;
    }
    
    XCTAssertFalse(cookieABExists); // AB is NOT sent
    XCTAssertTrue(cookieCDExists); // CD is sent
    XCTAssertTrue(cookieCEExists); // CE is sent
}

- (void)testCookiesNoStorage {
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageNoStorage];
    
    NSArray *cookies = [self cookiesSentBySTHTTPRequestAfterNSURLConnection];
    XCTAssertEqual([cookies count], 1);
    
    BOOL cookieABExists = NO;
    BOOL cookieCDExists = NO;
    BOOL cookieCEExists = NO;
    
    for(NSHTTPCookie *c in cookies) {
        NSDictionary *properties = [c properties];
        NSString *name = properties[NSHTTPCookieName];
        NSString *value = properties[NSHTTPCookieValue];
        if([name isEqualToString:@"a"] && [value isEqualToString:@"b"]) cookieABExists = YES;
        if([name isEqualToString:@"c"] && [value isEqualToString:@"d"]) cookieCDExists = YES;
        if([name isEqualToString:@"c"] && [value isEqualToString:@"e"]) cookieCEExists = YES;
    }
    
    XCTAssertFalse(cookieABExists); // AB is NOT sent
    XCTAssertFalse(cookieCDExists); // CD is NOT sent
    XCTAssertTrue(cookieCEExists); // CE is sent
}

- (void)testRedirect {
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

- (void)testDelay {
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

- (void)testBasicAuthenticationSuccess {
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

- (void)testBasicAuthenticationFailing {
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

- (void)testDigestAuthenticationSuccess {
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

- (void)testDigestAuthenticationFailing {
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

- (void)testStatusCodeOK {
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

- (void)testStreaming {
    __block NSData *data = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/stream-bytes/1024"];
    
    r.completionDataBlock = ^(NSDictionary *theHeaders, NSData *theData) {
        data = theData;
    };
    
    r.downloadProgressBlock = ^(NSData *data, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive) {
        
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

- (void)testNoTimeout {
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

- (void)testCookiesWithSharedStorage {
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageShared];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies/set?name=value"];
    
    r.preventRedirections = YES;
    
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
    
    // shared cookies should not be empty
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org"];
    NSArray *cookiesFromSharedCookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    XCTAssertEqual([cookiesFromSharedCookieStorage count], 1);
}

- (void)testCookiesWithLocalStorage
{
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageLocal];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies/set?name=value"];
    
    r.preventRedirections = YES;
    
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

- (void)testCookiesWithSharedStorageOverriddenByNoStorageAtInstanceLevel {
    __block NSString *body = nil;
    __block NSDictionary *headers = nil;
    __block NSError *error = nil;
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageShared];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies/set?name=value"];
    
    r.cookieStoragePolicyForInstance = STHTTPRequestCookiesStorageNoStorage;
    
    r.preventRedirections = YES;
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        headers = theHeaders;
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(error, @"error");
    
    // ephemeral session cookie should be set
    XCTAssertEqual([[r requestCookies] count], 1);
    
    // but shared cookies should be empty
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org"];
    NSArray *cookiesFromSharedCookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    XCTAssertEqual([cookiesFromSharedCookieStorage count], 0);
    
    // set-cookie header should still be present
    XCTAssertNotNil(headers[@"Set-Cookie"], @"set-cookie header is missing");
}

- (void)testCookiesWithNoStorage {
    __block NSString *body = nil;
    __block NSDictionary *headers = nil;
    __block NSError *error = nil;
    
    [STHTTPRequest setGlobalCookiesStoragePolicy:STHTTPRequestCookiesStorageNoStorage];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/cookies/set?name=value"];
    
    r.preventRedirections = YES;
    
    //    r.ignoreSharedCookiesStorage = NO; // default
    
    r.completionBlock = ^(NSDictionary *theHeaders, NSString *theBody) {
        headers = theHeaders;
        body = theBody;
    };
    
    r.errorBlock = ^(NSError *theError) {
        error = theError;
    };
    
    [r startAsynchronous];
    
    XCTAssertTrue(WaitFor(^BOOL { return body || error; }), @"async URL loading failed");
    XCTAssertNil(error, @"error");
    
    // one cookie was sent
    XCTAssertEqual([[r requestCookies] count], 1);
    
    // shared cookies should be empty
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org"];
    NSArray *cookiesFromSharedCookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    XCTAssertEqual([cookiesFromSharedCookieStorage count], 0);
    
    // set-cookie header should still be present
    XCTAssertNotNil(headers[@"Set-Cookie"], @"set-cookie header is missing");
}

- (void)testStatusPUT {
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

- (void)testStatusPOST {
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/post"];
    
    r.HTTPMethod = @"POST";
    
    r.POSTDictionary = @{@"grant_type":@"client_credentials"};
    
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
    
    XCTAssertTrue([json[@"form"] isEqualToDictionary:@{@"grant_type":@"client_credentials"}]);
}

- (void)testStatusPOSTRaw {
    __block NSString *body = nil;
    __block NSError *error = nil;
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://httpbin.org/post"];
    
    r.HTTPMethod = @"POST";
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"asd":@"sdf"} options:0 error:nil];
    
    r.rawPOSTData = data;
    
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
    
    NSLog(@"--> %@", r.responseString);

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:r.responseData options:0 error:nil];
    
    XCTAssertTrue([json[@"json"] isEqualToDictionary:@{@"asd":@"sdf"}]);
}

@end
