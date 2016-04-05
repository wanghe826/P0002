//
//  FirmwareFileDownload.m
//  TWatch
//
//  Created by QFITS－iOS on 15/8/17.
//  Copyright (c) 2015年 ZeroSoft. All rights reserved.
//

#import "FirmwareFileDownloadUtils.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"

#import "Reachability.h"
#import "ZipArchive.h"
#import "UserDefaultsUtils.h"

@implementation FirmwareFileDownloadUtils

static dispatch_once_t once_token;

+ (void)startDownloadFirmwareFromNet:(NSString*)urlStr withFileName:(NSString*)fileName downloadFinish:(void (^)()) completion
{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(data){
        NSString* documents = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
        NSString* file = [documents stringByAppendingString:fileName];
        NSLog(@"ffffffile-> %@", file);
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:file]){
            if([data writeToFile:file atomically:YES])
            {
                //文件保存成功
                completion();
                NSLog(@"文件保存成功");
            }else{
                //文件保存失败
                NSLog(@"文件保存失败");
            }
        }else{
            completion();
        }
        
    }else{
        //文件下载失败
        NSLog(@"文件下载失败");
    }
}


+ (BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}

+ (BOOL) firmwareShouldUpdateToNewVersion:(NSString*)currentVersion remoteVersion:(NSString*)version2
{
    if(currentVersion.length<6 || version2.length<6)
    {
        return NO;
    }
    
    if(currentVersion==nil|| version2==nil)
    {
        return NO;
    }
    
    if([currentVersion isEqualToString:version2])
    {
        return NO;
    }
    //@"       C.TB.1.1.5.12.cyacd"
    //@"C.TB.1.1.4.11.cyacd"
    
    //    NSRange rangeOfCyacd = [curr]
    
    NSUInteger currentLength = currentVersion.length;
    NSUInteger verison2Length = version2.length;
    
    NSString* ver1 = [currentVersion substringFromIndex:currentLength-6];
    NSString* ver2 = [version2 substringFromIndex:verison2Length-6];
    switch ([ver1 compare:ver2])
    {
        case NSOrderedSame:
            return NO;
        case NSOrderedDescending:
            return NO;
        case NSOrderedAscending:
            return YES;
        default:
            break;
    }
    
    return NO;
}


+ (void) downloadNewVersionFirmware:(NSString*)snString withVersion:(NSString*)version
{
    NSString* logUrlString = FIRMWARE_NEW_VERSION_LOG_URL(snString, [[version substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""]);
//    http://smartmovt.net/update-ver.php?sn=P0002&ver=v1.1.0
    NSLog(@"logUrlString----> %@", logUrlString);
    NSURL* logUrl = [NSURL URLWithString:logUrlString];
    NSError* logError;
    NSString* log = [NSString stringWithContentsOfURL:logUrl encoding:NSUTF8StringEncoding error:&logError];
    if(!logError) NSLog(@"-----更新日志是:%@", log);
    else    NSLog(@"===%@", logError);
    ApplicationDelegate->_firmwareUpgradeLog = log;
    
    
    NSString* urlString = FIRMWARE_NEW_VERSION_URL(snString, version);

    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL* fileUrl = [NSURL URLWithString:urlString];
    NSError* error;
    
    NSLog(@"文件更新地址shishsihs-----》 %@", fileUrl);
    if(!fileUrl)
    {
        return;
    }
    NSData* data = [NSData dataWithContentsOfURL:fileUrl options:0 error:&error];
    if(!data)
    {
        NSLog(@"-----> 下载的错误代码是: %@", error);
        return;
    }
    
    NSString* retString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(retString)
    {
        if([retString isEqualToString:@"no"])
        {
            NSLog(@"没有新版本");
            return;
        }
    }
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error){
                                                        if(!error)
                                                        {
                                                            NSData* data = [NSData dataWithContentsOfURL:location];
                                                            NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:response.suggestedFilename];
                                                            NSLog(@"文件路径事实上司是----> %@", filePath);
                                                            NSFileManager* fileManager = [NSFileManager defaultManager];
                                                            if([fileManager fileExistsAtPath:filePath])
                                                            {
                                                                //                                                                ApplicationDelegate.upgradeFileName = filePath;
                                                                [FirmwareFileDownloadUtils unzipFile:filePath];
                                                                NSLog(@"已经存在该文件");
                                                            }
                                                            else
                                                            {
                                                                if(data)
                                                                {
                                                                    if([data writeToFile:filePath atomically:YES])
                                                                    {
                                                                        NSLog(@"下载并写入该文件成功");
                                                                        [FirmwareFileDownloadUtils unzipFile:filePath];
                                                                    }
                                                                    else
                                                                    {
                                                                        NSLog(@"写入文件不成功");
                                                                    }
                                                                    
                                                                    
                                                                }
                                                                else
                                                                {
                                                                    NSLog(@"ddddd-->为空");
                                                                }
                                                            }
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"下载失败哦error--->%@", error);
                                                        }
                                                        
                                                    }];
    [task resume];
    return ;
}

