//
//  STHTTPRequest.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "STHTTPRequest.h"

static NSMutableDictionary *credentialsStorage;

@implementation STHTTPRequest

@synthesize completionBlock;
@synthesize errorBlock;
@synthesize responseHeaders;
@synthesize credential;
@synthesize proxyCredential;
@synthesize POSTDictionary;
@synthesize responseData;
@synthesize url;
@synthesize responseStatus;
@synthesize textEncodingName;
@synthesize postDataEncoding;

#pragma mark Initializers

+ (STHTTPRequest *)requestWithURL:(NSURL *)url {
    if(url == nil) return nil;
    return [[[self alloc] initWithURL:url] autorelease];
}

+ (STHTTPRequest *)requestWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    return [self requestWithURL:url];
}

- (STHTTPRequest *)initWithURL:(NSURL *)theURL {
    
    if (self = [super init]) {
        url = [theURL retain];
        responseData = [[NSMutableData alloc] init];
        customRequestHeaders = [[NSMutableDictionary dictionary] retain];
        postDataEncoding = NSUTF8StringEncoding;
    }
    
    return self;
}

+ (void)clearSession {
    [self deleteAllCookies];
    [self deleteAllCredentials];
}

- (void)dealloc {
    [textEncodingName release];
    [customRequestHeaders release];
    [url release];
    [responseData release];
    [responseHeaders release];
    [completionBlock release];
    [errorBlock release];
    [credential release];
    [proxyCredential release];
    [POSTDictionary release];
    [super dealloc];
}

#pragma mark Credentials

+ (NSMutableDictionary *)credentialsStorage {
    if(credentialsStorage == nil) {
        credentialsStorage = [[NSMutableDictionary dictionary] retain];
    }
    return credentialsStorage;
}

+ (NSURLCredential *)sessionAuthenticationCredentialsForURL:(NSURL *)requestURL {
    return [[[self class] credentialsStorage] valueForKey:[requestURL host]];
}

+ (void)deleteAllCredentials {
    [credentialsStorage autorelease];
    credentialsStorage = [[NSMutableDictionary dictionary] retain];
}

- (void)setCredential:(NSURLCredential *)c {
#if DEBUG
    NSAssert(url, @"missing url to set credential");
#endif
    [[[self class] credentialsStorage] setObject:c forKey:[url host]];
}

- (NSURLCredential *)credential {
    return [[[self class] credentialsStorage] valueForKey:[url host]];
}

- (void)setUsername:(NSString *)username password:(NSString *)password {
    self.credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
}

- (NSString *)username {
    return [[self credential] user];
}

- (NSString *)password {
    return [[self credential] password];
}

#pragma mark Cookies

+ (NSArray *)sessionCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    return [cookieStorage cookies];
}

+ (void)deleteSessionCookies {
    for(NSHTTPCookie *cookie in [self sessionCookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+ (void)deleteAllCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (void)setCookie:(NSHTTPCookie *)cookie forURL:(NSURL *)url {
    NSArray *cookies = [NSArray arrayWithObject:cookie];
	
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];    
}

+ (void)setCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url {
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             name, NSHTTPCookieName,
                                             value, NSHTTPCookieValue,
                                             [url host], NSHTTPCookieDomain,
                                             [url host], NSHTTPCookieOriginURL,
                                             @"FALSE", NSHTTPCookieDiscard,
                                             @"/", NSHTTPCookiePath,
                                             @"0", NSHTTPCookieVersion,
                                             [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 30], NSHTTPCookieExpires,
                                             nil];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    [[self class] setCookie:cookie forURL:url];
}

- (NSArray *)requestCookies {
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[url absoluteURL]];
}

- (void)setCookie:(NSHTTPCookie *)cookie {
    [[self class] setCookie:cookie forURL:url];
}

- (void)setCookieWithName:(NSString *)name value:(NSString *)value {
    [[self class] setCookieWithName:name value:value url:url];
}

#pragma mark Headers

- (void)addRequestHeaderWithKey:(NSString *)key value:(NSString *)value {
    if(key == nil || value == nil) {
        //NSLog(@"-- cannot add request header, empty key or value: %@ / %@", key, value);
        return;
    }
    
    [customRequestHeaders setValue:value forKey:key];
}

- (NSURL *)urlWithCredentials {
    
    NSURLCredential *credentialForHost = [self credential];
    
    if(credentialForHost == nil) return url; // no credentials to add
    
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    
    BOOL hostAlreadyContainsCredentials = [host rangeOfString:@"@"].location != NSNotFound;
    if(hostAlreadyContainsCredentials) return url;
    
    NSMutableString *resourceSpecifier = [[[url resourceSpecifier] mutableCopy] autorelease];
    
    if([resourceSpecifier hasPrefix:@"//"] == NO) return nil;
    
    NSString *userPassword = [NSString stringWithFormat:@"%@:%@@", credentialForHost.user, credentialForHost.password];
    
    [resourceSpecifier insertString:userPassword atIndex:2];
    
    NSString *urlString = [NSString stringWithFormat:@"%@:%@", scheme, resourceSpecifier];
    
    return [NSURL URLWithString:urlString];
}

