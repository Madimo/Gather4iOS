//
//  PostViewController.m
//  Gather
//
//  Created by Madimo on 14-6-20.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "PostViewController.h"
#import "GatherAPI.h"
#import "NodeChosenViewController.h"
#import "PostManager.h"
#import "Node.h"

@interface PostViewController () <NodeChosenViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;
@property (strong, nonatomic) NSArray *nodes;
@property (nonatomic) NSInteger nodeItem;
@property (nonatomic) BOOL isLoadingNodes;
@end

@implementation PostViewController

#pragma mark - View lift cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    self.titleTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.contentTextView.keyboardAppearance = UIKeyboardAppearanceDark;

    [self loadNodes];
    
    if (self.postType == PostTypeTopic) {
        self.nodeItem = -1;
    } else if (self.postType == PostTypeReply) {
        self.titleTextField.text = [NSString stringWithFormat:@"Re: %@", self.topic.title];
        self.titleTextField.enabled = NO;
        self.titleTextField.textColor = [UIColor lightGrayColor];
        [self.activityIndicator stopAnimating];
        self.nodeLabel.text = self.topic.node.name;
        self.nodeLabel.hidden = NO;
    }
    self.contentTextView.text = self.content;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.postType == PostTypeTopic) {
        [self.titleTextField becomeFirstResponder];
    } else {
        [self.contentTextView becomeFirstResponder];
    }
}

#pragma mark - Action

- (IBAction)post:(id)sender
{
    if (self.postType == PostTypeTopic) {
        [self postTopic];
    } else if (self.postType == PostTypeReply) {
        [self postReply];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(postViewController:postCanceledWithPostType:title:node:content:)]) {
        [self.delegate postViewController:self
                 postCanceledWithPostType:self.postType
                                    title:self.titleTextField.text
                                     node:self.nodes[self.nodeItem]
                                  content:self.contentTextView.text];
    }
}

#pragma mark - Post

- (void)postTopic
{
    if ([self.titleTextField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops .."
                                                            message:@"It must have a title."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (self.nodeItem < 0 || self.nodeItem >= self.nodes.count) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops .."
                                                            message:@"You have to choose a node."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(postViewController:willPostWithPostType:title:node:content:)]) {
        [self.delegate postViewController:self
                     willPostWithPostType:self.postType
                                    title:self.titleTextField.text
                                     node:self.nodes[self.nodeItem]
                                  content:self.contentTextView.text];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *content = self.contentTextView.text;
    content = [NSString stringWithFormat:@"%@\n\n%@", content, [ud stringForKey:UD_KEY_SIGNATURE]];
    
    [[PostManager manager] postTopicWithTitle:self.titleTextField.text
                                       nodeId:((Node *)self.nodes[self.nodeItem]).nodeId
                                      content:content
                                       images:nil
                                      success:^(Topic *topic) {
                                          
                                      }
                                      failure:^(NSException *exception) {
                                          
                                      }];
}

- (void)postReply
{
    if ([self.titleTextField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops .."
                                                            message:@"It must have content."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(postViewController:willPostWithPostType:title:node:content:)]) {
        [self.delegate postViewController:self
                     willPostWithPostType:self.postType
                                    title:self.titleTextField.text
                                     node:self.nodes[self.nodeItem]
                                  content:self.contentTextView.text];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *content = self.contentTextView.text;
    content = [NSString stringWithFormat:@"%@\n\n%@", content, [ud stringForKey:UD_KEY_SIGNATURE]];
    
    [[PostManager manager] postReplyWithTopicId:self.topic.topicId
                                        content:self.contentTextView.text
                                         images:nil
                                        success:^(Reply *reply) {
                                            
                                        }
                                        failure:^(NSException *exception) {
                                            
                                        }];
}

#pragma mark - Load nodes

- (void)loadNodes
{
    if (self.isLoadingNodes) {
        return;
    }

    self.isLoadingNodes = YES;
    self.nodeLabel.hidden = YES;
    self.errorIcon.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    GatherAPI *api = [GatherAPI sharedAPI];
    [api getAllNodesWithSuccess:^(NSArray *nodes) {
        self.nodes = nodes;
        [self.activityIndicator stopAnimating];
        self.nodeLabel.hidden = NO;
        self.postButton.enabled = YES;
        self.isLoadingNodes = NO;
    } failure:^(NSException *exception) {
        [self.activityIndicator stopAnimating];
        self.errorIcon.hidden = NO;
        self.isLoadingNodes = NO;
    }];
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.postType == PostTypeReply || indexPath.row != 1) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nodes) {
        [self performSegueWithIdentifier:@"ChooseNode" sender:self];
    } else {
        [self loadNodes];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - NodeChosenViewController delegate

- (void)nodeChosenViewController:(NodeChosenViewController *)controller didSelectItemAtIndex:(NSInteger)index
{
    self.nodeItem = index;
    self.nodeLabel.text = [self.nodes[index] name];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseNode"]) {
        if ([segue.destinationViewController isKindOfClass:[NodeChosenViewController class]]) {
            NodeChosenViewController *ncvc = segue.destinationViewController;
            ncvc.nodes = self.nodes;
            ncvc.delegate = self;
            ncvc.selectedItem = self.nodeItem;
        }
    }
}

@end
