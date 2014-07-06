//
//  StartViewController.m
//  Gather
//
//  Created by Madimo on 14-6-2.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "StartViewController.h"
#import "ThemeManager.h"
#import "GatherClient.h"
#import "TopicViewController.h"
#import "WebBrowserController.h"

@interface StartViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *signView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *confirmTextField;
@end

@implementation StartViewController

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTextField];
    [self initGestureRecognizer];
    [self initNotification];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initViewAlpha];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initViewPosition];
        [self appearAnimation];
    });
}

#pragma mark - Initialize

- (void)initViewAlpha
{
    self.titleLabel.alpha = 0.0;
    self.loginView.alpha = 0.0;
    self.signView.alpha = 0.0;
    self.okButton.alpha = 0.0;
    self.cancelButton.alpha = 0.0;
}

- (void)initViewPosition
{
    CGRect frame = self.titleLabel.frame;
    frame.origin.y = CGRectGetMidY([UIScreen mainScreen].bounds) - CGRectGetMidY(frame);
    self.titleLabel.frame = frame;
}

- (void)initTextField
{
    CGRect frame = CGRectMake(20, 0, 280, 35);
    
    self.usernameTextField = [[UITextField alloc] initWithFrame:frame];
    self.passwordTextField = [[UITextField alloc] initWithFrame:frame];
    self.emailTextField = [[UITextField alloc] initWithFrame:frame];
    self.confirmTextField = [[UITextField alloc] initWithFrame:frame];
    
    NSArray *textFields = @[self.usernameTextField, self.passwordTextField, self.emailTextField, self.confirmTextField];
    
    for (UITextField *textField in textFields) {
        textField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        textField.textColor = [UIColor darkGrayColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardAppearance = UIKeyboardAppearanceDark;
        textField.enablesReturnKeyAutomatically = YES;
        textField.delegate = self;
        textField.alpha = 0.0;
    }
    
    self.usernameTextField.placeholder = @"Username";
    self.passwordTextField.placeholder = @"Password";
    self.emailTextField.placeholder    = @"Email Address";
    self.confirmTextField.placeholder  = @"Confirm Password";
    
    self.passwordTextField.secureTextEntry = YES;
    self.confirmTextField.secureTextEntry  = YES;
    
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.confirmTextField.returnKeyType = UIReturnKeyGo;
}

- (void)initGestureRecognizer
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Login

- (IBAction)ok:(id)sender
{
    if (self.loginView.alpha)
        [self login];
    else
        [self sign];
}

- (void)login
{
    [[GatherClient client] loginWithUsername:self.usernameTextField.text
                                    password:self.passwordTextField.text
                                     success:^{
                                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                         [self dismissViewControllerAnimated:NO completion:nil];
                                         [self presentViewController:storyboard.instantiateInitialViewController animated:NO completion:nil];
                                     }
                                     failure:^(NSError *error) {
                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                                             message:error.localizedDescription
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                         [alertView show];
                                     }];
}

- (void)sign
{
    
}

#pragma mark - Animations

- (void)appearAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGPoint center = self.titleLabel.center;
    center.y = 100;
    self.titleLabel.center = center;
    self.titleLabel.alpha = 1.0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationDuration:0.5];
    self.loginView.alpha = 1.0;
    self.signView.alpha = 1.0;
    [UIView commitAnimations];
}

