//
//  API.m
//  Xmazon
//
//  Created by Pierre Boudon on 13/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "API.h"

@implementation API

+ (void) getAppToken {
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xmazon.appspaces.fr/oauth/token"]];
    request.HTTPMethod = @"POST";
    
    NSString* body = [NSString stringWithFormat:@"grant_type=client_credentials&client_id=%@&client_secret=%@", idAccessAPI, secretAccessAPI];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Response : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            if (error) {
                NSLog(@"%@", error);
            } else {
                [userDefaults setValue:[jsonObjects valueForKey:@"token_type"] forKey:@"token_type"];
                [userDefaults setValue:[jsonObjects valueForKey:@"access_token"] forKey:@"access_token"];
                [userDefaults setValue:[jsonObjects valueForKey:@"refresh_token"] forKey:@"refresh_token"];
            }
        } else {
            NSLog(@"%@", error);
        }
    }] resume];
}
+ (void) getUserToken:(NSString*)pEmail andPassword:(NSString*)pPassword {
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
                    }
                }
            } else {
            }
        }] resume];
    } else {
        [self getAppToken];
        [self getUserToken:pEmail andPassword:pPassword];
    }
}

@end
