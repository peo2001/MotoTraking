//
//  mtxImageManager.m
//  RaceTracking
//
//  Created by Eugenio Pompei on 23/05/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxImageManager.h"
#import "RemoteConnectorParameters.h"

@implementation mtxImageManager

+(void) loadRolesImage: (NSMutableArray *) ruoliPrevisti{
    
    for (NSString *aRuolo in ruoliPrevisti) {
        [self loadPngImage:[NSString stringWithFormat:@"Pin_%@", aRuolo] fromPath:@"Ruoli"];
    }
}

+(UIImage *) getRoleImage: (NSString *)codRuolo{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/Pin_%@.png",docDir,codRuolo];
	return [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:pngFilePath]];
    
}

+(void) loadPngImage: (NSString *) imageName fromPath:(NSString *) imagePath{
	// Get an image from the URL below
    NSString *imgUrl = [NSString stringWithFormat:@"%@img/%@/%@.png", remoteServerURL, imagePath, imageName];
    NSLog(@"Downloading image %@", imgUrl);
    
	UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
    
	//NSLog(@"%f,%f",image.size.width,image.size.height);
    
	// Let's save the file into Document folder.
	// You can also change this to your desktop for testing. (e.g. /Users/kiichi/Desktop/)
	// NSString *deskTopDir = @"/Users/kiichi/Desktop";
    
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir,imageName];
    
	// If you go to the folder below, you will find those pictures
	//NSLog(@"saving png at %@",pngFilePath);

	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
	[data1 writeToFile:pngFilePath atomically:YES];
    
    /*
	NSLog(@"saving jpeg");
	NSString *jpegFilePath = [NSString stringWithFormat:@"%@/test.jpeg",docDir];
	NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
	[data2 writeToFile:jpegFilePath atomically:YES];
    */
    
	//NSLog(@"saving image done");
     
}
@end
