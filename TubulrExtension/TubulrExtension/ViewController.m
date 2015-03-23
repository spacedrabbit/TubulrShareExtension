//
//  ViewController.m
//  TubulrExtension
//
//  Created by Louis Tur on 1/21/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "ViewController.h"
#import "TBRExtensionViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSUserDefaults * tubulrUserDefaults;

@end

@implementation ViewController



-(void) changeToNSUserDefaults:(NSNotification *)notification
{
    NSLog(@"Defaults have changed");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // -- NSNOTIFICATION CENTER SET UP -- //
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeToNSUserDefaults:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    // -- NSUSERDEFAULTS SETUP -- //
    // Checking / creating the user defaults for the app
    //NSLog this dict to check current domains
    
    self.tubulrUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTubulrDomain];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
