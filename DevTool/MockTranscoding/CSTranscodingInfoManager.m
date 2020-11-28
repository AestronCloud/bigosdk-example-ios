//
//  CSTranscodingInfoManager.m
//  cstore-example-ios
//
//  Created by 林小程 on 2020/9/27.
//  Copyright © 2020 bigo. All rights reserved.
//

#import "CSTranscodingInfoManager.h"
#import <CStoreMediaEngineKit/CStoreMediaEngineKit.h>
#import <objc/runtime.h>
#import "MJExtension.h"
#import "CSUtils.h"

static inline NSSet<NSString *> *PropertiesFromClass(Class cls) {
    static NSSet *NSObjectProperties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSObjectProperties = [NSMutableSet setWithArray:@[@"description", @"debugDescription", @"hash", @"superclass"]];
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList([NSObject class], &propertyCount);
        for (unsigned int i = 0; i < propertyCount; i++)
        {
            //get property name
            objc_property_t property = propertyList[i];
            const char *propertyName = property_getName(property);
            [(NSMutableSet *)NSObjectProperties addObject:@(propertyName)];
        }
        free(propertyList);
        NSObjectProperties = [NSObjectProperties copy];
    });
    
    NSMutableSet *properties = [NSMutableSet set];
    if (cls != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList(cls, &propertyCount);
        for (unsigned int i = 0; i < propertyCount; i++)
        {
            //get property name
            objc_property_t property = propertyList[i];
            const char *propertyName = property_getName(property);
            NSString *key = @(propertyName);
            
            //ignore NSObject properties, unless overridden as readwrite
            char *readonly = property_copyAttributeValue(property, "R");
            if (readonly)
            {
                free(readonly);
                if ([NSObjectProperties containsObject:key])
                {
                    continue;
                }
            }
            [properties addObject:@(propertyName)];
        }
        free(propertyList);
    }
    return properties;
}

static inline Class ClassOfPropertyNamed(NSObject *sourceObj, NSString* propertyName) {
    // Get Class of property to be populated.
    Class propertyClass = nil;
    objc_property_t property = class_getProperty([sourceObj class], [propertyName UTF8String]);
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    if (splitPropertyAttributes.count > 0)
    {
        // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        NSString *encodeType = splitPropertyAttributes[0];
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        if (splitEncodeType.count > 1) {
            NSString *className = splitEncodeType[1];
            propertyClass = NSClassFromString(className);
        }
    }
    return propertyClass;
}

static inline void CopyObject(NSObject *source, NSObject *dest, NSDictionary<NSString *, Class> *destArrClsDic) {
    NSMutableSet<NSString *> *props = [PropertiesFromClass([source class]) mutableCopy];
    [props intersectSet:PropertiesFromClass([dest class])];
    for (NSString *prop in props) {
        NSObject *sourceValue = [source valueForKey:prop];
        if (sourceValue == nil) {
            [dest setValue:nil forKey:prop];
            continue;
        }
        
        Class sourceValueClass = ClassOfPropertyNamed(source, prop);
        if ([sourceValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *destArr = [NSMutableArray array];
            for (NSObject *arrEleSource in (NSArray *)sourceValue) {
                Class cls = destArrClsDic[prop];
                if (!cls) {
                    abort();
                }
                NSObject *arrEleDest = [[cls alloc] init];
                CopyObject(arrEleSource, arrEleDest, nil);
                [destArr addObject:arrEleDest];
            }
            [dest setValue:destArr forKey:prop];
        } else {
            if (sourceValueClass && ![sourceValue isKindOfClass:[NSString class]]) {
                Class destValueClass = ClassOfPropertyNamed(dest, prop);
                NSObject *destValue = [[destValueClass alloc] init];
                CopyObject(sourceValue, destValue, nil);
                [dest setValue:destValue forKey:prop];
            } else {
                [dest setValue:sourceValue forKey:prop];
            }
        }
    }
}

@interface CSMTranscodingUserForm : NSObject<FXForm>

@property (nonatomic, assign) uint64_t uid;///<  旁路推流的用户 ID
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) uint8_t zOrder;

@end

@implementation CSMTranscodingUserForm
@synthesize rect = _rect;

- (NSString *)fieldDescription {
    return [NSString stringWithFormat:@"x:%d,y:%d,w:%d,h:%d", (int)self.x, (int)self.y, (int)self.width, (int)self.height];
}

- (NSArray *)excludedFields {
    return @[ @"rect" ];
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[ @"rect" ];
}

- (void)setX:(CGFloat)x {
    _x = x;
    [self generateRect];
}

- (void)setY:(CGFloat)y {
    _y = y;
    [self generateRect];
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    [self generateRect];
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    [self generateRect];
}

- (void)generateRect {
    _rect = CGRectMake(_x, _y, _width, _height);
}

