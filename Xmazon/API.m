//
//  API.m
//  Xmazon
//
//  Created by Pierre Boudon on 13/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "API.h"

@implementation API

+ (BOOL) getAppToken {
    __block BOOL theReturn = NO;
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xmazon.appspaces.fr/oauth/token"]];
    request.HTTPMethod = @"POST";
    
    NSString* body = [NSString stringWithFormat:@"grant_type=client_credentials&client_id=%@&client_secret=%@", idAccessAPI, secretAccessAPI];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Response : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            theReturn = YES;
            
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
    
    return theReturn;
}
+ (BOOL) getUserToken {
    return false;
}

+ (BOOL) subscribeUserWithEmail:(NSString*)pEmail andPassword:(NSString*)pPassword andFirstName:(NSString*)pFirstName andLastName:(NSString*)pLastName {
    /*__block BOOL theReturn = NO;
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
                NSLog(@"Response : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    if ([jsonObjects valueForKey:@"code"]) {
                        NSLog(@"TestIf");
                        [userDefaults setValue:[jsonObjects valueForKey:@"code"] forKey:@"error_code"];
                        NSLog(@"%@", [userDefaults valueForKey:@"error_code"]);
                        theReturn = NO;
                    } else {
                        [userDefaults setValue:[jsonObjects valueForKey:@"uid"] forKey:@"uid"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"email"] forKey:@"email"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"username"] forKey:@"username"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"firstname"] forKey:@"firstname"];
                        [userDefaults setValue:[jsonObjects valueForKey:@"lastname"] forKey:@"lastname"];
                        theReturn = YES;
                    }
                }
            } else {
            }
        }] resume];
    } else {
        if ([self getAppToken]) {
            [self subscribeUserWithEmail:pEmail andPassword:pPassword andFirstName:pFirstName andLastName:pLastName];
        }
    }*/
    
    //Voir URL : http://stackoverflow.com/questions/26665010/force-wait-for-nsurlsessiondatatask-completion
    
    return NO;
}

@end
