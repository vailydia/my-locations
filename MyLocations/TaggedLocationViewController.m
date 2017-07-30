//
//  SecondViewController.m
//  MyLocations
//
//  Created by Weiling Xi on 19/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "TaggedLocationViewController.h"

@interface TaggedLocationViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *resultController;
@property (strong, nonatomic) NSArray *titleOfSections;
@property (strong, nonatomic) NSMutableDictionary *resultDictionary;

@end

@implementation TaggedLocationViewController
{
    Location *_selectedLocation;
    BOOL isEditting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self viewWillReload];
}


- (IBAction)deleteItem:(id)sender {
    
    if(isEditting == NO){
        [self.tableView setEditing:YES animated:YES];
        isEditting = YES;
    }else {
        [self.tableView setEditing:NO animated:YES];
        isEditting = NO;
    }
    
}


- (void) viewWillReload{
    
    [self initializeNSFetchedResultsControllerDelegate];
    [self setSection];
    [self.tableView reloadData];
    
    [self.tableView setEditing:NO animated:YES];
    isEditting = NO;
    
}


- (void)setSection {
    
    self.resultDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *temporaryResultArray = self.resultController.sections[0].objects;
    
    NSArray *temporarySectionNameArray = @[@"No Category", @"Apple Store", @"Bar", @"BookStore", @"Club", @"Grocery Store", @"House", @"Icecream Vendor", @"Beach", @"Landmark", @"Park"];
    
    for (NSString *item in temporarySectionNameArray) {
        
        for (Location *location in temporaryResultArray) {
            
            if ([location.category.description isEqualToString:item]) {
                
                if([self.resultDictionary objectForKey:item] == nil){
                    NSMutableArray *sectionArray = [[NSMutableArray alloc] initWithObjects:location, nil];
                    [self.resultDictionary setObject:sectionArray forKey:item];
                } else {
                    NSMutableArray *sectionArray = (NSMutableArray *)[self.resultDictionary objectForKey:item];
                    [sectionArray addObject:location];
                }
                
            }
        }
    }
    
    self.titleOfSections = [self.resultDictionary allKeys];
    
}


#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *sectionName = self.titleOfSections[indexPath.section];
        Location *selectedLocation = [[self.resultDictionary objectForKey:sectionName] objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject: selectedLocation];
        NSError *err;
        BOOL saveSuccess = [self.managedObjectContext save:&err];
        if(!saveSuccess) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"Couldn't save" userInfo:@{NSUnderlyingErrorKey:err}];
        }
        
        [self viewWillReload];
        
    }
    
}



- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSString *sectionName = self.titleOfSections[indexPath.section];
        
    _selectedLocation = [[self.resultDictionary objectForKey:sectionName] objectAtIndex:indexPath.row];
        
    return indexPath;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleOfSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionName = self.titleOfSections[section];
    return [[self.resultDictionary objectForKey:sectionName] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Location *locationItem = self.resultController.sections[indexPath.section].objects[indexPath.row];
    
    NSString *sectionName = self.titleOfSections[indexPath.section];
    Location *locationItem = [[self.resultDictionary objectForKey:sectionName] objectAtIndex:indexPath.row];
    
    LocationViewCell *cell = (LocationViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationViewCell" forIndexPath:indexPath];
    
    [cell setInternalFields:locationItem];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = [self.titleOfSections objectAtIndex:section];
    return sectionName;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void) initializeNSFetchedResultsControllerDelegate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    //[fetchRequest setReturnsDistinctResults:YES];
    //[fetchRequest setPropertiesToFetch:@[@"Beach"]];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES]];
    //[fetchRequest setResultType:NSDictionaryResultType];
    
    self.resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.resultController.delegate = self;
    
    NSError *error;
    
    BOOL fetchSuccess = [self.resultController performFetch:&error];
    if(!fetchSuccess) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Couldn't fetch data" userInfo:nil];
    }
    
}



#pragma mark - Navigation


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"EditLocation"]) {
        
        MyLocationTableViewController *controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.location = _selectedLocation;
        
    }
    
}

@end
