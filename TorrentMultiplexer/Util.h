//
//  Util.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 07.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const APPId;

extern NSString * const PREFAppTorrent;
extern NSString * const PREFAppMagnet;
extern NSString * const PREFMaskQuark;
extern NSString * const PREFMaskAtom;

@interface Util : NSObject

+ (void)makeError:(NSString*)description  error:(NSError**)outError;
+ (void)checkError:(OSStatus)status withResponder:(NSResponder*)responder;
+ (void)makeErrorFromStatus:(OSStatus)status error:(NSError**)outError;

@end
