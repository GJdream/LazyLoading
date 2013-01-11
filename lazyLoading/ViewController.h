//
//  ViewController.h
//  lazyLoading
//
//  Created by Salman Iftikhar on 08/01/2013.
//  Copyright (c) 2013 Salman Iftikhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"

@interface ViewController : UIViewController <ImageDownloaderDelegate>{
    NSMutableArray *recordUrl;
    NSMutableArray *recordImages;
    NSMutableArray *recordTitle;
    
    IBOutlet UITableView *musicTableView;
}

@end