- (IBAction)login:(id)sender
{
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    CGRect frame = self.loginView.frame;
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame);
    frame.size.height = 250;
    animation.toValue = [NSValue valueWithCGRect:frame];
    animation.dynamicsFriction = 14.0;
    [self.loginView pop_addAnimation:animation forKey:nil];
    
    CGFloat y = CGRectGetMaxY(frame) + 30;
    CGRect buttonFrame;
    buttonFrame = self.okButton.frame;
    buttonFrame.origin.y = y;
    self.okButton.frame = buttonFrame;
    buttonFrame = self.cancelButton.frame;
    buttonFrame.origin.y = y;
    self.cancelButton.frame = buttonFrame;
    
    CGRect textFieldFrame = self.usernameTextField.frame;
    textFieldFrame.origin.y = 75;
    self.usernameTextField.frame = textFieldFrame;
    textFieldFrame.origin.y = 130;
    self.passwordTextField.frame = textFieldFrame;
    [self.loginView addSubview:self.usernameTextField];
    [self.loginView addSubview:self.passwordTextField];
    self.passwordTextField.returnKeyType = UIReturnKeyGo;
    
    [UIView beginAnimations:nil context:nil];
    self.signView.alpha = 0.0;
    self.okButton.alpha = 0.7;
    self.cancelButton.alpha = 0.7;
    self.loginButton.alpha = 0.0;
    self.usernameTextField.alpha = 1.0;
    self.passwordTextField.alpha = 1.0;
    [UIView commitAnimations];
    
    [self animationButtonIn];
}

- (IBAction)sign:(id)sender
{
    WebBrowserController *wbc = [[WebBrowserController alloc] initWithURL:@"http://gather.whouz.com/account/register"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:wbc];
    [self presentViewController:nc animated:YES completion:nil];
    return;
    
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    CGRect frame = self.signView.frame;
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame);
    frame.size.height = 250;
    animation.toValue = [NSValue valueWithCGRect:frame];
    animation.dynamicsFriction = 14.0;
    [self.signView pop_addAnimation:animation forKey:nil];
    
    CGFloat y = CGRectGetMaxY(frame) + 30;
    CGRect buttonFrame;
    buttonFrame = self.okButton.frame;
    buttonFrame.origin.y = y;
    self.okButton.frame = buttonFrame;
    buttonFrame = self.cancelButton.frame;
    buttonFrame.origin.y = y;
    self.cancelButton.frame = buttonFrame;
    
    CGRect textFieldFrame = self.usernameTextField.frame;
    textFieldFrame.origin.y = 40;
    self.usernameTextField.frame = textFieldFrame;
    textFieldFrame.origin.y = 85;
    self.emailTextField.frame = textFieldFrame;
    textFieldFrame.origin.y = 130;
    self.passwordTextField.frame = textFieldFrame;
    textFieldFrame.origin.y = 175;
    self.confirmTextField.frame = textFieldFrame;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    [self.signView addSubview:self.usernameTextField];
    [self.signView addSubview:self.passwordTextField];
    [self.signView addSubview:self.emailTextField];
    [self.signView addSubview:self.confirmTextField];
    
    [UIView beginAnimations:nil context:nil];
    self.loginView.alpha = 0.0;
    self.okButton.alpha = 0.7;
    self.cancelButton.alpha = 0.7;
    self.signButton.alpha = 0.0;
    self.usernameTextField.alpha = 1.0;
    self.passwordTextField.alpha = 1.0;
    self.emailTextField.alpha = 1.0;
    self.confirmTextField.alpha = 1.0;
    [UIView commitAnimations];
    
    [self animationButtonIn];
}

- (void)animationButtonIn
{
    POPSpringAnimation *rotation;
    POPSpringAnimation *move;
    CGPoint center;
    
    rotation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.fromValue = @-M_PI;
    rotation.toValue = @0;
    rotation.dynamicsFriction = 14.0;
    [self.okButton.layer pop_addAnimation:rotation forKey:nil];
    move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center = self.okButton.center;
    center.x = -30;
    move.fromValue = [NSValue valueWithCGPoint:center];
    center.x = 80;
    move.toValue = [NSValue valueWithCGPoint:center];
    move.dynamicsFriction = 14.0;
    [self.okButton pop_addAnimation:move forKey:nil];
    
    rotation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.fromValue = @M_PI;
    rotation.toValue = @0;
    rotation.dynamicsFriction = 14.0;
    [self.cancelButton.layer pop_addAnimation:rotation forKey:nil];
    move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center = self.okButton.center;
    center.x = 350;
    move.fromValue = [NSValue valueWithCGPoint:center];
    center.x = 240;
    move.toValue = [NSValue valueWithCGPoint:center];
    move.dynamicsFriction = 14.0;
    [self.cancelButton pop_addAnimation:move forKey:nil];
}

