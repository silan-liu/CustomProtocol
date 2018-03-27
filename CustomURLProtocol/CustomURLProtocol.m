//
//  CustomURLProtocol.m
//  Join
//
//  Created by silan on 2016/11/3.
//  Copyright © 2016年 Join. All rights reserved.
//

#import "CustomURLProtocol.h"

static NSString *const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface CustomURLProtocol()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic,strong) NSURLConnection *connection;

@end

@implementation CustomURLProtocol

#pragma mark 初始化请求

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

#pragma mark 通信协议内容实现

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    if ([[self.request.URL absoluteString] hasSuffix:@"ttf"]) {
        NSString *fontName = [[self.request.URL.absoluteString lastPathComponent] stringByDeletingPathExtension];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:fontName ofType:@"ttf"];
        NSData *fontData = [NSData dataWithContentsOfFile:path];
        
        NSURLResponse *response = [[NSURLResponse alloc] init];
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:fontData];
        [[self client] URLProtocolDidFinishLoading:self];
        
    }else{
        self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
    }
}

- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark 请求管理 connection

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [[self client] URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end

