//
//  CStoreMediaEngineCoreDelegate.h
//  CStoreEngineKit
//
//  Created by Caimu Yang on 2019/8/20.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#ifndef CStoreMediaEngineCoreDelegate_h
#define CStoreMediaEngineCoreDelegate_h

#import <UIKit/UIKit.h>
#import "CStoreMediaEngineCoreEnums.h"

@class CStoreMediaEngineCore;
@class CSMChannelMicUser;

/**
CStoreMediaEngineCoreDelegate 接口类采用 Delegate 方法用于向 App 发送回调通知。

*/
@protocol CStoreMediaEngineCoreDelegate <NSObject>

@optional

#pragma mark - Core

/**
 SDK 运行时出现了媒体相关的错误
 
  @param mediaEngine CStoreMediaEngineCore对象
 @param errorCode 错误码
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didOccurError:(int32_t)errorCode;

/**
 用户角色发生变化
 
 在房间内调用 [CStoreMediaEngineCore setClientRole:] 进行上下麦操作会触发用户角色的变化，包括下面三种情况:
 
 1. 首次以主播身份进房
 2. 以观众角色调用 [CStoreMediaEngineCore setClientRole:] 在房间内上麦
 3. 麦上用户调用 [CStoreMediaEngineCore setClientRole:] 在房间内下麦
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param oldRole 原来的角色
 @param newRole 现在的角色
 @param clientRoleInfo 麦上用户信息
 @param channelName 频道名称
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didClientRoleChanged:(CSMClientRole)oldRole newRole:(CSMClientRole)newRole clientRoleInfo:(CSMChannelMicUser *)clientRoleInfo channelName:(NSString *)channelName;

/**
 有用户上麦，房间内的观众和主播会收到该回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param user 上麦的用户信息
 @param elapsed 时长
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userJoined:(CSMChannelMicUser *)user elapsed:(NSInteger)elapsed;

/**
 有用户下麦，房间内的观众观众和主播会收到该回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param user 上麦的用户信息
 @param reason 下麦原因
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine userOffline:(CSMChannelMicUser *)user reason:(int)reason;

/**
 媒体连接状态发生变化
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param state 媒体连接状态 CSMConnectionStateType
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine connectionChangedToState:(CSMConnectionStateType)state;

/**
 进入房间的所携带的token存在过期时间，当离过期时间还有30s的时候触发该回调
 
 此时你应该更新最新的token并通过调用 [CStoreMediaEngineCore renewToken:] 给sdk
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param token 过期token
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine tokenPrivilegeWillExpire:(NSString *)token;

/**
 token已经过期，发出通知
 此时你应该更新最新的token并通过调用 [CStoreMediaEngineCore renewToken:] 给sdk
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param token 过期token
 
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine tokenPrivilegeExpired:(NSString *)token;

/**
 网络类型发生变化
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param type 网络类型 CSMNetworkType
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine networkTypeChangedToType:(CSMNetworkType)type;

/**
 被踢出频道回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param reason 被踢原因 CSMKickReason
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine kicked:(CSMKickReason)reason;

#pragma mark - Media

// Audio

/**
 打开麦克风通知
 @param mediaEngine CStoreMediaEngineCore对象
 @param enabled 是否打开麦克风，YES：打开，NO：关闭
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didMicrophoneEnabled:(BOOL)enabled;

/**
 当前麦上用户的说话状态回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uids 该房间内正在发言的人
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine speakerChanged:(NSArray<NSNumber *> *)uids;

/**
 收到远端麦上用户为uid的用户的音频首包回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uid  收到首包音频的uid
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteAudioPkgReceived:(uint64_t)uid;

/**
 远端麦上用户为uid的用户的音频频首帧回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uid  收到首帧音频的uid
 @param elapsed 耗时
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteAudioFrameOfUid:(uint64_t)uid elapsed:(NSInteger)elapsed;

/**
 远端麦上用户为uid的用户的音频首帧解码回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uid  收到首帧解码的uid
 @param elapsed 耗时
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteAudioFrameDecodedOfUid:(uint64_t)uid elapsed:(NSInteger)elapsed;

/**
 麦上用户的音频禁用状态回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param muted 是否禁用音频，YES 禁用，NO 打开音频
 @param uid 用户uid
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didAudioMuted:(BOOL)muted byUid:(uint64_t)uid;

/**
 音频初始化失败回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param reason 失败原因，1：audio session错误, 0：其它失败
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didAudioInitializeFailed:(int32_t)reason;

// Video

/**
 收到远端麦上用户为uid的用户的视频首包回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uid  收到首包视频的uid
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteVideoPkgReceived:(uint64_t)uid;

/**
 远端麦上用户为uid的用户的视频首帧回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uid  收到首帧视频的uid
 @param size 视频区域大小
 @param elapsed 耗时
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteVideoFrameOfUid:(uint64_t)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

/**
 远端麦上用户为uid的用户的视频首帧解码回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param uid  收到首帧解码的uid
 @param elapsed 耗时
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine firstRemoteVideoDecodedOfUid:(uint64_t)uid elapsed:(NSInteger)elapsed;

/**
 麦上用户的视频禁用状态回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param muted 是否禁用视频，YES 禁用，NO 打开视频
 @param uid 用户uid
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine didVideoMuted:(BOOL)muted byUid:(uint64_t)uid;

/**
 本地的一些设备状态回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param localVideoState 本地设备状态
 @param error  错误信息
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine localVideoStateChanged:(int)localVideoState error:(int)error;

/**
 视频卡顿回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param isSmooth 是否卡顿
 
 - YES：不卡顿
 - NO：卡顿
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine videoPlaySmoothStatusChanged:(BOOL)isSmooth;

/**
 媒体中断通知
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param isAudio 媒体类型（视频或音频）
 
 - YES: 音频
 - NO: 视频
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine mediaInterrupted:(BOOL)isAudio;

/**
 媒体恢复通知
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param success 是否成功恢复
 @param isAudio 媒体类型（视频或音频）
 
 - YES: 音频
 - NO: 视频
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine mediaInterruptResumed:(BOOL)success isAudio:(BOOL)isAudio;

@end

#endif /* CStoreMediaEngineCoreDelegate_h */
