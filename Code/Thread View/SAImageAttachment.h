//
//  SAImageAttachment.h
//  Awful 2
//
//  Created by Nolan Waite on 2013-08-31.
//  Copyright (c) 2013 Awful Contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An SAImageAttachment is the value for SAImageAttachmentAttributeName in NSAttributedString objects. It represents a possibly unavailable image.
 */
@interface SAImageAttachment : NSObject

/**
 * Returns an initialized SAImageAttachment with a URL.
 */
- (id)initWithURL:(NSURL *)URL;

/**
 * The URL for the attached image.
 */
@property (readonly, strong, nonatomic) NSURL *URL;

/**
 * The attached image.
 */
@property (strong, nonatomic) UIImage *image;

@end
