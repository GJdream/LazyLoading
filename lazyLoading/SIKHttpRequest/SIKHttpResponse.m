//
//  SIKHttpResponse.m
//  SIKHttpRequestDemo
//
//  Created by Salman Iftikhar on 10/29/12.
//
//

#import "SIKHttpResponse.h"

@implementation SIKHttpResponse

@synthesize responseData;
@synthesize responseString;
@synthesize responseUrl;

- (SIKHttpResponse *)initWith:(NSData *)_responseData withUrlResponse:(NSHTTPURLResponse *)_responseUrl {
    
    NSString *_responseString = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    [self setResponseString:_responseString];
    [self setResponseData:_responseData];
    [self setResponseUrl:_responseUrl];
    
    _responseString = nil;
    return self;
}

@end
