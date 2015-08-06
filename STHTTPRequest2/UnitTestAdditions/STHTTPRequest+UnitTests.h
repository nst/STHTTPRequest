//
//  STHTTPRequest+UnitTests.h
//
//  Created by Nicolas Seriot on 8/8/12.
//
//

#import "STHTTPRequest.h"

@interface STHTTPRequest (UnitTests)

// expose private properties
@property (nonatomic) NSUInteger responseStatus;
@property (nonatomic, retain) NSString *responseString;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSError *error;

- (void)unitTests_addDownloadProgressData:(NSData *)data;
- (void)unitTests_addDownloadProgressUTF8String:(NSString *)s;

@end
