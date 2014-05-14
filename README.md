### STHTTPRequest

_A NSURLConnection wrapper for humans_

> "It took me 15 minutes to do with STHTTPRequest what I couldn’t do in 3 hours with AFNetworking." [@sburlot](https://twitter.com/sburlot/status/431816832144900096)

##### Simple...

-   700 lines of Objective-C you can understand
-   runs on iOS 5+ and Mac OS X 10.7+
-   just drag and drop .h and .m in your project
-   pod 'STHTTPRequest' in CocoaPods
-   new BSD license

##### ... yet powerful

-   synchronous and asynchronous (block based) calls
-   easy to set request headers, cookies and POST data
-   easy to get response status, headers and encoding
-   file upload with progress block
-   fast and simple HTTP authentication
-   log requests in curl format

##### Maturity

STHTTPRequest is used in applications available on the App Store and used by 100'000+ regular users.

STHTTPRequest is also used in the [STTwitter library](https://github.com/nst/STTwitter), the main Objective-C library to access Twitter API.

##### Typical usage

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
Notes:

- STHTTPRequest must be used from the main thread
- success block and error block are called on main thread

##### Starting a synchronous request

    NSError *error = nil;
    NSString *body = [r startSynchronousWithError:&error];

##### Getting HTTP data and metadata

```Objective-C
NSInteger     status   = r.responseStatus;
NSDictionary *headers  = r.responseHeaders;
NSString     *encoding = r.responseStringEncodingName;
NSData       *data     = r.responseData;
```

##### Usable in unit tests

You can fill a queue with fake responses to be consumed by requests started from unit tests.

##### Adding a request header

```Objective-C
[r setHeaderWithName:@"test" value:@"1234"];
```

##### Adding a request cookie

```Objective-C
[r addCookieWithName:@"test" value:@"1234"];
```

##### Setting credentials

```Objective-C
[r setUsername:@"test" password:@"1234"];
```

##### POSTing a dictionary

```Objective-C
r.POSTDictionary = @{ @"paperid":@"6", @"q77":"1", @"q80":@"hello" };
```

##### POSTing raw data

```Objective-C
request.rawPOSTData = myData;
```

[full example here](http://stackoverflow.com/questions/19176289/sthttprequest-how-to-postdata-not-key-value/19226132#19226132)

##### Uploading a file

```Objective-C
[r addFileToUpload:@"/tmp/photo.jpg" parameterName:@"photo"];
```

##### Uploading multiple images

```Objective-C
[request addDataToUpload:data1 parameterName:@"p1" mimeType:@"image/jpeg" fileName:@"name1"];
[request addDataToUpload:data2 parameterName:@"p2" mimeType:@"image/jpeg" fileName:@"name2"];
```

##### Setting a download progress block

```Objective-C
r.downloadProgressBlock = ^(NSData *dataJustReceived,
                            NSInteger totalBytesReceived,
                            NSInteger totalBytesExpectedToReceive) {
    // notify user of download progress
}
```

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
