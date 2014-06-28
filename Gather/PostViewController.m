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
#import "EmoticonViewController.h"
#import "Emoticon.h"
#import "EmoticonManager.h"

@interface PostViewController () <NodeChosenViewControllerDelegate, EmoticonViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;
@property (weak, nonatomic) IBOutlet UILabel *nodeDisplay;
@property (strong, nonatomic) EmoticonViewController *emoticonViewController;
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
    
    [self initToolbar];
    
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
        self.nodeDisplay.textColor = [UIColor grayColor];
    }
    self.contentTextView.text = self.content;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.postType == PostTypeReply) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.postType == PostTypeTopic) {
        if (![self.contentTextView isFirstResponder]) {
            [self.titleTextField becomeFirstResponder];
        }
    } else if (self.postType == PostTypeReply) {
        [self.contentTextView becomeFirstResponder];
    }
}

#pragma mark - Initialize

- (void)initToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    toolbar.tintColor = [UIColor whiteColor];
    toolbar.barTintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *emoticon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emoticon"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(showHideEmoticonView:)];

    
    toolbar.items = @[emoticon];
    
    self.contentTextView.inputAccessoryView = toolbar;
}

#pragma mark - Action

- (IBAction)post:(id)sender
{
    if (self.postType == PostTypeTopic) {
        [self postTopic];
    } else if (self.postType == PostTypeReply) {
        [self postReply];
    }
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
    content = [[EmoticonManager manager] translateEmoticonName:content];
    content = [NSString stringWithFormat:@"%@\n\n%@", content, [ud stringForKey:UD_KEY_SIGNATURE]];
    
    [[PostManager manager] postTopicWithTitle:self.titleTextField.text
                                       nodeId:((Node *)self.nodes[self.nodeItem]).nodeId
                                      content:content
                                       images:nil
                                      success:^(Topic *topic) {
                                          if (self.delegate && [self.delegate respondsToSelector:@selector(postViewController:didPostWithPost:)]) {
                                              [self.delegate postViewController:self didPostWithPost:topic];
                                          }                                      }
                                      failure:^(NSException *exception) {
                                          
                                      }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postReply
{
    if ([self.contentTextView.text isEqualToString:@""]) {
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
    content = [[EmoticonManager manager] translateEmoticonName:content];
    content = [NSString stringWithFormat:@"%@ \n\n %@", content, [ud stringForKey:UD_KEY_SIGNATURE]];
    
    [[PostManager manager] postReplyWithTopicId:self.topic.topicId
                                        content:content
                                         images:nil
                                        success:^(Reply *reply) {
                                            if (self.delegate && [self.delegate respondsToSelector:@selector(postViewController:didPostWithPost:)]) {
                                                [self.delegate postViewController:self didPostWithPost:reply];
                                            }
                                        }
                                        failure:^(NSException *exception) {
                                            
                                        }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Toolbar button action

- (void)showHideEmoticonView:(UIBarButtonItem *)sender
{
    if (!self.emoticonViewController) {
        self.emoticonViewController = [[EmoticonViewController alloc] init];
        self.emoticonViewController.delegate = self;
    }
    
    if (self.contentTextView.inputView) {
        self.contentTextView.inputView = nil;
        sender.image = [UIImage imageNamed:@"emoticon"];
    } else {
        self.contentTextView.inputView = self.emoticonViewController.view;
        sender.image = [UIImage imageNamed:@"keyboard"];
    }
    
    [self.contentTextView resignFirstResponder];
    [self.contentTextView becomeFirstResponder];
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

#pragma mark - EmoticonViewController delegate

- (void)emoticonViewController:(EmoticonViewController *)controller didSelectEmoticon:(Emoticon *)emoticon
{
    NSMutableString *content = [self.contentTextView.text mutableCopy];
    NSInteger start = self.contentTextView.selectedRange.location;
    NSString *name = [NSString stringWithFormat:@"<#%@>", emoticon.name];
    [content replaceCharactersInRange:self.contentTextView.selectedRange
                           withString:name];
    self.contentTextView.text = content;
    self.contentTextView.selectedRange = NSMakeRange(start + name.length, 0);
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
