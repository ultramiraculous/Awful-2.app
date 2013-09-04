//
//  SAImageTextAttachment.h
//  Awful 2
//
//  Created by Chris Williams on 9/1/13.
//  Copyright (c) 2013 Awful Contributors. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UMAnimatedTextAttachment/UMAnimatedTextAttachment.h>

@interface SAImageTextAttachment : UMAnimatedTextAttachment

+(instancetype)attachmentWithURL:(NSURL*)url;

@end
