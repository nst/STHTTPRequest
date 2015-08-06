//
//  ViewController.m
//  STHTTPRequestDemo
//
//  Created by Nicolas Seriot on 8/10/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "ViewController.h"
#import "STHTTPRequest.h"

@implementation ViewController

- (IBAction)buttonClicked:(id)sender {
    
    [_activityIndicator startAnimating];
    
    _fetchButton.enabled = NO;
    _statusLabel.text = @"";
    _headersTextView.text = @"";
    _imageView.image = nil;
    
    __block STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://raw.github.com/github/media/master/octocats/octocat.png"];

//    r.GETDictionary = @{@"a":@"1", @"b":@"x/x?!=&x"};
    
    __weak STHTTPRequest *wr = r; // so that we can access the request from within the callback blocks but without creating a retain cycle
    
    r.completionDataBlock = ^(NSDictionary *headers, NSData *data) {
        
        __strong STHTTPRequest *sr = wr;
        if(sr == nil) return;
        
        self.imageView.image = [UIImage imageWithData:data];
        self.statusLabel.text = [NSString stringWithFormat:@"HTTP status %@", @(sr.responseStatus)];
        self.headersTextView.text = [headers description];
        
        self.fetchButton.enabled = YES;
        [self.activityIndicator stopAnimating];
    };
    
    r.errorBlock = ^(NSError *error) {
        self.statusLabel.text = [error localizedDescription];
        
        NSLog(@"-- isCancellationError: %d", [error st_isCancellationError]);
        
        self.fetchButton.enabled = YES;
        [self.activityIndicator stopAnimating];
    };
    
    [r startAsynchronous];
    //    [r cancel];
}

@end
