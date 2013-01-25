//
//  iUpdate.h
//  iUpdate
//
//  Created by Gabriel Gino Vincent on 18/01/13.
//  Copyright (c) 2013 Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol iUpdateDelegate <NSObject>
@end

@interface iUpdate : NSObject <UIAlertViewDelegate> {
    NSString *releaseNotes;
}

+ (iUpdate *)sharedInstance;

@property (nonatomic, strong) UIViewController *delegate;
@property (nonatomic) NSUInteger appStoreID;
@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic, strong) NSString *updateButtonTitle;
@property (nonatomic, strong) NSString *closeButtonTitle;
@property (nonatomic, strong) NSURL *checkURL;
@property (nonatomic, strong) UIImage *blockedUIViewBackgroundImage;
@property (nonatomic) BOOL showReleaseNotes;

- (void)checkIfShouldBlockUI;
- (void)checkForUpdate;

@end
