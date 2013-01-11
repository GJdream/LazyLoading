//
//  SIKHttpRequest.h
//  UrlRequest
//
//  Created by Salman Iftikhar on 10/13/12.
//  Copyright (c) 2012 Pi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIKHttpResponse.h"

@interface SIKHttpRequest:NSObject {
    NSURLConnection *_URLConnection;
    NSURLResponse *_ServerResponse;
    NSData *_Data;
    BOOL _IsFetching;
}

@property NSMutableURLRequest *_urlRequest;
@property SEL _onSuccess;
@property SEL _onFailurer;
@property id _delegate;

- (id)requestWithString:(NSString *)url withDelegate:(id)delegate;
- (void)setDidFinishSelector:(SEL)onFinish;
- (void)setDidFailSelector:(SEL)onWentWrong;
- (void)sendSynchronous;
- (void)sendAsynchronous;
- (void)releaseInstances;
- (void)cancelRequest;

- (SIKHttpResponse *)compileData:(NSData *)_data withUrlResponse:(id)_response;

@end
