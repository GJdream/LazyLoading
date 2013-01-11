//
//  ViewController.m
//
//

#import "ImageDownloader.h"
#import "SIKHttpRequest.h"

#define kAppIconHeight 48

@implementation ImageDownloader

SIKHttpRequest *SIKRequest;

@synthesize downloadedImage;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize imageURLString;

//@synthesize activeDownload;
//@synthesize imageConnection;

#pragma mark - Start - Cancel HttpRequest

- (void)startDownload {
    [self startUsingSIKHttpRequest];
    //[self startUsingNativeRequest];
}

- (void)cancelDownload {
    [self cancelUsingSIKHttpRequest];
    //[self cancelUsingNativeRequest];
}

#pragma mark - SIKHttpRequest Events

- (void)startUsingSIKHttpRequest {
    SIKRequest = [[SIKHttpRequest alloc] requestWithString:self.imageURLString withDelegate:self];
    [SIKRequest setDidFinishSelector:@selector(serverRequestSuccessWith:)];
    [SIKRequest setDidFailSelector:@selector(serverRequestFailureWith:)];
    [SIKRequest sendSynchronous];
    SIKRequest = nil;
}

- (void)cancelUsingSIKHttpRequest {
    [SIKRequest cancelRequest];
}

- (void)serverRequestSuccessWith:(SIKHttpResponse *)response {
    
    UIImage *image = [[UIImage alloc] initWithData:[response responseData]];
    
    if(image.size.width != kAppIconHeight && image.size.height != kAppIconHeight) {
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.downloadedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else {
        self.downloadedImage = image;
    }
    
    // Call our delegate and tell it that our icon is ready for display
    [delegate imageDidLoad:self.indexPathInTableView withImage:self.downloadedImage];
}

- (void)serverRequestFailureWith:(NSError *)error{
    [delegate imageDidLoad:self.indexPathInTableView withImage:nil];
}

/*

#pragma mark - NSURLConnection events

- (void)startUsingNativeRequest {
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURLString]] delegate:self];
    
    self.imageConnection = conn;
    conn = nil;
}

- (void)cancelUsingNativeRequest {
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if(image.size.width != kAppIconHeight && image.size.height != kAppIconHeight) {
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.downloadedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else {
        self.downloadedImage = image;
    }
    
    self.activeDownload = nil;
    image = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // Call our delegate and tell it that our icon is ready for display
    [delegate imageDidLoad:self.indexPathInTableView withImage:self.downloadedImage];
}

*/

@end

