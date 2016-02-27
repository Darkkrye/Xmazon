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

- (IBAction)login:(id)sender {
    if (self.emailTextField.text && self.emailTextField.text.length > 5) {
        if (self.passwordTextField.text && self.passwordTextField.text.length > 5) {
            [self getUserToken:self.emailTextField.text andPassword:self.passwordTextField.text];
        } else {
            [self showErrorWithTitle:@"ERREUR" andDescription:@"Le mot de passe doit être supérieur à 5 lettres"];
        }
    } else {
        [self showErrorWithTitle:@"ERREUR" andDescription:@"Veuillez saisir un email valide"];
    }
    
}


- (void) getUserToken:(NSString*)pEmail andPassword:(NSString*)pPassword {
    NSLog(@"%@ - %@", pEmail, pPassword);
    
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xmazon.appspaces.fr/oauth/token"]];
    request.HTTPMethod = @"POST";
    
    if ([userDefaults valueForKey:@"token_type"] && [userDefaults valueForKey:@"access_token"] && [userDefaults valueForKey:@"refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"token_type"] capitalizedString], [userDefaults valueForKey:@"access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
        NSString* body = [NSString stringWithFormat:@"grant_type=password&username=%@&password=%@&client_id=%@&client_secret=%@", pEmail, pPassword, idAccessAPI, secretAccessAPI];
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"Response getUserToken : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:500]) {
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            NSLog(@"ERREUR");
                            //                            [self showErrorWithTitle:@"ERREUR" andDescription:@"Un compte a déjà été créé avec cet email."];
                        });
                    } else if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:401]) {
                        [API getAppToken];
                        [self getUserToken:pEmail andPassword:pPassword];
                    } else if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:400]) {
                        NSLog(@"ERROR : email ou password non valide");
                    } else {
                        [userDefaults setValue:[jsonObjects valueForKey:@"token_type"] forKey:@"user_token_type"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"access_token"] forKey:@"user_access_token"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"expires_in"] forKey:@"user_expires_in"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"refresh_token"] forKey:@"user_refresh_token"];
                        
                        UINavigationController* storeView = [[UINavigationController alloc] initWithRootViewController:[StoreTableViewController new]];;
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [self presentViewController:storeView animated:YES completion:0];
                        });
                    }
                }
            } else {
            }
        }] resume];
    } else {
        [API getAppToken];
        [self getUserToken:pEmail andPassword:pPassword];
    }
    //[API getStoreList];
}

- (IBAction)subscribeButtonTapped:(id)sender {
    if (self.emailTextField.text && self.emailTextField.text.length > 5) {
        if (self.passwordTextField.text && self.passwordTextField.text.length > 5) {
            if (self.firstnameTextField.text && self.firstnameTextField.text.length > 0) {
                if (self.lastnameTextField.text && self.lastnameTextField.text.length > 0) {
                    [self subscribeUserWithEmail:self.emailTextField.text andPassword:self.passwordTextField.text andFirstName:self.firstnameTextField.text andLastName:self.lastnameTextField.text];
                } else {
                    [self showErrorWithTitle:@"ERREUR" andDescription:@"Veuillez saisir un nom de famille"];
                }
            } else {
                [self showErrorWithTitle:@"ERREUR" andDescription:@"Veuillez saisir un prénom"];
            }
        } else {
            [self showErrorWithTitle:@"ERREUR" andDescription:@"Le mot de passe doit être supérieur à 5 lettres"];
        }
    } else {
        [self showErrorWithTitle:@"ERREUR" andDescription:@"Veuillez saisir un email valide"];
    }
}

- (void) showErrorWithTitle:(NSString*)pTitle andDescription:(NSString*)pDescription {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:pTitle
                                  message:pDescription
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"Ok !"
                                style:UIAlertActionStyleDefault
                                handler:nil];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) subscribeUserWithEmail:(NSString*)pEmail andPassword:(NSString*)pPassword andFirstName:(NSString*)pFirstName andLastName:(NSString*)pLastName {
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xmazon.appspaces.fr/auth/subscribe"]];
    request.HTTPMethod = @"POST";
    
    if ([userDefaults valueForKey:@"token_type"] && [userDefaults valueForKey:@"access_token"] && [userDefaults valueForKey:@"refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"token_type"] capitalizedString], [userDefaults valueForKey:@"access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
        NSString* body = [NSString stringWithFormat:@"grant_type=client_credentials&email=%@&password=%@&firstname=%@&lastname=%@", pEmail, pPassword, pFirstName, pLastName];
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"Response suscribeUser: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:500]) {
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [self showErrorWithTitle:@"ERREUR" andDescription:@"Un compte a déjà été créé avec cet email."];
                        });
                    } else if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:401]) {
                        [API getAppToken];
                        [self subscribeUserWithEmail:pEmail andPassword:pPassword andFirstName:pFirstName andLastName:pLastName];
                    } else {
                        [userDefaults setValue:[jsonObjects valueForKey:@"uid"] forKey:@"uid"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"email"] forKey:@"email"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"username"] forKey:@"username"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"firstname"] forKey:@"firstname"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"lastname"] forKey:@"lastname"];
                    }
                }
            } else {
            }
        }] resume];
    } else {
        [API getAppToken];
        [self subscribeUserWithEmail:pEmail andPassword:pPassword andFirstName:pFirstName andLastName:pLastName];
    }
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
