//
//  MyLocationTableViewController.m
//  MyLocations
//
//  Created by Weiling Xi on 26/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "MyLocationTableViewController.h"

@interface MyLocationTableViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longititudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation MyLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showDetails];
}

- (void)showDetails {
    CLPlacemark *placemark = self.location.placemark;
    
    self.descriptionTextView.text = self.location.locationDescription;
    self.categoryLabel.text = self.location.category;
    self.latitudeLabel.text =[NSString stringWithFormat:@"%.8f",self.location.latitude];
    self.longititudeLabel.text = [NSString stringWithFormat:@"%.8f",self.location.longitude];
    self.dateLabel.text = [self formateDate:self.location.date];
    self.addressLabel.text = [self stringFromPlacemark:placemark];
    
    NSString *title = placemark.areasOfInterest.firstObject.description;
    
    if(title == nil) {
        
        if(self.location.locationDescription != nil) {
            self.navigationItem.title = self.location.locationDescription;
        }else{
            self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare,placemark.thoroughfare];
        }
        
    } else {
        self.navigationItem.title = title;
    }
    
}

- (NSString *)stringFromPlacemark: (CLPlacemark *)thePlacemark {
    
    return [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@", thePlacemark.subThoroughfare,thePlacemark.thoroughfare,thePlacemark.locality,thePlacemark.administrativeArea,thePlacemark.postalCode,thePlacemark.country];
}

- (NSString *)formateDate: (NSDate *)theDate {
    
    static NSDateFormatter *formatter = nil;
    
    if(formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:theDate];
}



#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    }
    else if(indexPath.section == 2 && indexPath.row == 2) {
        CGRect rect = CGRectMake(183, 12, 217, 10000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height + 20;
    } else {
        return 44;
    }
    
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}



#pragma UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    cell.imageView.image = [self readImageFromFile];
    
    return cell;
}

- (UIImage *) readImageFromFile {
    
    NSString *imagePath = [self imageSavedPath:@"image.jpg"];
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    return image;
}



- (NSString *)imageSavedPath:(NSString *)imageName {
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    //获取文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
    NSLog(@"%@", imageDocPath);//debug
    
    //创建ImageFile文件夹
    [fileManager createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //返回保存图片的路径（图片保存在ImageFile文件夹下）
    NSString *imagePath = [imageDocPath stringByAppendingPathComponent:imageName];
    
    return imagePath;
}


@end
