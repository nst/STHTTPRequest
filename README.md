### STHTTPRequest

_A NSURLConnection wrapper for humans_

##### Simple...

-   700 lines of Objective-C you can understand
-   runs on iOS 5+ and Mac OS X 10.7+
-   drag and drop .h and .m in your project, add Security.framework
-   new BSD license

##### ... yet powerful

-   synchronous and asynchronous (block based) calls
-   easy to set request headers, cookies and POST data
-   easy to get response status, headers and encoding
-   file upload with progress block
-   fast and simple HTTP authentication

##### Usable in unit tests

You can fill a queue with fake responses to be consumed by requests started from unit tests.

##### Typical usage

    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://google.com"];
        
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        // ...
    };
    
    r.errorBlock = ^(NSError *error) {
        // ...
    };
    
    [r startAsynchronous];

Notes:

- STHTTPRequest must be used from the main thread
- success block and error block are called on main thread

##### Starting a synchronous request

    NSError *error = nil;
    NSString *body = [r startSynchronousWithError:&error];

##### Getting HTTP data and metadata

    NSInteger     status   = r.responseStatus;
    NSDictionary *headers  = r.responseHeaders;
    NSString     *encoding = r.responseStringEncodingName;
    NSData       *data     = r.responseData;

##### Adding a request header

    [r setHeaderWithName:@"test" value:@"1234"];

##### Adding a request cookie

    [r addCookieWithName:@"test" value:@"1234"];

##### Setting a POST dictionary
    
    r.POSTDictionary = [NSDictionary dictionaryWithObject:@"1234" forKey:@"test"];

##### Setting credentials

    [r setUsername:@"test" password:@"1234"];

##### Uploading a file

    [r setFileToUpload:@"/tmp/photo.jpg" parameterName:@"photo"];
    
##### Setting a download progress block

    r.downloadProgressBlock = ^(NSData *dataJustReceived,
                                NSInteger totalBytesReceived,
                                NSInteger totalBytesExpectedToReceive) {
        // notify user of download progress
    }

##### Log the requests

To log human readable debug description, add launch argument `-STHTTPRequestShowDebugDescription 1`.

    GET https://raw.github.com/github/media/master/octocats/octocat.png
    HEADERS
        Cookie = asd=sdf; xxx=yyy
    COOKIES
        asd = sdf
        xxx = yyy

To log curl description, add launch argument `-STHTTPRequestShowCurlDescription 1`.

    $ curl -i \
    -b "asd=sdf;xxx=yyy" \
    -H "Cookie: asd=sdf; xxx=yyy,asd=sdf; xxx=yyy" \
    "https://raw.github.com/github/media/master/octocats/octocat.png"

(Curl is a command-line tool shipped with OS X that can craft and send HTTP requests.)
