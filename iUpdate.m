//
//  iUpdate.m
//  iUpdate
//
//  Created by Gabriel Gino Vincent on 18/01/13.
//  Copyright (c) 2013 Sync. All rights reserved.
//

#define LookUpURL @"http://itunes.apple.com/lookup?id="
#define Close 0
#define Update 1

#import "iUpdate.h"

@implementation iUpdate

#pragma mark Singleton methods

static iUpdate *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (iUpdate *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        // Work your initialising magic here as you normally would
        
        // Default configuration
        
        self.appStoreID = 0;
        self.alertTitle = @"An update to this app is available";
        self.alertMessage = @"Update now and keep enjoying this great app!";
        self.updateButtonTitle = @"Update";
        self.closeButtonTitle = @"Not now";
        self.blockedUIViewBackgroundImage = nil;
    }
    
    return self;
}

#pragma mark Implementation

- (NSString *) simplifiedVersionString:(NSString *)stringToBeSimplified {
    
    NSArray *stringComponents = [stringToBeSimplified componentsSeparatedByString:@"."];
    
    for (int i = 0; i < [stringComponents count]; i++) {
        
        if (i == 0)
            stringToBeSimplified = [NSString stringWithFormat:@"%@.", stringComponents[0]];
        else
            stringToBeSimplified = [NSString stringWithFormat:@"%@%@",stringToBeSimplified, stringComponents[i]];
    }
    
    return stringToBeSimplified;
}

- (void) blockUI {
    NSLog(@"UI is blocked");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect deviceScreenSize = [[UIScreen mainScreen] bounds];
        
        UIView *blockView = [[UIView alloc] initWithFrame:deviceScreenSize];
        UIViewController *blockUIViewController = [[UIViewController alloc] init];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:self.blockedUIViewBackgroundImage];
        
        backgroundImageView.bounds = blockView.bounds;
        [blockView addSubview:backgroundImageView];
        blockUIViewController.view = blockView;
        
        [self.delegate presentViewController:blockUIViewController animated:YES completion:^{
            
        }];
        
    });
}

- (void) goToAppStore {
    
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%i?&mt=8", self.appStoreID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void) showUpdateAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *message;
        
        if (self.showReleaseNotes)
            message = releaseNotes;
        else
            message = self.alertMessage;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.alertTitle message:message delegate:self cancelButtonTitle:self.closeButtonTitle otherButtonTitles:self.updateButtonTitle, nil];
        [alert show];
        
    });
}

- (void)checkForUpdate {
    
    NSString *urlString = [NSString stringWithFormat:@"%@", self.checkURL];
    urlString = [urlString stringByAppendingFormat:@"?appStoreID=%u", self.appStoreID];
    urlString = [urlString stringByAppendingFormat:@"&releaseNotes=%d", self.showReleaseNotes];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:8.0];
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
            
            NSLog(@"JSONObject: %@", jsonObject);
            
            NSString *appVersionString = [infoDict objectForKey:@"CFBundleShortVersionString"];
            NSString *appStoreVersionString = [jsonObject objectForKey:@"version"];
            BOOL shouldBlockUI = [[jsonObject objectForKey:@"block_ui"] boolValue];
            
            if (self.showReleaseNotes)
                releaseNotes = [jsonObject objectForKey:@"release_notes"];
            
            float appVersion = [[self simplifiedVersionString:appVersionString] floatValue];
            float appStoreVersion = [[self simplifiedVersionString:appStoreVersionString] floatValue];
            
            if (appStoreVersion > appVersion) {
                NSLog(@"An update is available");
                
                [self showUpdateAlert];
                
                if (shouldBlockUI)
                    [self blockUI];
                
            }
            else {
                NSLog(@"App is up to date");
            }
        });
    }];
    
}

#pragma mark UIAlertView delegate methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Index: %d", buttonIndex);
    
    if (buttonIndex == Update)
        [self goToAppStore];
}

@end
