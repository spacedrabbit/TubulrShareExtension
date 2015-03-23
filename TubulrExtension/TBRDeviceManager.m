//
//  TBRDeviceManager.m
//  TubulrExtension
//
//  Created by Louis Tur on 3/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TBRDeviceManager.h"
#import <UIKit/UIKit.h>

@implementation TBRDeviceManager

+(BOOL)isiPadInterface{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? YES : NO;
}
+(BOOL)isiPhoneInterface{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? YES : NO;
}
@end
