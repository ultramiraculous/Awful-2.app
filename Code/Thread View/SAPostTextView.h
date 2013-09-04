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

@end

/**
 * The value of this attribute is a UIColor object. Use this attribute to specify the color of a thin vertical line to draw on the left of the paragraph.
 */
extern NSString * const SALeftBarColorAttributeName;

/**
 * The value of this attribute is an SAImageAttachment object.
 */
extern NSString * const SAImageAttachmentAttributeName;
