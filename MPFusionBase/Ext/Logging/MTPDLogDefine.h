//
//  MTPDLogDefine.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#ifndef MPFusionBase_MTPDLogDefine_h
#define MPFusionBase_MTPDLogDefine_h

#ifndef __OPTIMIZE__
#   define DLog(fmt, ...) NSLog((@"%s [File %s: Line %d] " fmt), __PRETTY_FUNCTION__, __FILE__, __LINE__, ##__VA_ARGS__)
#   define ELog(err) {if(err) DLog(@"%@", err);}
#else
#   define DLog(...)
#endif

#endif
