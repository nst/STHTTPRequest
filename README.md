### STHTTPRequest

_A NSURLSession wrapper for humans_

##### Simple...

-   1000 lines of Objective-C you can understand
-   runs on iOS 7+ and Mac OS X 10.7+
-   just drag and drop .h and .m in your project
-   pod 'STHTTPRequest' in CocoaPods
-   new BSD license

##### ... yet powerful

-   synchronous and asynchronous (block based) calls
-   easy to set request headers, cookies and POST data
-   easy to get response status, headers and encoding
-   file upload with progress block
-   can use streaming with the download progress block
-   fast and simple HTTP authentication
-   log requests in curl format

##### Typical usage

Objective-C
```Objective-C
STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://google.com"];

r.completionBlock = ^(NSDictionary *headers, NSString *body) {
    // ...
};

r.errorBlock = ^(NSError *error) {
    // ...
};

[r startAsynchronous];
```

Swift
```Swift
let r = STHTTPRequest(URLString:"http://www.google.com")

r.completionBlock = { (headers, body) in
    // ...
}

r.errorBlock = { (error) in
    // ...
}

r.startAsynchronous()
```

Notes:

- STHTTPRequest must be used from the main thread
- all blocks are guaranteed to be called on main thread

##### Start a synchronous request

```Objective-C
NSError *error = nil;
NSString *body = [r startSynchronousWithError:&error];
```

##### Get HTTP data and metadata

```Objective-C
NSInteger     status   = r.responseStatus;
NSDictionary *headers  = r.responseHeaders;
NSString     *encoding = r.responseStringEncodingName;
NSData       *data     = r.responseData;
```

##### Add a request header

```Objective-C
[r setHeaderWithName:@"test" value:@"1234"];
```

##### Add a request cookie

```Objective-C
[r addCookieWithName:@"test" value:@"1234"];
```

##### Set credentials

```Objective-C
[r setUsername:@"test" password:@"1234"];
```

##### set the GET parameters

```Objective-C
r.GETDictionary = @{ @"paperid":@"6", @"q77":"1", @"q80":@"hello" };
```

##### POST a dictionary

```Objective-C
r.POSTDictionary = @{ @"paperid":@"6", @"q77":"1", @"q80":@"hello" };
```

##### POST raw data

```Objective-C
request.rawPOSTData = myData;
```

[full example here](http://stackoverflow.com/questions/19176289/sthttprequest-how-to-postdata-not-key-value/19226132#19226132)

##### Upload a file

```Objective-C
[r addFileToUpload:@"/tmp/photo.jpg" parameterName:@"photo"];
```

[full example here](http://stackoverflow.com/questions/23605292/http-post-request-to-send-an-image/23631175#23631175)

##### Upload an image and set parameters

```Objective-C
NSData *imageData = [NSData dataWithContentsOfFile:"image.jpg"];
[request addDataToUpload:imageData parameterName:@"param" mimeType:@"image/jpeg" fileName:@"file_name"];
```

##### Upload several images

```Objective-C
[request addDataToUpload:data1 parameterName:@"p1" mimeType:@"image/jpeg" fileName:@"name1"];
[request addDataToUpload:data2 parameterName:@"p2" mimeType:@"image/jpeg" fileName:@"name2"];
```

##### Get headers only

```Objective-C
r.HTTPMethod = @"HEAD";
```

##### Set a download progress block

```Objective-C
r.downloadProgressBlock = ^(NSData *dataJustReceived,
                            NSInteger totalBytesReceived,
                            NSInteger totalBytesExpectedToReceive) {
    // notify user of download progress
    // use the stream
}
```

##### Usable in unit tests

The demo project comes with two unit tests target.

`AsynchronousTests` shows how to [perform actual network requests](https://github.com/nst/STHTTPRequest/blob/master/Demo%20Project/Unit%20Tests/STHTTPRequestAsyncTests.m) in unit tests.

`STHTTPRequestTests` show how to perform synchronous tests by [filling a queue](https://github.com/nst/STHTTPRequest/blob/master/Demo%20Project/Unit%20Tests/STHTTPRequestTests.m#L42-L74) with fake responses to be consumed by requests started from unit tests. Just include the [UnitTestAdditions](https://github.com/nst/STHTTPRequest/tree/master/Demo%20Project/Unit%20Tests) directory to your project.

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

(Curl is a command-line tool shipped with OS X that can craft HTTP requests.)

##### Support

If you have any question, [open an issue](https://github.com/nst/STHTTPRequest/issues/new) on GitHub or use the [STHTTPRequest tag](http://stackoverflow.com/questions/tagged/sthttprequest) on StackOverflow.

##### BSD 3-Clause License

See [LICENCE.txt](LICENCE.txt).
