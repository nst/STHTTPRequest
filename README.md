### STHTTPRequest

_A NSURLConnection wrapper for humans_

##### Simple...

-   400 lines of Objective-C you can understand
-   runs on iOS 4+ and Mac OS X 10.6+
-   just drag-and-drop .h and .m in your project
-   new BSD license

##### ... yet powerful

-   synchronous and asynchronous (block based) calls
-   easy to set request headers, cookies and POST data
-   easy to get response status, headers and encoding
-   supports HTTP and proxy authentication

##### Typical usage

    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://google.com"];
        
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        NSLog(@"-- %@", headers);
        NSLog(@"-- %@", body);
    };
    
    r.errorBlock = ^(NSError *error) {
       NSLog(@"-- %@", error);
    };
    
    [r startAsynchronous];

##### Starting a synchronous request

    NSError *error = nil;
    NSString *body = [r startSynchronousWithError:&error];

##### Getting HTTP data and metadata

    NSInteger     status   = r.responseStatus;
    NSDictionary *headers  = r.responseHeaders;
    NSString     *encoding = r.textEncodingName;
    NSData       *data     = r.responseData;

##### Addding a request header

    [r addRequestHeaderWithKey:@"test" value:@"1234"];

##### Adding a request cookie

    [r setCookieWithName:@"test" value:@"1234"];

##### Setting a POST dictionary
    
    r.POSTDictionary = [NSDictionary dictionaryWithObject:@"o1" forKey:@"k1"];

##### Setting credentials

    r.credential = \
        [NSURLCredential credentialWithUser:@"username"
                                   password:@"password"
                                persistence:NSURLCredentialPersistenceForSession];

##### Setting proxy credentials

    r.proxyCredential = \
        [NSURLCredential credentialWithUser:@"username"
                                   password:@"password"
                                persistence:NSURLCredentialPersistenceForSession];
