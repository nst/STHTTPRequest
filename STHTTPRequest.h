/*
 Copyright (c) 2012, Nicolas Seriot
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the Nicolas Seriot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

@class STHTTPRequest;

typedef void (^completionBlock_t)(NSDictionary *headers, NSString *body);
typedef void (^errorBlock_t)(NSError *error);

@interface STHTTPRequest : NSObject {
    NSURL *url;
    NSDictionary *POSTDictionary;
    NSMutableData *responseData;
    NSDictionary *customRequestHeaders;
    NSDictionary *_responseHeaders;
    completionBlock_t completionBlock;
    errorBlock_t errorBlock;
    NSURLCredential *credential;
    NSURLCredential *proxyCredential;
    NSInteger responseStatus;
    NSString *textEncodingName;
    NSStringEncoding postDataEncoding;
}

@property (copy) completionBlock_t completionBlock;
@property (copy) errorBlock_t errorBlock;
@property (nonatomic) NSInteger responseStatus;
@property (nonatomic) NSStringEncoding postDataEncoding;
@property (nonatomic, retain) NSURLCredential *credential;
@property (nonatomic, retain) NSURLCredential *proxyCredential;
@property (nonatomic, retain) NSDictionary *POSTDictionary;
@property (nonatomic, retain) NSString *textEncodingName;
@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSURL *url;

+ (STHTTPRequest *)requestWithURL:(NSURL *)url;
+ (STHTTPRequest *)requestWithURLString:(NSString *)urlString;

- (NSString *)startSynchronousWithError:(NSError **)error;
- (void)startAsynchronous;

- (NSStringEncoding)responseStringEncoding;

// Cookies
+ (void)setCookieWithName:(NSString *)name value:(NSString *)value url:(NSURL *)url;
- (void)setCookieWithName:(NSString *)name value:(NSString *)value;
+ (NSArray *)sessionCookies;
+ (void)deleteSessionCookies;
- (NSArray *)requestCookies;

// Credentials
+ (NSURLCredential *)sessionAuthenticationCredentialsForURL:(NSURL *)requestURL;
+ (void)deleteAllCredentials;
- (void)setUsername:(NSString *)username password:(NSString *)password;
- (NSString *)username;
- (NSString *)password;

// Headers
- (void)addRequestHeaderWithKey:(NSString *)name value:(NSString *)value;
- (NSDictionary *)responseHeaders;

// Clear Session
+ (void)clearSession;

@end

@interface NSError (SQHTTPRequest)
- (BOOL)st_isAuthenticationError;
@end
