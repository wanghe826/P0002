//
//  FirmwareFileDownload.h
//  TWatch
//
//  Created by QFITS－iOS on 15/8/17.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FIRMWARE_NEW_VERSION_URL(snString,verString)  [NSString stringWithFormat:@"http://smartmovt.net/update-ver.php?sn=%@&ver=%@",snString,verString]

#define FIRMWARE_NEW_VERSION_LOG_URL(snString,verString) [NSString stringWithFormat:@"http://smartmovt.net/verlog.php?type=oat&sn=%@&ver=%@", snString, verString]


@interface FirmwareFileDownloadUtils : NSObject

+ (void)startDownloadFirmwareFromNet:(NSString*)urlStr withFileName:(NSString*)fileName downloadFinish:(void (^)()) completion;



+ (BOOL) isConnectionAvailable;

+ (BOOL) firmwareShouldUpdateToNewVersion:(NSString*)currentVersion remoteVersion:(NSString*)version2;

+ (void) downloadNewVersionFirmware:(NSString*)snString withVersion:(NSString*)version;

+ (void) unzipFile:(NSString*)filePath;
@end
