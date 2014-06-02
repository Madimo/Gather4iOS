//
//  StartViewController.m
//  Gather
//
//  Created by Madimo on 14-6-2.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "StartViewController.h"
#import "BackgroundImage.h"
#import "GatherAPI.h"
#import <POP.h>

@interface StartViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
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
    
    self.backgroundImageView.image = [BackgroundImage sharedImage].image;

    [self initViewPositionAndAlpha];
    [self initTextField];
    [self initGestureRecognizer];
    [self initNotification];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self appearAnimation];
}

#pragma mark - Initialize

- (void)initViewPositionAndAlpha
{
    self.titleLabel.center = CGPointMake(160, CGRectGetMidY([UIScreen mainScreen].bounds));
    self.loginView.alpha = 0.0;
    self.signView.alpha = 0.0;
    self.okButton.alpha = 0.0;
    self.cancelButton.alpha = 0.0;
}

- (void)initTextField
{
    CGRect frame = CGRectMake(20, 0, 280, 35);
    
    self.usernameTextField = ({
        UITextField *t = [[UITextField alloc] initWithFrame:frame];
        t.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        t.textColor = [UIColor lightGrayColor];
        t.clearButtonMode = UITextFieldViewModeWhileEditing;
        t.textAlignment = NSTextAlignmentCenter;
        t.keyboardType = UIKeyboardTypeASCIICapable;
        t.spellCheckingType = UITextSpellCheckingTypeNo;
        t.autocorrectionType = UITextAutocorrectionTypeNo;
        t.returnKeyType = UIReturnKeyNext;
        t.enablesReturnKeyAutomatically = YES;
        t.delegate = self;
        t.placeholder = @"Username";
        t.alpha = 0.0;
        t;
    });
    
    self.passwordTextField = ({
        UITextField *t = [[UITextField alloc] initWithFrame:frame];
        t.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        t.textColor = [UIColor lightGrayColor];
        t.clearButtonMode = UITextFieldViewModeWhileEditing;
        t.textAlignment = NSTextAlignmentCenter;
        t.enablesReturnKeyAutomatically = YES;
        t.delegate = self;
        t.placeholder = @"Password";
        t.alpha = 0.0;
        t.secureTextEntry = YES;
        t;
    });
    
    self.emailTextField = ({
        UITextField *t = [[UITextField alloc] initWithFrame:frame];
        t.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        t.textColor = [UIColor lightGrayColor];
        t.clearButtonMode = UITextFieldViewModeWhileEditing;
        t.textAlignment = NSTextAlignmentCenter;
        t.keyboardType = UIKeyboardTypeEmailAddress;
        t.keyboardType = UIKeyboardTypeASCIICapable;
        t.spellCheckingType = UITextSpellCheckingTypeNo;
        t.returnKeyType = UIReturnKeyNext;
        t.enablesReturnKeyAutomatically = YES;
        t.delegate = self;
        t.placeholder = @"Email Address";
        t.alpha = 0.0;
        t;
    });
    
    self.confirmTextField = ({
        UITextField *t = [[UITextField alloc] initWithFrame:frame];
        t.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        t.textColor = [UIColor lightGrayColor];
        t.clearButtonMode = UITextFieldViewModeWhileEditing;
        t.textAlignment = NSTextAlignmentCenter;
        t.returnKeyType = UIReturnKeyGo;
        t.enablesReturnKeyAutomatically = YES;
        t.delegate = self;
        t.placeholder = @"Confirm Password";
        t.alpha = 0.0;
        t.secureTextEntry = YES;
        t;
    });
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
