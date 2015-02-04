//
//  VimeoVideo.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "VimeoVideo.h"
@interface VimeoVideo ()



@end

@implementation VimeoVideo

-(instancetype)initWithResponse:(NSDictionary *)json{
    
    self = [super init];
    if (self) {
        _fullURI = json[@"link"];
        _videoName = json[@"name"];
        _imgURL_100x75 = json[@"pictures"][@"sizes"][0][@"link"]; //there's other options
        _videoOwner = json[@"user"][@"name"];
    }
    return self;
}

@end