+ (void) unzipFile:(NSString *)filePath{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile: filePath]) {
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        BOOL ret = [za UnzipFileTo: path overWrite: YES];
        if (NO == ret){
            NSLog(@"解压失败");
        }else{
            
            NSString* zipSuffix = [filePath substringFromIndex:filePath.length-4];
            NSRange range = [filePath rangeOfString:zipSuffix];
            NSString* dicOfBinAndCheckfile = [filePath substringWithRange:NSMakeRange(0, range.location)];
            NSArray* allFiles = [fileManager contentsOfDirectoryAtPath:dicOfBinAndCheckfile error:nil];
            for(NSString* str in allFiles)
            {
                NSString* lastFileComponent = [[str componentsSeparatedByString:@"."] lastObject];
                NSLog(@"----lastFileComponent--->%@", lastFileComponent);
                if([lastFileComponent isEqualToString:@"bin"])
                {
                    ApplicationDelegate.upgradeFileName = [dicOfBinAndCheckfile stringByAppendingPathComponent:str];
                }
                
                if([lastFileComponent isEqualToString:@"chk"])
                {
                    ApplicationDelegate.upgradeChkFileName = [dicOfBinAndCheckfile stringByAppendingPathComponent:str];
                }
            }
            
            
            if(!ApplicationDelegate.upgradeChkFileName || !ApplicationDelegate.upgradeFileName || ![fileManager fileExistsAtPath:ApplicationDelegate.upgradeChkFileName isDirectory:nil] || ![fileManager fileExistsAtPath:ApplicationDelegate.upgradeFileName isDirectory:nil])
            {
                NSArray* documentsAllFiles = [fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
                for(NSString* str in documentsAllFiles)
                {
                    NSLog(@"里面的文件是---> %@", str);
                    NSString* lastFileComponent = [[str componentsSeparatedByString:@"."] lastObject];
                    if([lastFileComponent isEqualToString:@"bin"])
                    {
                        ApplicationDelegate.upgradeFileName = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:str];
                    }
                    if([lastFileComponent isEqualToString:@"chk"])
                    {
                        ApplicationDelegate.upgradeChkFileName = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:str];
                    }
                }
            }
            
            if(!ApplicationDelegate.upgradeChkFileName || !ApplicationDelegate.upgradeFileName)
            {
                for(NSString* str in [fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil])
                {
                    NSError* error;
                    NSString* dicPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:str];
                    
                    NSLog(@"---d-d-d-d-d->%@", str);
                    
                    NSArray* contentFiles = [fileManager contentsOfDirectoryAtPath:dicPath error:&error];
                    NSLog(@"错误是--> %@", error);
                    
                    if(!error)
                    {
                        for(NSString* str in contentFiles)
                        {
                            NSLog(@"wenjianannana--->%@", str);
                            NSString* lastFileComponent = [[str componentsSeparatedByString:@"."] lastObject];
                            if([lastFileComponent isEqualToString:@"bin"])
                            {
                                ApplicationDelegate.upgradeFileName = [dicPath stringByAppendingPathComponent:str];
                            }
                            if([lastFileComponent isEqualToString:@"chk"])
                            {
                                ApplicationDelegate.upgradeChkFileName = [dicPath stringByAppendingPathComponent:str];
                            }
                        }
                    }
                    
                }
            }
            
            NSLog(@"-----zipSuffix---> %@", zipSuffix);
            NSLog(@"-----dicOfBinAnd----> %@", dicOfBinAndCheckfile);
            NSLog(@"-----bin---->%@", ApplicationDelegate.upgradeFileName);
            NSLog(@"-----chk---->%@", ApplicationDelegate.upgradeChkFileName);
        }
        [za UnzipCloseFile];
        
        if(!ApplicationDelegate.isOnFirmwareUpgrade && ApplicationDelegate.upgradeChkFileName && ApplicationDelegate.upgradeFileName)
        {
            //               [ApplicationDelegate performSelectorOnMainThread:@selector(alertNewFirmwareVersion) withObject:nil waitUntilDone:YES];
            
            dispatch_once(&once_token, ^{
//                if(![UserDefaultsUtils boolValueWithKey:FirstTimeLogin])
//                {
//                    
//                }
                
                sleep(25);
                
                while (true) {
                    if(ApplicationDelegate.functionVc)
                    {
                        JGBLEManager* manager = [JGBLEManager sharedManager];
                        if(manager->_hasReadytoDownloadSportData || (manager.sportModelsBuffer && manager.sportModelsBuffer.count!=0))
                        {
                            return ;
                        }
                        
                       [ApplicationDelegate performSelectorOnMainThread:@selector(alertNewFirmwareVersion) withObject:nil waitUntilDone:YES];
                        return ;
                    }
                    sleep(1);
                }
                
            });
        }
    }
}

@end
