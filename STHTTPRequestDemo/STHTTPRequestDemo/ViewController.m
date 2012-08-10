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
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://assets.github.com/images/modules/about_page/octocat.png"];
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        
        _imageView.image = [UIImage imageWithData:r.responseData];
        _statusLabel.text = [NSString stringWithFormat:@"HTTP status %d", r.responseStatus];
        _headersTextView.text = [headers description];
        
        _fetchButton.enabled = YES;
        [_activityIndicator stopAnimating];
    };
    
    r.errorBlock = ^(NSError *error) {
        _statusLabel.text = [error localizedDescription];
        
        _fetchButton.enabled = YES;
        [_activityIndicator stopAnimating];
    };
    
    [r startAsynchronous];
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
