//
//  InscriptionViewController.m
//  Xmazon
//
//  Created by Pierre Boudon on 13/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "InscriptionViewController.h"

@interface InscriptionViewController ()

@end

@implementation InscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)subscribeButtonTapped:(id)sender {
    /*if (![API subscribeUserWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text andFirstName:self.firstnameTextField.text andLastName:self.lastnameTextField.text]) {
        NSLog(@"Test");
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults valueForKey:@"error_code"]) {
            NSLog(@"Test2");
            if ([[userDefaults valueForKey:@"error_code"] isEqualToString:@"500"]) {
                UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Erreur" message:@"Vous êtes déjà inscrit !" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
        
        [userDefaults removeObjectForKey:@"error_code"];
    }*/
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
