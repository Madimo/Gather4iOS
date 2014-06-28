//
//  SignatureViewController.m
//  Gather
//
//  Created by Madimo on 6/28/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "SignatureViewController.h"

@interface SignatureViewController ()
@property (weak, nonatomic) IBOutlet UITextField *signatureTextField;
@end

@implementation SignatureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signatureTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:UD_KEY_SIGNATURE];
    self.signatureTextField.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.signatureTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.signatureTextField.text forKey:UD_KEY_SIGNATURE];
    [defaults synchronize];
}

- (IBAction)defaultSignature:(id)sender
{
    self.signatureTextField.text = @"Posted from Gather for iOS";
}

@end
