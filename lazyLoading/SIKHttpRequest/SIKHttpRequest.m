//
//  SIKHttpRequest.m
//  UrlRequest
//
//  Created by Salman Iftikhar on 10/13/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SIKHttpRequest.h"
#import "SIKHttpResponse.h"

@implementation SIKHttpRequest

@synthesize _delegate;
@synthesize _urlRequest;
@synthesize _onSuccess, _onFailurer;

- (id)requestWithString:(NSString *)url withDelegate:(id)delegate{
    
    if (!delegate) {
        return nil;
    }
    
    [self set_delegate:delegate];
    
    _urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    return self;
}

- (void)setDidFinishSelector:(SEL)onFinish{
    [self set_onSuccess:onFinish];
}

- (void)setDidFailSelector:(SEL)onWentWrong{
    [self set_onFailurer:onWentWrong];
}

- (void)cancelRequest{
    [_URLConnection cancel];
    
    [self releaseInstances];
}

- (SIKHttpResponse *)compileData:(NSData *)_data withUrlResponse:(id)_response{
    SIKHttpResponse *obj = [[SIKHttpResponse alloc]initWith:_data withUrlResponse:_response];
    return obj;
}

- (void)releaseInstances{
    _delegate = nil;
    _urlRequest = nil;
    _onSuccess = nil;
    _onFailurer = nil;
    _ServerResponse = nil;
    _Data = nil;
}

- (void)sendSynchronous{
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:_urlRequest returningResponse:&response error:&error];
    
    if (responseData) {
        SIKHttpResponse *resultObj = [self compileData:responseData withUrlResponse:response];
        [_delegate performSelectorOnMainThread:_onSuccess withObject:resultObj waitUntilDone:YES];
    }
    else {
        [_delegate performSelectorOnMainThread:_onFailurer withObject:error waitUntilDone:YES];
    }
    
    error = nil;
    response = nil;
    responseData = nil;
    
    [self releaseInstances];
    
}

- (void) sendAsynchronous {
    if (_IsFetching){
        return;
    }
    
    @synchronized(self){
        @try{
            _IsFetching = YES;
            
			[[NSURLCache sharedURLCache] setMemoryCapacity:0];
			[[NSURLCache sharedURLCache] setDiskCapacity:0];
            
			_URLConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
		}
		@catch (NSException *exc){
			return;
		}
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(!_delegate) return;
	_ServerResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(!_delegate) return;
	
	if(!_Data){
		_Data = [data mutableCopy];
	}
	else {
		[(NSMutableData *)_Data appendData: data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if(!_delegate) return;
	
    _IsFetching = NO;
    
    [_delegate performSelectorOnMainThread:_onFailurer withObject:error waitUntilDone:YES];
    
    [self releaseInstances];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
    if(!_delegate) return;
    _IsFetching = NO;
    
    SIKHttpResponse *resultObj = [self compileData:_Data withUrlResponse:_ServerResponse];
    [_delegate performSelectorOnMainThread:_onSuccess withObject:resultObj waitUntilDone:YES];
    
    [self releaseInstances];
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	return request;
}


@end
