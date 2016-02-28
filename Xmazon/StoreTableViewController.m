//
//  StoreTableViewController.m
//  Xmazon
//
//  Created by Pierre on 27/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "StoreTableViewController.h"

@interface StoreTableViewController ()

@end

@implementation StoreTableViewController

// MARK: - Variables
@synthesize uD = uD_;
@synthesize stores = stores_;
@synthesize alreadyConnected = alreadyConnected_;


// MARK: - IBOutlets


// MARK: - IBActions
- (IBAction)logButtonTapped:(UIButton*) sender {
    InscriptionViewController* inscriptionVC = [[InscriptionViewController alloc] init];
    [self.navigationController pushViewController:inscriptionVC animated:YES];
}

-(IBAction)searchButtonTapped:(UIButton*) sender {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Rechercher" message:@"Rechercher un produit" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Recherche";
    }];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Rechercher" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        NSLog(@"Recherche : %@", [alertController.textFields objectAtIndex:0].text);
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}


// MARK: - Méthodes de base
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.uD = [NSUserDefaults standardUserDefaults];
    [self load];
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
    return self.stores.count;
}

static NSString* const kCellReuseIdentifier = @"StoreCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    if (!cell) {
        //NSLog(@"CREATE Cell");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellReuseIdentifier];
    } else {
        //NSLog(@"REUSE Cell");
    }
    
    NSString* value = [[self.stores objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.textLabel.text = value;
    cell.detailTextLabel.text = [[self.stores objectAtIndex:indexPath.row] valueForKey:@"uid"];
    
    return cell;
}


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    CategoryTableViewController *detailViewController = [[CategoryTableViewController alloc] initWithNibName:@"CategoryTableViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    detailViewController.storeName = [[self.stores objectAtIndex:indexPath.row] valueForKey:@"name"];
    detailViewController.storeUid = [[self.stores objectAtIndex:indexPath.row] valueForKey:@"uid"];
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


// MARK: - Méthodes perso
- (void)load {
    if ([self.uD valueForKey:@"user_access_token"]) {
        [self getStoreList];
        
        self.uD = [NSUserDefaults standardUserDefaults];
        self.stores = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *logButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"S'enregistrer"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(logButtonTapped:)];
        
        UIBarButtonItem* searchButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                         target:self
                                         action:@selector(searchButtonTapped:)];
        
        self.navigationItem.leftBarButtonItem = logButton;
        self.navigationItem.rightBarButtonItem = searchButton;
    } else {
        [API getAppToken];
        InscriptionViewController* inscriptionVC = [[InscriptionViewController alloc] init];
        [self.navigationController presentViewController:inscriptionVC animated:YES completion:0];
    }
}

- (void) getStoreList {
    
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
                //NSLog(@"Response getStoreList: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:500]) {
                        UINavigationController* storeView = [[UINavigationController alloc] initWithRootViewController:[InscriptionViewController new]];;
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [self presentViewController:storeView animated:YES completion:0];
                        });
                    } else if ([jsonObjects valueForKey:@"code"] == [[NSNumber alloc] initWithLong:401]) {
                        //NSLog(@"PASSE ICI !");
                        [API getAppToken];
                        [self getStoreList];
                    } else {
                        NSArray* result = [jsonObjects valueForKey:@"result"];
                        //NSLog(@"BEFORE : %@", [[result objectAtIndex:0] valueForKey:@"uid"]);
                        //[self getCategoryList:[[result objectAtIndex:0] valueForKey:@"uid"]];
                        
                        for (int i = 0; i < result.count; i++) {
                            [self.stores addObject:[result objectAtIndex:i]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [self.tableView reloadData];
                        });
                    }
                }
                
            } else {
                //NSLog(@"HERE : %@", error);
            }
        }] resume];
    } else {
        [API getAppToken];
        [self getStoreList];
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
