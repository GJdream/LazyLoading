//
//  ViewController.m
//  lazyLoading
//
//  Created by Salman Iftikhar on 08/01/2013.
//  Copyright (c) 2013 Salman Iftikhar. All rights reserved.
//

#import "ViewController.h"
#import "SIKHttpRequest.h"
#import "ImageDownloader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    recordUrl = [[NSMutableArray alloc]init];
    recordTitle = [[NSMutableArray alloc]init];
    recordImages = [[NSMutableArray alloc]init];
    //imageDownloadedDict = [[NSMutableDictionary alloc]init];
    
    [self performSelector:@selector(sendCall) withObject:nil afterDelay:0.2];
}

-(void)sendCall{
    NSString *urlString = @"https://m.hmv.com/api/products/hot/music/";
    
    SIKHttpRequest *request = [[SIKHttpRequest alloc] requestWithString:urlString withDelegate:self];
    [request setDidFinishSelector:@selector(serverRequestSuccessWith:)];
    [request setDidFailSelector:@selector(serverRequestFailureWith:)];
    [request sendSynchronous];
    request = nil;
}

- (void)didReceiveMemoryWarning
{
    recordTitle = nil;
    recordUrl = nil;
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)serverRequestSuccessWith:(SIKHttpResponse *)response {
    
    NSArray *records = [[NSJSONSerialization JSONObjectWithData:[response responseData]  options: NSJSONReadingMutableContainers error:nil] objectForKey:@"records"];
    
    for(int i = 0; i < [records count]; i++) {
        NSDictionary *record = [records objectAtIndex:i];
        
        [recordTitle addObject:[record objectForKey:@"title"]];
        [recordUrl addObject:[record objectForKey:@"thumbnailURL"]];
    }
    
    for (int i = 0 ; i < [recordTitle count]; i++) {
        [recordImages addObject:@""];
    }
    
    [musicTableView reloadData];
}

- (void)serverRequestFailureWith:(NSError *)error{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%d",[error code]] message: [error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    alert = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return recordTitle != nil ? [recordTitle count] : 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:16.0]];
    }
    
    if([recordImages objectAtIndex:indexPath.row] == @"") {
        if (tableView.dragging == NO && tableView.decelerating == NO) {
            [self startImageDownload:[recordUrl objectAtIndex:indexPath.row] forIndexPath:indexPath];
        }
        
        // If a download is deferred or in progress, return a placeholder image
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    else {
        [cell.imageView setImage:[recordImages objectAtIndex:indexPath.row]];
    }
    
    cell.textLabel.text = [recordTitle objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark Table cell image support
- (void)startImageDownload:(NSString *)urlString forIndexPath:(NSIndexPath *)indexPath {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] init];
    
    imageDownloader.delegate = self;
    imageDownloader.indexPathInTableView = indexPath;
    imageDownloader.imageURLString = urlString;
    [imageDownloader startDownload];
    
    imageDownloader = nil;
}

// Called by our ImageDownloader when an image is ready to be displayed
- (void)imageDidLoad:(NSIndexPath *)indexPath withImage:(UIImage *)downloadedImage {
    
    if(downloadedImage != nil) {
        [recordImages replaceObjectAtIndex:indexPath.row withObject:downloadedImage];
        
        //UITableViewCell *cell = [musicTableView cellForRowAtIndexPath:imageDownloader.indexPathInTableView];
        //[cell.imageView setImage:[recordImages objectAtIndex:indexPath.row]];
        
        [musicTableView reloadData];
        NSLog(@"Downloaded Images %i",indexPath.row + 1);
    }
}


#pragma mark Deferred image loading (UIScrollViewDelegate)
// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self loadImagesForVisibleRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForVisibleRows];
}

// This method is used in case the user scrolled into a set of cells that don't have their images icons yet
- (void)loadImagesForVisibleRows {
    NSArray *visiblePaths = [musicTableView indexPathsForVisibleRows];
    
    for(NSIndexPath *indexPath in visiblePaths) {
        if([recordImages objectAtIndex:indexPath.row] == @"") {
            [self startImageDownload:[recordUrl objectAtIndex:indexPath.row] forIndexPath:indexPath];
        }
    }
}


@end