- (NSURLRequest *)requestByAddingCredentialsToURL:(BOOL)credentialsInRequest {
    
    NSURL *theURL = credentialsInRequest ? [self urlWithCredentials] : url;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
    
    if([POSTDictionary count] > 0) {
        
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:[POSTDictionary count]];
        
        for(NSString *k in POSTDictionary) {
            NSString *kv = [NSString stringWithFormat:@"%@=%@", k, [POSTDictionary objectForKey:k]];
            [ma addObject:kv];
        }
                
        NSString *s = [ma componentsJoinedByString:@"&"];
        NSData *data = [s dataUsingEncoding:postDataEncoding allowLossyConversion:YES];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:data];
    }
    
    if([customRequestHeaders count] > 0) {
        for(NSString *k in customRequestHeaders) {
            NSString *v = [customRequestHeaders valueForKey:k];
            [request addValue:v forHTTPHeaderField:k];
        }
    }
    
    return request;
}

- (NSURLRequest *)request {
    return [self requestByAddingCredentialsToURL:NO];
}

- (NSURLRequest *)requestByAddingCredentialsToURL {
    return [self requestByAddingCredentialsToURL:YES];
}

- (NSDictionary *)customRequestHeaders {
    return customRequestHeaders;
}

#pragma mark Response

- (NSStringEncoding)responseStringEncoding {
    if(textEncodingName == nil) return NSUTF8StringEncoding; // by default
    
    return CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)textEncodingName));
}

- (NSString *)responseString {
    if(responseData == nil) return nil;
    
    NSStringEncoding responseEncoding = NSUTF8StringEncoding; // by default
    
    NSStringEncoding encoding = [self responseStringEncoding];
    
    if(encoding != kCFStringEncodingInvalidId) {
        responseEncoding = encoding;
    }
    
    return [[[NSString alloc] initWithData:responseData encoding:responseEncoding] autorelease];
}

- (void)logRequest:(NSURLRequest *)request {
    
    NSLog(@"--------------------------------------");
    
    NSLog(@"%@", [request URL]);
    
    NSArray *cookies = [self requestCookies];
    
    if([cookies count]) NSLog(@"COOKIES");
    
    for(NSHTTPCookie *cookie in cookies) {
        NSLog(@"\t %@ = %@", [cookie name], [cookie value]);
    }
    
    NSDictionary *d = [self POSTDictionary];
    
    if([d count]) NSLog(@"POST DATA");
    
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"\t %@ = %@", key, obj);
    }];

    NSLog(@"--------------------------------------");
}

#pragma mark Start Request

- (void)startAsynchronous {
    NSURLRequest *request = [self request];

#if DEBUG
    [self logRequest:request];
#endif
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

    if(connection == nil) {
        NSString *s = @"can't create connection";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
        errorBlock(error);
    }
}

- (NSString *)startSynchronousWithError:(NSError **)error {
    
    self.responseHeaders = nil;
    self.responseStatus = 0;
    
    NSURLRequest *request = [self requestByAddingCredentialsToURL];
    
    NSURLResponse *urlResponse = nil;
    
    self.responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:error];
    if(responseData == nil) return nil;
    
    if([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
        
        self.responseHeaders = [httpResponse allHeaderFields];
        self.responseStatus = [httpResponse statusCode];
        self.textEncodingName = [httpResponse textEncodingName];
    }
    
    return [self responseString];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge previousFailureCount] <= 2) {
        
        NSURLCredential *currentCredential = nil;
        
        if ([[challenge protectionSpace] isProxy] && proxyCredential != nil) {
            currentCredential = proxyCredential;
        } else {
            currentCredential = [self credential];
        }
        
        if (currentCredential) {
            [[challenge sender] useCredential:currentCredential forAuthenticationChallenge:challenge];
            return;
        }
    }
    
    [connection cancel];
    
    [[challenge sender] cancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        self.responseHeaders = [r allHeaderFields];
        self.responseStatus = [r statusCode];
        self.textEncodingName = [r textEncodingName];
    }
    
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    [responseData appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {   
    completionBlock(responseHeaders, [self responseString]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {    
    errorBlock(error);
}

@end

/**/

@implementation NSError (STHTTPRequest)

- (BOOL)st_isAuthenticationError {
    if([[self domain] isEqualToString:NSURLErrorDomain] == NO) return NO;

    return ([self code] == kCFURLErrorUserCancelledAuthentication || [self code] == kCFURLErrorUserAuthenticationRequired);
}

@end

/**/

#if DEBUG
@implementation NSURLRequest (IgnoreSSLValidation)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return NO;
}
@end
#endif
