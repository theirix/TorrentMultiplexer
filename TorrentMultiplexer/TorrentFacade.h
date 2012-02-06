//
//  TorrentFacade.h
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#ifndef INC_TORRENTFACADE_H
#define INC_TORRENTFACADE_H

#if __cplusplus
extern "C" {
#endif
    
void nameForTorrent(const char* torrentFile, char** name);
    
#if __cplusplus
}   // Extern C
#endif

#endif