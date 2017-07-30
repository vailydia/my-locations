//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Weiling Xi on 20/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location+CoreDataClass.h"

@interface LocationDetailsViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longititudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation LocationDetailsViewController
{
    
    NSString *_descriptionText;
    NSString *_categoryName;
    NSDate *_date;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.descriptionTextView.text = _descriptionText;
    self.categoryLabel.text = _categoryName;
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.latitude];
    self.longititudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.longitude];
    
    if(self.placemark != nil) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    } else {
        self.addressLabel.text = @"NO Address Found.";
    }
    
    self.dateLabel.text = [self formateDate:_date];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
}


-(void)hideKeyBoard:(UIGestureRecognizer *) gestureRecognizer {
    
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if(indexPath != nil && indexPath.section == 0 && indexPath == 0) {
        return;
    }
    [self.descriptionTextView resignFirstResponder];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if((self = [super initWithCoder:aDecoder])){
        
        _descriptionText = @"";
        _categoryName = @"No Category";
        _date = [NSDate date];
        
    }
    
    return self;
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


- (IBAction)done:(id)sender {
    
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    hudView.text = @"Tagged";
    
    
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    location.locationDescription = self.descriptionTextView.text;
    location.category = self.categoryLabel.text;
    location.latitude = self.coordinate.latitude;
    location.longitude = self.coordinate.longitude;
    location.date = _date;
    location.placemark = self.placemark;
    
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"Error : %@",error);
        abort();
    }
    

    //[self closeScreen];
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}


- (IBAction)cancel:(id)sender {
    
    [self closeScreen];
    
}

- (void) closeScreen {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
   
   

#pragma mark - UITableViewDelegate

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


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    }else {
        return nil;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }
    
    if(indexPath.section == 1) {
        [self choosePictures];
    }
    
}



#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _descriptionText = textView.text;
}





#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"%@",info);
    
    NSString *mediaType = info[@"UIImagePickerControllerMediaType"];
    
    if([mediaType isEqualToString:@"public.image"]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self savePhoto:image];
        
    }
  
}


- (void)choosePictures {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photo Source" message:@"Please select one" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *openCameraAction = [UIAlertAction actionWithTitle:@"Take a photoe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        BOOL isAvailableOfCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if(!isAvailableOfCamera) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"No camera is available" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
            
        } else {
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        }
        
    }];
    
    UIAlertAction *openAlbumAction = [UIAlertAction actionWithTitle:@"Choose from Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    [alert addAction:openCameraAction];
    [alert addAction:openAlbumAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)savePhoto: (UIImage *)image {
    
    NSString *imagePath = [self imageSavedPath:@"image.jpg"];
    BOOL isSaveSuccess = [self saveToDocument:image withFilePath:imagePath];
    
    if(isSaveSuccess){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save Success!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:okAction];
        
        [self.presentedViewController presentViewController:alert animated:YES completion:nil];
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save Fail!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okAction];
        
        [self.presentedViewController presentViewController:alert animated:YES completion:nil];
    }
    
}

//将选取的图片保存到目录文件夹下
- (BOOL)saveToDocument:(UIImage *)image withFilePath:(NSString *)filePath {
    
    if(image == nil || filePath == nil || [filePath isEqualToString:@""]){
        return NO;
    }
    
    @try {
        
        NSData *imageData = nil;
        //获取文件扩展名
        NSString *extention = [filePath pathExtension];
        if([extention isEqualToString:@"png"]){
            imageData = UIImagePNGRepresentation(image);
        }else{
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        
        if(imageData == nil || [imageData length] <= 0){
            return NO;
        }
        
        //将图片写入指定路径
        [imageData writeToFile:filePath atomically:YES];
        return YES;
        
    } @catch (NSException *exception) {
        
        NSLog(@"save to document failed.");
        
    }
    
    return NO;
    
}


- (NSString *)imageSavedPath:(NSString *)imageName {
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    //获取文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingString:@"/ImageFile"];
    NSLog(@"%@", imageDocPath);//debug
    
    //创建ImageFile文件夹
    [fileManager createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //返回保存图片的路径（图片保存在ImageFile文件夹下）
    NSString *imagePath = [[imageDocPath stringByAppendingString:@"/"] stringByAppendingString:imageName];
    
    return imagePath;
}


#pragma mark - Navigation



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"PickCategory"]) {
        
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.seletedCategoryName = _categoryName;
        
    }
    
}


- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue {
    
    CategoryPickerViewController *viewController = segue.sourceViewController;
    _categoryName = viewController.seletedCategoryName;
    self.categoryLabel.text = _categoryName;
    
}



@end
