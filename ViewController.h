//
//  ViewController.h
//  SQLiteApp
//
//  Created by A's macAir on 9/25/15.
//  Copyright (c) 2015 Abdoulaye Diallo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *country;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *zipcode;
- (IBAction)save:(id)sender;
- (IBAction)find:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)clear:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *DB;
- (IBAction)resignFirstResponder:(id)sender;

@end

