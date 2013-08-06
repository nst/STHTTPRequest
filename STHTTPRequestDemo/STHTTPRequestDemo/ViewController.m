//
//  ViewController.m
//  STHTTPRequestDemo
//
//  Created by Nicolas Seriot on 8/10/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

/*
 TEST Basic Authentication:
 http://ericasadun.com/Private
 PrivateAccess / tuR7!mZ#eh
 
 TEST Digest Authentication:
 http://jigsaw.w3.org/HTTP/Digest/
 guest / guest
 */

#import "ViewController.h"
#import "STHTTPRequest.h"

@implementation ViewController

- (IBAction)buttonClicked:(id)sender {
    
#if 1
    [_activityIndicator startAnimating];
    
    _fetchButton.enabled = NO;
    _statusLabel.text = @"";
    _headersTextView.text = @"";
    _imageView.image = nil;
    
    // declared as __block to avoid retain cycle since we are accessing the request in a block
    __block STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://raw.github.com/github/media/master/octocats/octocat.png"];
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        
        _imageView.image = [UIImage imageWithData:r.responseData];
        _statusLabel.text = [NSString stringWithFormat:@"HTTP status %d", r.responseStatus];
        _headersTextView.text = [headers description];
        
        _fetchButton.enabled = YES;
        [_activityIndicator stopAnimating];
    };
    
    r.errorBlock = ^(NSError *error) {
        _statusLabel.text = [error localizedDescription];
        
        NSLog(@"-- isCancellationError: %d", [error st_isCancellationError]);
        
        _fetchButton.enabled = YES;
        [_activityIndicator stopAnimating];
    };
    
    [r startAsynchronous];
    //    [r cancel];
#endif
    
#if 0
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://jigsaw.w3.org/HTTP/Digest/"];
    [r setUsername:@"guest" password:@"guest_"];
    
    r.addCredentialsToURL = NO;
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        NSLog(@"-- success: %@", body);
        
    };
    
    r.errorBlock = ^(NSError *error) {
        NSLog(@"-- error: %@", error);
        
        STHTTPRequest *r2 = [STHTTPRequest requestWithURLString:@"http://jigsaw.w3.org/HTTP/Digest/"];
        
        [r2 setUsername:@"guest" password:@"guest"];
        
        r2.addCredentialsToURL = NO;
        
        r2.completionBlock = ^(NSDictionary *headers, NSString *body) {
            NSLog(@"-- success: %@", body);
        };
        
        r2.errorBlock = ^(NSError *error) {
            NSLog(@"-- error: %@", error);
        };
        
        [r2 startAsynchronous];
    };
    
    [r startAsynchronous];
#endif
    
#if 0
    NSString *email = @"sburlot@coriolis.ch";
    NSString *password = @"123456";

    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://mywebsite.com"];
    [r setHeaderWithName:@"Content-Type" value:@"application/json"];
    [r setHeaderWithName:@"Accept" value:@"application/json"];
    NSString *jsonString = [NSString stringWithFormat:@"{\"user\":{\"email\":\"%@\", \"password\":\"%@\"}}", email, password];
    [r setPOSTData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    [r startSynchronousWithError:&error];
    
    if (error) {
        _statusLabel.text = [error localizedDescription];
        [_activityIndicator stopAnimating];
    } else {
        NSLog(@"response: %@", [r responseString]);
        _statusLabel.text = [NSString stringWithFormat:@"HTTP status %d", r.responseStatus];
        _headersTextView.text = [r.responseHeaders description];
        _fetchButton.enabled = YES;
        [_activityIndicator stopAnimating];
    }
#endif
    
#if 0
    __block STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://cgi-lib.berkeley.edu/ex/fup.cgi"];

    [r addFileToUpload:@"/Users/nst/Desktop/asd.txt" parameterName:@"upfile"];
    //    [r addFileToUpload:@"/Users/nst/Desktop/photo2.png" parameterName:@"myPix2"];
    //
//    NSData *data = [[NSData alloc] initWithContentsOfFile:@"/Users/nst/Desktop/photo.png"];
//    [r addDataToUpload:data parameterName:@"upfile" mimeType:@"multipart/form-data" fileName:@"photo.png"];
//
    r.POSTDictionary = @{@"note":@"myNote"};

    r.forcedResponseEncoding = NSASCIIStringEncoding;

    r.uploadProgressBlock = ^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        NSLog(@"-- uploadProgressBlock: received %d bytes, total %d bytes, %d bytes expected", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    };

    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        NSLog(@"-- body: %@", body);
        [_activityIndicator stopAnimating];
    };

    r.errorBlock = ^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
        [_activityIndicator stopAnimating];
    };

    [r startAsynchronous];
#endif
    
}

- (void)dealloc {
    [_imageView release];
    [_statusLabel release];
    [_headersTextView release];
    [_activityIndicator release];
    [_fetchButton release];
    [super dealloc];
}

@end
