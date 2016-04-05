//
//  MHEvent.h
//  sportsBracelets
//
//  Created by dingyl on 14/12/23.
//
//

#import <Foundation/Foundation.h>


@interface MHEvent : NSObject

@property (nonatomic) int eventID;
@property (nonatomic, retain) NSString * iTitle;
@property (nonatomic, retain) NSDate * iDate;
@property (nonatomic, retain) NSString * iContent;

@end
