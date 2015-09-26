//
//  ViewController.m
//  SQLiteApp
//
//  Created by A's macAir on 9/25/15.
//  Copyright (c) 2015 Abdoulaye Diallo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
NSArray *_countries;
}
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Let's set the delegate and the data source of the pickerview  to self.
    self.pickerView.delegate=self;
    self.pickerView.dataSource=self;
    
    
    //Let's connect to the database
    [self connectToTheDatabase];
    
    
    _countries=@[ @"Afghanistan",  @"Albania", @"Algeria", @"American Samoa", @"Andorra", @"Angola", @"Anguilla", @"Antarctica", @"Antigua and Barbuda", @"Argentina", @"Armenia", @"Aruba", @"Ashmore and Cartier Islands", @"Australia", @"Austria", @"Azerbaijan", @"The Bahamas", @"Bahrain", @"Bangladesh", @"Barbados", @"Bassas da India", @"Belarus", @"Belgium", @"Belize", @"Benin", @"Bermuda", @"Bhutan", @"Bolivia", @"Bosnia and Herzegovina", @"Botswana",  @"Brazil", @"British Indian Ocean Territory", @"British Virgin Islands", @"Brunei", @"Bulgaria", @"Burkina Faso",@"Guinea",@"Ghana" ];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-Connection of the database

-(void)connectToTheDatabase{
    

    NSArray *dirPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirectory=dirPaths[0];
    
    _databasePath = [[NSString alloc] initWithString:[docsDirectory stringByAppendingPathComponent:@"user.db"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager  fileExistsAtPath:_databasePath] == NO){
        
        const char *dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
            char *error;
            const char *sql_statement = "CREATE TABLE IF NOT EXISTS person (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, PASSWORD TEXT, EMAIL TEXT, ADDRESS TEXT, COUNTRY TEXT, ZIPCODE TEXT)";
            
            if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &error) != SQLITE_OK){\
                
                [self showAlertMessage:@"Failed to create the table" andTitle:@"Error"];
            }
            sqlite3_close(_DB);
        }
        else{
            [self showAlertMessage:@"Failed to open/create the table" andTitle:@"Error"];
        }
    }
}

#pragma mark- UIPickerView Delegate.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 1;
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _country.text=_countries[row];
    _pickerView.hidden=YES;
    
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return [_countries count];
}
           
#pragma mark-the Methods.

- (IBAction)save:(id)sender {
    
    sqlite3_stmt *stmt;
    const char *path = [_databasePath UTF8String];
    
    if(sqlite3_open(path, &_DB) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO person (NAME, PASSWORD, EMAIL,ADDRESS,COUNTRY,ZIPCODE) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", _name.text, _password.text, _email.text, _address.text, _country.text, _zipcode.text];
        
        const char *insertStatement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_DB, insertStatement, -1, &stmt, NULL);
        
        if(sqlite3_step(stmt) == SQLITE_DONE){
            [self showAlertMessage:@"User added to the database" andTitle:@"Message"];
            _name.text = @"";
            _password.text = @"";
            _address.text = @"";
            _email.text = @"";
            _country.text = @"";
            _zipcode.text = @"";
        }
        else{
            [self showAlertMessage:@"Failed to add the user" andTitle:@"Error"];
        }
        sqlite3_finalize(stmt);
        sqlite3_close(_DB);
    }
}

- (IBAction)find:(id)sender {
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT address, email, phone, city, state, zip FROM users WHERE name = \"%@\"", _name.text];
        const char *query_statement = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_DB, query_statement, -1, &statement, NULL) == SQLITE_OK){
            if(sqlite3_step(statement) == SQLITE_ROW){
                
                NSString *nameField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                _name.text= nameField;
                
                NSString *emailField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                _email.text = emailField;
                
                NSString *addressField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                _address.text = addressField;
                
                NSString *countryField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                _country.text = countryField;
                
                NSString *zipcodeField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                _zipcode.text = zipcodeField;
                
                
               [self showAlertMessage:@"Failed to search the database" andTitle:@"Error"];
                
            }
            else{
                [self showAlertMessage:@"Match not found in databse" andTitle:@"Message"];
                _name.text = @"";
                _password.text = @"";
                _address.text = @"";
                _email.text = @"";
                _country.text = @"";
                _zipcode.text = @"";
            }
            sqlite3_finalize(statement);
        }
        else{
            [self showAlertMessage:@"Failed to search the database" andTitle:@"Error"];
        }
        sqlite3_close(_DB);
    }
}


- (IBAction)remove:(id)sender {
    
    const char *path = [_databasePath UTF8String];
    char *error;
    
    if(sqlite3_open(path, &_DB) == SQLITE_OK){
        NSString *query = [NSString stringWithFormat:@"DELETE FROM users WHERE name = \"%@\"", _name.text];
        const char *queryStatement = [query UTF8String];
        
        
        if(sqlite3_exec(_DB, queryStatement, NULL, NULL, &error) == SQLITE_OK){
            
            [self showAlertMessage:@"Deleted from database" andTitle:@"Message"];
            _name.text = @"";
            _password.text = @"";
            _address.text = @"";
            _email.text = @"";
            _address.text = @"";
            _country.text = @"";
            _zipcode.text = @"";
        }
        else{
            [self showAlertMessage:@"Failed to remove from database" andTitle:@"Error!!"];
        }
    }
    else{
        [self showAlertMessage:@"Failed to remove from database" andTitle:@"Error!!"];
    }
    
}

- (IBAction)clear:(id)sender {
    _name.text = @"";
    _password.text = @"";
    _address.text = @"";
    _email.text = @"";
    _address.text = @"";
    _country.text = @"";
    _zipcode.text = @"";
}

-(void)showAlertMessage:(NSString*) message andTitle:(NSString*) title{
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    [alertView show];
}
- (IBAction)resignFirstResponder:(id)sender {
    
    [sender resignFirstResponder];
}
@end
