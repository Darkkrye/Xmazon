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
            NSLog(@"Response getAppToken : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
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

+ (void) getStoreList {
    
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
   
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xmazon.appspaces.fr/store/list"]];
        request.HTTPMethod = @"GET";

    if ([userDefaults valueForKey:@"token_type"] && [userDefaults valueForKey:@"access_token"] && [userDefaults valueForKey:@"refresh_token"]) {
            NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
            NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"token_type"] capitalizedString], [userDefaults valueForKey:@"access_token"]];
            [headers setObject:authorization forKey:@"Authorization"];
            request.allHTTPHeaderFields = headers;
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"Response getStoreList: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

                if (error) {
                    NSLog(@"%@", error);
                } else {
                    if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:500]) {
                        dispatch_async(dispatch_get_main_queue(), ^() {
//                            [self showErrorWithTitle:@"ERREUR" andDescription:@"Un compte a déjà été créé avec cet email."];
                        });
                    } else if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:401]) {
                        NSLog(@"PASSE ICI !");
                        [API getAppToken];
                        [self getStoreList];
                    } else {
                        NSArray* result = [jsonObjects valueForKey:@"result"];
                        NSLog(@"BEFORE : %@", [[result objectAtIndex:0] valueForKey:@"uid"]);
                        [self getCategoryList:[[result objectAtIndex:0] valueForKey:@"uid"]];

                    }
                }
                
            } else {
                NSLog(@"HERE : %@", error);
            }
        }] resume];
    } else {
        [self getAppToken];
        [self getStoreList];
    }
}

+ (void) getCategoryList:(NSString*)storeUID {
    NSLog(@"AFTER : %@", storeUID);
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/category/list?store_uid=%@&limit=3", storeUID]]];
    request.HTTPMethod = @"GET";
    
    if ([userDefaults valueForKey:@"token_type"] && [userDefaults valueForKey:@"access_token"] && [userDefaults valueForKey:@"refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"token_type"] capitalizedString], [userDefaults valueForKey:@"access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
//        NSString* body = [NSString stringWithFormat:@"store_uid=%@&limit=3", storeUID];
//        NSInputStream* dataStream = [[NSInputStream alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
//        request.HTTPBodyStream = dataStream ;
//        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"ENTER ?");
            if(!error) {
                NSLog(@"And Now ?");
                NSLog(@"Response getCategoryList : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    NSLog(@"%@", jsonObjects);
                }
            } else {
                NSLog(@"HERE HERE : %@", error);
            }
        }] resume];
    } else {
        [self getAppToken];
        [self getStoreList];
    }
}


@end
