//
//  TorrentFacade.cpp
//  TorrentMultiplexer
//
//  Created by Eugene Seliverstov on 06.02.2012.
//  Copyright (c) 2012 MSTU-RK6. All rights reserved.
//

#import <libtorrent/torrent/download.h>
#include "TorrentFacade.h"

#if __cplusplus
extern "C" {
#endif
    
void nameForTorrent(const char* torrentFile, char** name)
{
    torrent::Download* pDownload = new torrent::Download();
}


#if __cplusplus
}   // Extern C
#endif