- (void)animationButtonOut
{
    POPSpringAnimation *rotation;
    POPSpringAnimation *move;
    CGPoint center;
    
    rotation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.fromValue = @0;
    rotation.toValue = @-M_PI;
    [self.okButton.layer pop_addAnimation:rotation forKey:nil];
    move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center = self.okButton.center;
    center.x = 80;
    move.fromValue = [NSValue valueWithCGPoint:center];
    center.x = -30;
    move.toValue = [NSValue valueWithCGPoint:center];
    [self.okButton pop_addAnimation:move forKey:nil];
    
    rotation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.fromValue = @0;
    rotation.toValue = @M_PI;
    [self.cancelButton.layer pop_addAnimation:rotation forKey:nil];
    move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center = self.okButton.center;
    center.x = 240;
    move.fromValue = [NSValue valueWithCGPoint:center];
    center.x = 350;
    move.toValue = [NSValue valueWithCGPoint:center];
    [self.cancelButton pop_addAnimation:move forKey:nil];
}

- (IBAction)cancel:(id)sender
{
    if (self.loginButton.alpha == 0.0) {
        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        CGRect frame = CGRectMake(0, 340, 320, 45);
        animation.toValue = [NSValue valueWithCGRect:frame];
        animation.dynamicsFriction = 14.0;
        [self.loginView pop_addAnimation:animation forKey:nil];
        
        [UIView beginAnimations:nil context:nil];
        self.signView.alpha = 1.0;
        self.okButton.alpha = 0.0;
        self.cancelButton.alpha = 0.0;
        self.loginButton.alpha = 1.0;
        self.usernameTextField.alpha = 0.0;
        self.passwordTextField.alpha = 0.0;
        [UIView commitAnimations];
        
        [self animationButtonOut];
    } else {
        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        CGRect frame = CGRectMake(0, 400, 320, 45);
        animation.toValue = [NSValue valueWithCGRect:frame];
        animation.dynamicsFriction = 14.0;
        [self.signView pop_addAnimation:animation forKey:nil];
        
        [UIView beginAnimations:nil context:nil];
        self.loginView.alpha = 1.0;
        self.okButton.alpha = 0.0;
        self.cancelButton.alpha = 0.0;
        self.signButton.alpha = 1.0;
        self.usernameTextField.alpha = 0.0;
        self.passwordTextField.alpha = 0.0;
        self.emailTextField.alpha = 0.0;
        self.confirmTextField.alpha = 1.0;
        [UIView commitAnimations];
        
        [self animationButtonOut];
    }
}

#pragma mark - Handle guesture

- (void)closeKeyboard
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
}

#pragma mark - Handle notifications

- (void)keyboardWillShow
{
    [UIView beginAnimations:nil context:nil];
    CGRect frame = self.signView.frame;
    frame.origin.y -= 50;
    self.signView.frame = frame;
    self.titleLabel.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)keyboardWillHide
{
    [UIView beginAnimations:nil context:nil];
    CGRect frame = self.signView.frame;
    frame.origin.y += 50;
    self.signView.frame = frame;
    self.titleLabel.alpha = 1.0;
    [UIView commitAnimations];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.passwordTextField.returnKeyType == UIReturnKeyGo) {
        if (textField == self.usernameTextField)
            [self.passwordTextField becomeFirstResponder];
        
        if (textField == self.passwordTextField) {
            [textField resignFirstResponder];
            [self ok:self.okButton];
        }
    } else {
        if (textField == self.usernameTextField)
            [self.emailTextField becomeFirstResponder];
        
        if (textField == self.emailTextField)
            [self.passwordTextField becomeFirstResponder];
        
        if (textField == self.passwordTextField)
            [self.confirmTextField becomeFirstResponder];
        
        if (textField == self.confirmTextField) {
            [textField resignFirstResponder];
            [self ok:self.okButton];
        }
    }
    
    return NO;
}

@end
