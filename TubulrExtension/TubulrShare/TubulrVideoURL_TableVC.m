//
//  TubulrVideoURL_TableVC.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/7/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubulrVideoURL_TableVC.h"

@interface TubulrVideoURLTVCOver : NSObject

@end


@interface TubulrVideoURL_TableVC ()

@end

@implementation TubulrVideoURL_TableVC

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSLog(@"Initi with coder:");
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

-(void)loadView{
    
    self.view = [[UIView alloc] init];
    
}

-(void)awakeFromNib{
    NSLog(@"AwakeFromNib");
    [_containerView setBackgroundColor:[UIColor redColor]];
    [_containerView setAlpha:.50];
    
    UITableViewCell * videoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"videoCell"];
    [videoCell.contentView.layer setCornerRadius:8.0];
    [videoCell.contentView setBackgroundColor:[UIColor yellowColor]];
    
    [_videoTableView registerClass:[videoCell class] forCellReuseIdentifier:@"videoCell"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did load");
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 8;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
