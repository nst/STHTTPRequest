//
//  STHTTPRequest+UnitTests.h
//
//  Created by Nicolas Seriot on 8/8/12.
//
//

#import "STHTTPRequest.h"

@interface STHTTPRequest (UnitTests)

- (void)startAsynchronous;
- (NSString *)startSynchronousWithError:(NSError **)error;

@property (nonatomic) NSUInteger responseStatus;

@end
