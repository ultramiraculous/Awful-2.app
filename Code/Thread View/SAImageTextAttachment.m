//
//  SAImageTextAttachment.m
//  Awful 2
//
//  Created by Chris Williams on 9/1/13.
//  Copyright (c) 2013 Awful Contributors. All rights reserved.
//

#import "SAImageTextAttachment.h"

#import <objc/runtime.h>

#import <AFNetworking/AFNetworking.h>

#import "UIImage+animatedGIF.h"



/**
 Alternate text attachment style for smiles that causes the smile 
 image height to match the height of the line of text
*/
@interface SASmileAttachment : SAImageTextAttachment

@end

@implementation SASmileAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
	CGRect superRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
	
	float height = CGRectGetHeight(lineFrag);
	float width = CGRectGetWidth(superRect) * height/CGRectGetHeight(superRect);
		
	return CGRectMake(CGRectGetMinX(superRect), CGRectGetMinY(superRect), width, height);
}

@end

@interface SAImageTextAttachment ()

@property (nonatomic, weak) NSLayoutManager *manager;
@property (nonatomic, assign) NSUInteger index;

@end


@implementation SAImageTextAttachment

+(instancetype)attachmentWithURL:(NSURL*)url
{
	//If the URL is a smile, use a SASmileAttachment instead
	if ([[url pathComponents] containsObject:@"emoticons"]){
		return [[SASmileAttachment alloc] initWithURL:url];
	}
	else{
		return [[self alloc] initWithURL:url];
	}
}

+(NSCache*)cache
{
	static NSCache *cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [NSCache new];
	});
	
	return cache;
}

- (instancetype)initWithURL:(NSURL*)url;
{
    if (!(self = [super init])) return nil;
	
	if ([[[self class] cache] objectForKey:url]) {
		
		UIImage *image = [[[self class] cache] objectForKey:url];
		
		self.image = image;
		
	}
	else{
		
		[[NSOperationQueue mainQueue] addOperation:[[AFHTTPClient client] HTTPRequestOperationWithRequest:[NSURLRequest requestWithURL:url]
														success:^(AFHTTPRequestOperation *operation, id responseObject) {
															
															UIImage *image = [UIImage animatedImageWithAnimatedGIFData:responseObject];
															
															self.image = image;
															
															[[[self class] cache] setObject:image forKey:url];
													   		
															[self.manager invalidateDisplayForCharacterRange:NSMakeRange(self.index, 1)];
															
														} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
															
															self.image = nil;
															
															
														}]];
	}
	

	
    return self;
}


- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
	_manager = textContainer.layoutManager;
	self.index = charIndex;
	
	if (self.image) {
		float width = MIN(lineFrag.size.width, self.image.size.width);
		float height = self.image.size.height * width/self.image.size.width;
		
		return CGRectMake(0, 0, width, height);
	}
	else{
		return CGRectZero;
	}

}

@end

