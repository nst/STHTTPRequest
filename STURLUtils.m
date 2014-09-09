/*
 Copyright (c) 2012, Nicolas Seriot
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the Nicolas Seriot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */



#import "STURLUtils.h"


@implementation STURLUtils

+ (NSURL *)URL:(NSURL *)url appendedWithQueryParameters:(NSDictionary *)parameters
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:[url absoluteString]];

    for (id key in parameters) {
        NSString *keyString = [key description];
        NSString *valueString = [[parameters objectForKey:key] description];

        if ([urlString rangeOfString:@"?"].location == NSNotFound) {
            [urlString appendFormat:@"?%@=%@", [self URLEscapeString:keyString], [self URLEscapeString:valueString]];
        }
        else {
            [urlString appendFormat:@"&%@=%@", [self URLEscapeString:keyString], [self URLEscapeString:valueString]];
        }
    }
    return [NSURL URLWithString:urlString];
}

+ (NSString *)URLEscapeString:(NSString *)rawString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef) rawString;
    NSString *encoded =
        (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, originalStringRef, NULL, NULL, kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return encoded;
}

@end