//
//  UMAnimatedTextAttachment.h
//  AnimatedTextAttachment
//
//  Created by Chris Williams on 9/1/13.
//

#import <UIKit/UIKit.h>

/**
 This block will give you a CGRect to work with
 and it will be used in the same context as a 
 drawRect: method in a UIView, but the rect
 represents the total area you are allowed to draw in
*/
typedef void (^UMDrawInRectBlock)(CGRect rect);

@interface UMAnimatedTextAttachment : NSTextAttachment

//Initialize the attachment with an image
- (instancetype)initWithImage:(UIImage*)image;

//Initialize the attachment with bounds
//Useful for attachments that will exclusively use drawBlock:
- (instancetype)initWithBounds:(CGRect)bounds;

//Cause the attachment to refresh its display using the given block
- (void)drawBlock:(UMDrawInRectBlock)drawblock;

@end
