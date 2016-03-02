//
//  CategoryTableViewController.m
//  Xmazon
//
//  Created by Pierre on 27/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "CategoryTableViewController.h"

@interface CategoryTableViewController ()

@end

@implementation CategoryTableViewController

// MARK: - Variables
@synthesize storeName = storeName_;
@synthesize storeUid = storeUid_;
@synthesize categories = categories_;


// MARK: - IBOutlets


// MARK: - IBActions
-(IBAction)showOptions:(UIButton*) sender {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Options" message:@"Que souhaitez-vous faire ?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* search = [UIAlertAction actionWithTitle:@"Faire une recherche" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self searchButtonTapped];
    }];
    UIAlertAction* cart = [UIAlertAction actionWithTitle:@"Afficher le panier" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        PanierTableViewController* inscriptionVC = [[PanierTableViewController alloc] init];
        [self.navigationController modalTransitionStyle];
        [self.navigationController pushViewController:inscriptionVC animated:YES];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:search];
    [alertController addAction:cart];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}


//MARK: - Méthodes de base
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self getCategoryList:self.storeUid];
    self.categories = [[NSMutableArray alloc] init];
    
    UIBarButtonItem* optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions:)];
    self.navigationItem.rightBarButtonItem = optionsButton;
    
    self.navigationItem.title = self.storeName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

static NSString* const kCellReuseIdentifier = @"CategoryCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    if (!cell) {
        //NSLog(@"CREATE Cell");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellReuseIdentifier];
    } else {
        //NSLog(@"REUSE Cell");
    }
    
    NSString* value = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.textLabel.text = value;
    cell.detailTextLabel.text = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"uid"];
    
    return cell;
}


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    ProduitTableViewController *detailViewController = [[ProduitTableViewController alloc] initWithNibName:@"ProduitTableViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    detailViewController.catName = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"name"];
    detailViewController.catUid = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"uid"];
    detailViewController.products = nil;
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


//MARK: - Méthodes perso
- (void) getCategoryList:(NSString*)storeUID {
    NSLog(@"AFTER : %@", storeUID);
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/category/list?store_uid=%@&limit=3", self.storeUid]]];
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
            //NSLog(@"ENTER ?");
            if(!error) {
                //NSLog(@"And Now ?");
                NSLog(@"Response getCategoryList : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    NSLog(@"%@", jsonObjects);
                    NSArray* result = [jsonObjects valueForKey:@"result"];
                    //NSLog(@"BEFORE : %@", [[result objectAtIndex:0] valueForKey:@"uid"]);
                    //[self getCategoryList:[[result objectAtIndex:0] valueForKey:@"uid"]];
                    
                    if (result == nil || [result count] == 0) {
                        /*ProduitTableViewController *detailViewController = [[ProduitTableViewController alloc] initWithNibName:@"ProduitTableViewController" bundle:nil];
                        
                        detailViewController.catName = self.storeName;
                        detailViewController.catUid = self.storeUid;
                        
                        [self.navigationController pushViewController:detailViewController animated:YES];*/
                    } else {
                        for (int i = 0; i < result.count; i++) {
                            [self.categories addObject:[result objectAtIndex:i]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [self.tableView reloadData];
                        });
                    }
                }
            } else {
                //NSLog(@"HERE HERE : %@", error);
            }
        }] resume];
    } else {
        [API getAppToken];
        [API getStoreList];
    }
}

- (void) searchButtonTapped {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Rechercher" message:@"Rechercher un produit" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Recherche";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Limit";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Offset";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Rechercher" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        NSLog(@"Recherche : %@", [alertController.textFields objectAtIndex:0].text);
        [self getProductListByResearch:[alertController.textFields objectAtIndex:0].text andLimit:[alertController.textFields objectAtIndex:1].text andOffset:[alertController.textFields objectAtIndex:2].text];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) getProductListByResearch:(NSString*)research andLimit:(NSString*)pLimit andOffset:(NSString*)pOffset {
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURL* url;
    if ([pLimit isEqualToString:@""] && [pOffset isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&offset=%@", research, pOffset]];
    } else if ([pOffset isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&limit=%@", research, pLimit]];
    } else if ([pLimit isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&offset=%@", research, pOffset]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&limit=%@&offset=%@", research, pLimit, pOffset]];
    }
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    if ([userDefaults valueForKey:@"user_token_type"] && [userDefaults valueForKey:@"user_access_token"] && [userDefaults valueForKey:@"user_refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"user_token_type"] capitalizedString], [userDefaults valueForKey:@"user_access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //NSLog(@"ENTER ?");
            if(!error) {
                //NSLog(@"And Now ?");
                NSLog(@"Response getProductList : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else if ([[jsonObjects valueForKey:@"error"] isEqualToString:@"invalid_token"]) {
                    [API getUserToken];
                    [self getProductListByResearch:research andLimit:pLimit andOffset:pOffset];
                } else {
                    NSLog(@"%@", jsonObjects);
                    /*NSArray* result = [jsonObjects valueForKey:@"result"];
                     
                     if (result == nil || [result count] == 0) {
                     NSLog(@"Rien");
                     } else {
                     for (int i = 0; i < result.count; i++) {
                     [self.products addObject:[result objectAtIndex:i]];
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^() {
                     [self.tableView reloadData];
                     });
                     }*/
                }
            } else {
                //NSLog(@"HERE HERE : %@", error);
            }
        }] resume];
    } else {
        [API getUserToken];
        [self getProductListByResearch:research andLimit:pLimit andOffset:pOffset];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
