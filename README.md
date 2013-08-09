### STHTTPRequest

_A NSURLConnection wrapper for humans_

##### Simple...

-   700 lines of Objective-C you can understand
-   runs on iOS 5+ and Mac OS X 10.7+
-   just drag-and-drop .h and .m in your project
-   new BSD license

##### ... yet powerful

-   synchronous and asynchronous (block based) calls
-   easy to set request headers, cookies and POST data
-   easy to get response status, headers and encoding
-   file upload with progress block
-   fast and simple HTTP authentication

##### Typical usage

    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://google.com"];
        
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        // ...
    };
    
    r.errorBlock = ^(NSError *error) {
        // ...
    };
    
    [r startAsynchronous];

##### Starting a synchronous request

    NSError *error = nil;
    NSString *body = [r startSynchronousWithError:&error];

##### Getting HTTP data and metadata

    NSInteger     status   = r.responseStatus;
    NSDictionary *headers  = r.responseHeaders;
    NSString     *encoding = r.responseStringEncodingName;
    NSData       *data     = r.responseData;

##### Adding a request header

    [r addHeaderWithName:@"test" value:@"1234"];

##### Adding a request cookie

    [r addCookieWithName:@"test" value:@"1234"];

##### Setting a POST dictionary
    
    r.POSTDictionary = [NSDictionary dictionaryWithObject:@"1234" forKey:@"test"];

##### Setting credentials

    [r setUsername:@"test" password:@"1234"];

##### Uploading a file

    [r setFileToUpload:@"/tmp/photo.jpg" parameterName:@"photo"];
    
##### Setting a download progress block

    r.downloadProgressBlock = ^(NSInteger bytesReceived,
                                NSInteger totalBytesReceived,
                                NSInteger totalBytesExpectedToReceive) {
        // notify user of download progress
    }

##### Using STHTTPRequest in Unit Tests

You can fill a queue with fake responses to be consumed by requests started from unit tests.

    - (void)testExample {
    
        // 1. prepare a fake response, enqueue it in the response queue
        
        STHTTPRequestTestResponseQueue *queue = [STHTTPRequestTestResponseQueue sharedInstance];
    
        STHTTPRequestTestResponse *tr = [STHTTPRequestTestResponse testResponseWithBlock:^(STHTTPRequest *r) {
            r.responseStatus = 200; // by default
            r.responseHeaders = @{ @"key" : @"value" };
            r.responseString = @"OK";
        }];
        
        [queue enqueue:tr];
        
        // 2. use STHTTPRequest as usual
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://www.google.com"];
        
        r.completionBlock = ^(NSDictionary *headers, NSString *responseString) {
            // use response
        };
    
        r.errorBlock = ^(NSError *error) {
            // use error
        };
    
        [r startAsynchronous]; // will actually get executed sychronously in tests
    
        // 3. test the request response
        
        STAssertTrue(r.error == nil, [NSString stringWithFormat:@"error should be nil: %@", r.error]);
        STAssertEquals(r.responseStatus, 200, [NSString stringWithFormat:@"bad response status: %d", r.responseStatus]);
        STAssertEqualObjects(r.responseHeaders, @{ @"key" : @"value" }, [NSString stringWithFormat:@"bad headers: %@", [r responseHeaders]]);
        STAssertEqualObjects(r.responseString, @"OK", [NSString stringWithFormat:@"bad response: %@", r.responseString]);
    }
