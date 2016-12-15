//
//  nineSister-Bridging-Header.h
//  nineSister
//
//  Created by 木柳 on 2016/12/15.
//  Copyright © 2016年 com.yundian. All rights reserved.
//


#import <OEZCommSDK/OEZCommSDK.h>

#pragma pack(1)
struct SocketPacketHead {
    UInt16 packet_length;
    UInt8 is_zip_encrypt;
    UInt8 type ;
    UInt16 signature;
    UInt16 operate_code;
    UInt16 data_length;
    UInt32 timestamp ;
    UInt64 session_id ;
    UInt32 request_id ;
};
#pragma pack()

#import <Qiniu/QiniuSDK.h>
#import <FMDB/FMDB.h>
#import <GTSDK/GeTuiSdk.h>
#import <UMMobClick/MobClick.h>

/* nineSister_Bridging_Header_h */
