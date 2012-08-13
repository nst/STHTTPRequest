//
//  STHTTPRequest.m
//  STHTTPRequest
//
//  Created by Nicolas Seriot on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "STHTTPRequest.h"

static NSMutableDictionary *sharedCredentialsStorage;

@interface STHTTPRequest ()
@property (nonatomic) NSInteger responseStatus;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *responseStringEncodingName;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSError *error;
@end

@interface NSData (Base64)
- (NSString *)base64Encoding; // private API
@end

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
@synthesize responseStringEncodingName;
@synthesize postDataEncoding;
@synthesize requestHeaders;
@synthesize responseString;
@synthesize error;

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
        requestHeaders = [[NSMutableDictionary dictionary] retain];
        postDataEncoding = NSUTF8StringEncoding;
    }
    
    return self;
}

+ (void)clearSession {
    [self deleteAllCookies];
    [self deleteAllCredentials];
}

- (void)dealloc {
    [responseStringEncodingName release];
    [requestHeaders release];
    [url release];
    [responseData release];
    [responseHeaders release];
    [responseString release];
    [completionBlock release];
    [errorBlock release];
    [credential release];
    [proxyCredential release];
    [POSTDictionary release];
    [error release];
    [super dealloc];
}

#pragma mark Credentials

+ (NSMutableDictionary *)sharedCredentialsStorage {
    if(sharedCredentialsStorage == nil) {
        sharedCredentialsStorage = [[NSMutableDictionary dictionary] retain];
    }
    return sharedCredentialsStorage;
}

+ (NSURLCredential *)sessionAuthenticationCredentialsForURL:(NSURL *)requestURL {
    return [[[self class] sharedCredentialsStorage] valueForKey:[requestURL host]];
}

+ (void)deleteAllCredentials {
    [sharedCredentialsStorage autorelease];
    sharedCredentialsStorage = [[NSMutableDictionary dictionary] retain];
}

- (void)setCredential:(NSURLCredential *)c {
#if DEBUG
    NSAssert(url, @"missing url to set credential");
#endif
    [[[self class] sharedCredentialsStorage] setObject:c forKey:[url host]];
}

- (NSURLCredential *)credential {
    return [[[self class] sharedCredentialsStorage] valueForKey:[url host]];
}

- (void)setUsername:(NSString *)username password:(NSString *)password {
    NSURLCredential *c = [NSURLCredential credentialWithUser:username
                                                    password:password
                                                 persistence:NSURLCredentialPersistenceNone];
    
    [self setCredential:c];
}

- (void)setProxyUsername:(NSString *)username password:(NSString *)password {
    NSURLCredential *c = [NSURLCredential credentialWithUser:username
                                                    password:password
                                                 persistence:NSURLCredentialPersistenceNone];
    
    [self setProxyCredential:c];
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

+ (void)addCookie:(NSHTTPCookie *)cookie forURL:(NSURL *)url {
    NSArray *cookies = [NSArray arrayWithObject:cookie];
	
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];
}

+ (void)addCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url {
    
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
    
    [[self class] addCookie:cookie forURL:url];
}

- (NSArray *)requestCookies {
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[url absoluteURL]];
}

- (void)addCookie:(NSHTTPCookie *)cookie {
    [[self class] addCookie:cookie forURL:url];
}

- (void)addCookieWithName:(NSString *)name value:(NSString *)value {
    [[self class] addCookieWithName:name value:value url:url];
}

#pragma mark Headers

- (void)setHeaderWithName:(NSString *)name value:(NSString *)value {
    if(name == nil || value == nil) return;
    [[self requestHeaders] setObject:value forKey:name];
}

- (void)removeHeaderWithName:(NSString *)name {
    if(name == nil) return;
    [[self requestHeaders] removeObjectForKey:name];
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

- (NSURLRequest *)requestByAddingCredentialsToURL:(BOOL)credentialsInRequest sendBasicAuthenticationHeaders:(BOOL)sendBasicAuthenticationHeaders {
    
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
    
    [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
        
    NSURLCredential *credentialForHost = [self credential];
            
    if(sendBasicAuthenticationHeaders && credentialsInRequest && credentialForHost) {
        NSString *authString = [NSString stringWithFormat:@"%@:%@", credentialForHost.user, credentialForHost.password];
        NSData *authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
        [request addValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

- (NSURLRequest *)request {
    return [self requestByAddingCredentialsToURL:NO sendBasicAuthenticationHeaders:YES];
}

- (NSURLRequest *)requestByAddingCredentialsToURL {
    return [self requestByAddingCredentialsToURL:YES sendBasicAuthenticationHeaders:YES];
}

#pragma mark Response

+ (NSString *)stringWithData:(NSData *)data encodingName:(NSString *)encodingName {
    if(data == nil) return nil;
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    if(encodingName != nil) {
        
        encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName));
        
        if(encoding == kCFStringEncodingInvalidId) {
            encoding = NSUTF8StringEncoding; // by default
        }
    }
    
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
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
    NSURLRequest *request = [self requestByAddingCredentialsToURL];
    
#if DEBUG
    [self logRequest:request];
#endif
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(connection == nil) {
        NSString *s = @"can't create connection";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey];
        self.error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
        errorBlock(error);
    }
}

- (NSString *)startSynchronousWithError:(NSError **)e {
    
    self.responseHeaders = nil;
    self.responseStatus = 0;
    
    NSURLRequest *request = [self requestByAddingCredentialsToURL];
    
    NSURLResponse *urlResponse = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:e];
    if(data == nil) return nil;
    
    self.responseData = [NSMutableData dataWithData:data];
    
    if([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
        
        self.responseHeaders = [httpResponse allHeaderFields];
        self.responseStatus = [httpResponse statusCode];
        self.responseStringEncodingName = [httpResponse textEncodingName];
    }
    
    return [[self class] stringWithData:responseData encodingName:responseStringEncodingName];
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
        self.responseStringEncodingName = [r textEncodingName];
    }
    
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    [responseData appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.responseString = [[self class] stringWithData:responseData encodingName:responseStringEncodingName];
    
    completionBlock(responseHeaders, [self responseString]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)e {
    self.error = e;
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
