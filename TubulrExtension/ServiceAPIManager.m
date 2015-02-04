//
//  ServiceAPIManager.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "ServiceAPIManager.h"

// -- Unauthenticated Vimeo Requests -- //
static NSString * const kVimeoToken = @"e8cd186f05e710c0af6c9a610b4b12b4";



@implementation ServiceAPIManager

+(instancetype) sharedVimeoManager{

    static ServiceAPIManager * _sharedVimeoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedVimeoManager = [[ServiceAPIManager alloc] init];
    });
    
    return _sharedVimeoManager;
    
 }



@end
