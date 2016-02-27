//
//  InscriptionViewController.h
//  Xmazon
//
//  Created by Pierre Boudon on 13/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "StoreTableViewController.h"

@interface InscriptionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;

- (void) showErrorWithTitle:(NSString*)pTitle andDescription:(NSString*)pDescription;
- (void) getUserToken:(NSString*)pEmail andPassword:(NSString*)pPassword;

@end
