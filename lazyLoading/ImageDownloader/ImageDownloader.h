//
//  ViewController.m
//
//

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject {
    id <ImageDownloaderDelegate> delegate;
    NSString *imageURLString;
    UIImage *downloadedImage;
    NSIndexPath *indexPathInTableView;
    
    //NSMutableData *activeDownload;
    //NSURLConnection *imageConnection;
}

@property(nonatomic, strong) id <ImageDownloaderDelegate> delegate;
@property(nonatomic, retain) NSIndexPath *indexPathInTableView;
@property(nonatomic, retain) UIImage *downloadedImage;
@property(nonatomic, retain) NSString *imageURLString;

//@property(nonatomic, retain) NSMutableData *activeDownload;
//@property(nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

- (void)startUsingSIKHttpRequest;
- (void)cancelUsingSIKHttpRequest;

//- (void)startUsingNativeRequest;
//- (void)cancelUsingNativeRequest;

@end

@protocol ImageDownloaderDelegate

- (void)imageDidLoad:(NSIndexPath *)indexPath withImage:(UIImage *)downloadedImage;

@end