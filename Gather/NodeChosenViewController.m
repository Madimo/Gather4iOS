//
//  NodeChosenViewController.m
//  Gather
//
//  Created by Madimo on 14-6-22.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "NodeChosenViewController.h"
#import "Node.h"

@interface NodeChosenViewController ()

@end

@implementation NodeChosenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView reloadData];
    if (self.selectedItem >= 0 && self.selectedItem < self.nodes.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItem inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodeCell" forIndexPath:indexPath];
    
    Node *node = self.nodes[indexPath.row];
    cell.textLabel.text = node.name;
    cell.detailTextLabel.text = node.description;
    if (self.selectedItem == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItem inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeChosenViewController:didSelectItemAtIndex:)]) {
        [self.delegate nodeChosenViewController:self didSelectItemAtIndex:indexPath.row];
    }
}

@end
