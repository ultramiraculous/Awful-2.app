//
//  SAPostTextView.h
//  Awful 2
//
//  Created by Nolan Waite on 2013-08-30.
//

#import <UIKit/UIKit.h>

/**
 * An SAPostTextView handles custom attributes unknown to a standard UITextView.
 */
@interface SAPostTextView : UITextView

/**
 * Returns an array of NSURL objects of image attachments whose image size is unkown.
 */
- (NSArray *)missingImageAttachmentURLs;

/**
 * Sets an image for all image attachments with the URL. This method may cause the text view to re-layout.
 *
 * @param image The image to use.
 * @param attachmentURL The URL of the image as returned by -missingImageAttachmentURLs.
 */
- (void)setImage:(UIImage *)image forImageAttachmentWithURL:(NSURL *)attachmentURL;

@end

/**
 * The value of this attribute is a UIColor object. Use this attribute to specify the color of a thin vertical line to draw on the left of the paragraph.
 */
extern NSString * const SALeftBarColorAttributeName;

/**
 * The value of this attribute is an SAImageAttachment object.
 */
extern NSString * const SAImageAttachmentAttributeName;