- (void)setRect:(CGRect)rect {
    _rect = rect;
    _x = rect.origin.x;
    _y = rect.origin.y;
    _width = rect.size.width;
    _height = rect.size.height;
}

- (CGRect)rect {
    [self generateRect];
    return _rect;
}

@end

@interface CSMTranscodingImageForm : NSObject<FXForm>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign)CGRect rect;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation CSMTranscodingImageForm
@synthesize rect = _rect;

- (NSArray *)excludedFields {
    return @[ @"rect" ];
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[ @"rect" ];
}

- (void)setX:(CGFloat)x {
    _x = x;
    [self generateRect];
}

- (void)setY:(CGFloat)y {
    _y = y;
    [self generateRect];
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    [self generateRect];
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    [self generateRect];
}

- (void)generateRect {
    _rect = CGRectMake(_x, _y, _width, _height);
}

- (void)setRect:(CGRect)rect {
    _rect = rect;
    _x = rect.origin.x;
    _y = rect.origin.y;
    _width = rect.size.width;
    _height = rect.size.height;
}

- (CGRect)rect {
    [self generateRect];
    return _rect;
}

@end

@interface CSMLiveTranscodingForm : NSObject<FXForm>

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize size;
@property (nonatomic, assign) uint16_t videoBitrate;
@property (nonatomic, assign) uint8_t videoFramerate;
@property (nonatomic, assign) uint8_t videoGop;
@property (nonatomic, strong) NSArray<CSMTranscodingUserForm *> *transcodingUsers;
@property (nonatomic, strong) CSMTranscodingImageForm *backgroundImage;

@end

@implementation CSMLiveTranscodingForm
@synthesize size = _size;

- (NSArray *)excludedFields {
    return @[ @"size" ];
}

+ (NSArray *)mj_ignoredPropertyNames {
    return @[ @"size" ];
}

- (NSDictionary *)transcodingUsersField {
    return @{ FXFormFieldTemplate : @{ FXFormFieldClass: @"CSMTranscodingUserForm" }};
}

- (void)setSize:(CGSize)size {
    _size = size;
    _width = size.width;
    _height = size.height;
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    [self generateSize];
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    [self generateSize];
}

- (void)generateSize {
    _size = CGSizeMake(_width, _height);
}

- (CGSize)size {
    [self generateSize];
    return _size;
}

- (CSMLiveTranscoding *)toTranscoding {
    CSMLiveTranscoding *transcoding = [[CSMLiveTranscoding alloc] init];
    CopyObject(self, transcoding, @{ @"transcodingUsers" : [CSMTranscodingUser class] });
    return transcoding;
}

+ (instancetype)fromTranscodingInfo:(CSMLiveTranscoding *)transcoding {
    CSMLiveTranscodingForm *form = [[CSMLiveTranscodingForm alloc] init];
    CopyObject(transcoding, form, @{ @"transcodingUsers" : [CSMTranscodingUserForm class] });
    return form;
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{ @"transcodingUsers" : [CSMTranscodingUserForm class] };
}

@end

@interface CSTranscodingInfoManager ()

@property(nonatomic, strong)CSMLiveTranscodingForm *pkForm;
@property(nonatomic, strong)CSMLiveTranscodingForm *onMicForm;

@end

#define PKDefaultTranscodingFormKey @"PKDefaultTranscodingFormKey"
#define OnMicDefaultTranscodingFormKey @"OnMicDefaultTranscodingFormKey"
@implementation CSTranscodingInfoManager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)prepare {
    self.pkForm = [self defaultForm:YES];
    self.onMicForm = [self defaultForm:NO];
}

- (NSUInteger)transcodingUserCountInPk:(BOOL)isPK {
    return [self transcodingInPk:isPK].transcodingUsers.count;
}

- (CSMLiveTranscoding *)transcodingInPk:(BOOL)isPK withUids:(NSArray<NSNumber *> *)uids {
    CSMLiveTranscoding *transcoding = [self transcodingInPk:isPK];
    transcoding.transcodingUsers = [transcoding.transcodingUsers subarrayWithRange:NSMakeRange(0, MIN(uids.count, transcoding.transcodingUsers.count))];
    [transcoding.transcodingUsers enumerateObjectsUsingBlock:^(CSMTranscodingUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < uids.count) {
            obj.uid = uids[idx].unsignedLongLongValue;
        } else {
            *stop = YES;
        }
    }];
    return transcoding;
}

- (void)restoreDefaultTranscodingInPk:(BOOL)isPk {
    CSMLiveTranscoding *transcodingInfo = [self defaultTranscodingInPk:isPk];
    CSMLiveTranscodingForm *form = [CSMLiveTranscodingForm fromTranscodingInfo:transcodingInfo];
    [self saveTranscodingForm:form withKey:isPk ? PKDefaultTranscodingFormKey : OnMicDefaultTranscodingFormKey];
    [self prepare];
}

