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

// TODO: Get images and name them based on their sized as listed by their keys
-(instancetype)initWithResponse:(NSDictionary *)json{
    
    self = [super init];
    if (self) {
        _fullURI = json[@"link"];
        _videoTitle = json[@"name"];
        _imgURL_100x75 = json[@"pictures"][@"sizes"][0][@"link"]; //there's other options
        _videoOwner = json[@"user"][@"name"];
        _imgURL_200x150 = json[@"pictures"][@"sizes"][1][@"link"]; // i'd prefer to actually check the value of the key
        _imgURL_295x166 = json[@"pictures"][@"sizes"][2][@"link"]; // rather than the position in the array...
        _imgURL_640x359 = json[@"pictures"][@"sizes"][3][@"link"];
    }
    return self;
}

@end
