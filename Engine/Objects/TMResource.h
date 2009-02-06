//
//  TMResource.h
//  TapMania
//
//  Created by Alex Kremer on 06.02.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMResource : NSObject {
	NSObject*		m_pResource;			
	NSString*		m_sResourceName;		// The name (eg. '_TapNote_8x8.png' becomes 'TapNote')
	int				m_nCols, m_nRows;		// For framed textures and animations
	
	NSString*		m_sFileSystemPath;		// The path to the real file
	Class			m_oClass;				// The class which should be used to construct the resource
	
	BOOL			m_bIsLoaded;
}

@property (readonly, getter=resource, retain) NSObject* m_pResource;
@property (readonly, getter=componentName, retain) NSString* m_sResourceName;

/* The constructor. It only loads up information about the resource. Eg. it sets the m_sFileSystemPath and the m_idClass */
- (id) initWithPath:(NSString*) path andItemName:(NSString*) itemName;

- (void) loadResource;		// Will actually load the resource into memory (GPU)
- (void) unLoadResource;	// Will release m_pResource

@end