- (CSMLiveTranscoding *)transcodingInPk:(BOOL)isPK {
    if (isPK) {
        return [self.pkForm toTranscoding];
    } else {
        return [self.onMicForm toTranscoding];;
    }
}

- (void)saveTranscodingForm:(CSMLiveTranscodingForm *)form withKey:(NSString *)key {
    NSData *data = [form mj_JSONData];
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CSMLiveTranscodingForm *)defaultForm:(BOOL)isPK {
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:isPK ? PKDefaultTranscodingFormKey : OnMicDefaultTranscodingFormKey];
    if (data) {
        return [CSMLiveTranscodingForm mj_objectWithKeyValues:data];
    } else {
        CSMLiveTranscoding *transcodingInfo = [self defaultTranscodingInPk:isPK];
        return [CSMLiveTranscodingForm fromTranscodingInfo:transcodingInfo];
    }
}

- (CSMLiveTranscoding *)defaultTranscodingInPk:(BOOL)isPK {
    CSMLiveTranscoding *transcodingInfo = [[CSMLiveTranscoding alloc] init];
    transcodingInfo.size = CGSizeMake(540, 960);
    transcodingInfo.videoBitrate = 1400;
    transcodingInfo.videoFramerate = 30;
    transcodingInfo.videoGop = 30;
    transcodingInfo.backgroundImage = [[CSMTranscodingImage alloc] init];
    transcodingInfo.backgroundImage.url = @"https://www.cleverfiles.com/howto/wp-content/uploads/2018/03/minion.jpg";
    transcodingInfo.backgroundImage.rect = CGRectMake(0, 0, 200, 100);
    
    if (isPK) {
        //左右布局
        CGFloat videoW = (1.0f / 2.0f) * transcodingInfo.size.width;
        CGFloat videoH = videoW * (transcodingInfo.size.height / transcodingInfo.size.width);
        CSMTranscodingUser *transcodingUser = [[CSMTranscodingUser alloc] init];
        transcodingUser.rect = CGRectMake(0, 0, videoW, videoH);
        transcodingUser.zOrder = 0;
        
        CSMTranscodingUser *transcodingUser1 = [[CSMTranscodingUser alloc] init];
        transcodingUser1.rect = CGRectMake(videoW, 0, videoW, videoH);
        transcodingUser1.zOrder = 1;
        
        transcodingInfo.transcodingUsers = @[ transcodingUser, transcodingUser1 ];
    } else {
        //大小窗布局
        CGFloat videoW = transcodingInfo.size.width;
        CGFloat videoH = transcodingInfo.size.height;
        CGFloat smallWindowWidth = videoW / 3;
        CGFloat smallWindowHeight = smallWindowWidth / 9 * 16; //视频比例16:9
        
        CSMTranscodingUser *transcodingUser = [[CSMTranscodingUser alloc] init];
        transcodingUser.rect = CGRectMake(0, 0, videoW, videoH);
        transcodingUser.zOrder = 0;
        
        CSMTranscodingUser *transcodingUser1 = [[CSMTranscodingUser alloc] init];
        transcodingUser1.rect = CGRectMake(videoW - smallWindowWidth, videoH - 50 - smallWindowHeight, smallWindowWidth, smallWindowHeight);
        transcodingUser1.zOrder = 1;
        
        CSMTranscodingUser *transcodingUser2 = [[CSMTranscodingUser alloc] init];
        transcodingUser2.rect = CGRectMake(videoW - smallWindowWidth, videoH - 50 - 2 * smallWindowHeight, smallWindowWidth, smallWindowHeight);
        transcodingUser2.zOrder = 2;
        
        transcodingInfo.transcodingUsers = @[ transcodingUser, transcodingUser1, transcodingUser2 ];
    }
    return transcodingInfo;
}

@end

@interface CSModiTranscodingFormController ()

@property(nonatomic, assign)BOOL isPk;

@end

@implementation CSModiTranscodingFormController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isPk) {
        [[CSTranscodingInfoManager sharedInstance] saveTranscodingForm:[CSTranscodingInfoManager sharedInstance].pkForm  withKey:PKDefaultTranscodingFormKey];
    } else {
        [[CSTranscodingInfoManager sharedInstance] saveTranscodingForm:[CSTranscodingInfoManager sharedInstance].onMicForm withKey:OnMicDefaultTranscodingFormKey];
    }
}

+ (CSModiTranscodingFormController *)formControllerWithPkOrMic:(BOOL)isPK {
    CSModiTranscodingFormController *controller = [[CSModiTranscodingFormController alloc] init];
    controller.isPk = isPK;
    if (isPK) {
        controller.formController.form = [CSTranscodingInfoManager sharedInstance].pkForm;
    } else {
        controller.formController.form = [CSTranscodingInfoManager sharedInstance].onMicForm;
    }
    
    return controller;
}

@end
