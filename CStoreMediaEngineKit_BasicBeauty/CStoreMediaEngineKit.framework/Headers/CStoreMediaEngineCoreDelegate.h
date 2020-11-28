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
@class CSMLocalVideoStats;
@class CSMLocalAudioStats;

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
 
 此时你应该更新最新的token并通过调用 [CStoreMediaEngineCore renewToken:] 给sdk，回调该接口前，内部会调用[CStoreMediaEngineCore leaveChannel]。 此时需要生成新的 Token，使用新的 Token 重新加入频道。
 
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

/**
 RTMP 推流状态发生改变回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param url 推流状态发生改变的 URL 地址。
 @param state 当前的推流状态，详见 @see CSMRtmpStreamingState
 @param errorCode 具体的推流错误信息，详见 @see CSMRtmpStreamingErrorCode
 */
- (void)mediaEngine:(CStoreMediaEngineCore *)mediaEngine rtmpStreamingChangedToState:(NSString *_Nonnull)url state:(CSMRtmpStreamingState)state errorCode:(CSMRtmpStreamingErrorCode)errorCode;

/**
 设置合流转码参数回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 */
- (void)mediaEngineTranscodingUpdated:(CStoreMediaEngineCore *_Nonnull)mediaEngine;

- (void)mediaEngine:(CStoreMediaEngineCore * _Nonnull)mediaEngine someBodyJoinedChannelWithUid:(uint64_t)uid role:(CSMClientRole)role;
/**
 通话音量模式 / 媒体音量模式切换回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param usingCallMode YES：使用通话音量模式，NO：使用媒体音量模式
 */
- (void)mediaEngine:(CStoreMediaEngineCore * _Nonnull)mediaEngine usingCallMode:(BOOL)usingCallMode;

/**
 收到远端的媒体次要信息回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param info 媒体次要信息
 @param senderUid 发送该媒体次要信息的用户uid
 */
- (void)mediaEngine:(CStoreMediaEngineCore * _Nonnull)mediaEngine onRecvMediaSideInfo:(NSString * _Nullable)info withSenderUid:(uint64_t)senderUid;

/**
 * 采集原始数据回调
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param data         采集原始数据
 @param frameType    视频帧类型,详见 BigoPixelFormat
 @param width        视频像素宽度
 @param height       视频像素高度
 @param bufferLength 数据长度
 @param rotation     视频旋转角度
 @param renderTimeMs 回调时间
 */
- (void)mediaEngine:(CStoreMediaEngineCore * _Nonnull)mediaEngine onCaptureVideoFrame:(unsigned char *_Nonnull)data frameType:(BigoPixelFormat)frameType width:(int)width height:(int)height bufferLength:(int)bufferLength rotation:(int)rotation renderTimeMs:(uint64_t)renderTimeMs;

/**
音效文件播放状态通知

@param mediaEngine CStoreMediaEngineCore对象
@param state 哪种状态
 
 - BigoAudioMixingStatePlaying：音乐文件正常播放，正常调用playEffect/resumeEffect
 - BigoAudioMixingStatePaused：音乐文件暂停播放
 - BigoAudioMixingStateStopped：音乐文件停止播放
 - BigoAudioMixingStateFailed：音乐文件播放失败
 - BigoAudioMixingStateProgress：音乐文件播放进度回调
 
@param soundId 音效文件id
@param reason 状态值
 
 - BigoAudioMixingErrorCanNotOpen：state为BigoAudioMixingStateStopped时，表示打开文件失败
 - BigoAudioMixingErrorInterruptedEOF = 703, state为BigoAudioMixingStateStopped时，表示打开文件异常
 - BigoAudioMixingPlayEndOfFile：state为BigoAudioMixingStateStopped时，表示文件播放结束
 - BigoAudioMixingPlayActiveStop：打开文件错误
 - BigoAudioEffectFileNumFull：打开文件错误
 - 其他state值，reason为毫秒ms值
 */
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine localAudioEffectStateChange:(BigoAudioMixingStateCode)state soundId:(NSInteger)soundId reason:(NSUInteger)reason;

/**
音乐文件播放状态通知

@param mediaEngine CStoreMediaEngineCore对象
 @param state 哪种状态
 
  - BigoAudioMixingStatePlaying：音乐文件正常播放，正常调用 startAudioMixing / resumeAudioMixing
  - BigoAudioMixingStatePaused：音乐文件暂停播放
  - BigoAudioMixingStateStopped：音乐文件停止播放
  - BigoAudioMixingStateFailed：音乐文件播放失败
  - BigoAudioMixingStateProgress：音乐文件播放进度回调
@param reason 状态值
 
 - BigoAudioMixingErrorCanNotOpen：state为BigoAudioMixingStateStopped时，表示打开文件失败
 - BigoAudioMixingErrorInterruptedEOF = 703, state为BigoAudioMixingStateStopped时，表示打开文件异常
 - BigoAudioMixingPlayEndOfFile：state为BigoAudioMixingStateStopped时，表示文件播放结束
 - BigoAudioMixingPlayActiveStop：打开文件错误
 - BigoAudioEffectFileNumFull：打开文件错误
 - 其他state值，reason为毫秒ms值
*/
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine localAudioMixingStateDidChanged:(BigoAudioMixingStateCode)state reason:(NSUInteger)reason;

/**
 提示频道内谁正在说话、说话者音量及本地用户是否在说话的回调

 @param mediaEngine CStoreMediaEngineCore对象
 @param uid uint64_t[],说话者的用户 ID, uid = 0表示本地用户
 @param volume unsigned int []，说话者各自混音后的音量
 @param vad unsigned int []，本地用户的人声状态，0：本地用户不在说话；1：本地用户在说话
 @param channelId 频道 ID，表明当前说话者在哪个频道
 @param totalVolume 混音后的总音量
*/
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine reportAudioVolumeIndicationOfSpeakers:(NSArray<NSNumber *> *)uid volume:(NSArray<NSNumber *> *)volume vad:(NSArray<NSNumber *> *)vad channelId:(NSArray<NSString *> *)channelId totalVolume:(NSUInteger)totalVolume;

/**
 监测到最活跃用户回调。
 
@param mediaEngine CStoreMediaEngineCore对象
@param uid 活跃用户的uid
*/
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine activeSpeaker:(uint64_t)uid;

/**
 SDK 通知将要开始采集视频帧，收到该回调后向 SDK 发送的视频帧数据才有效
 
 @param mediaEngine CStoreMediaEngineCore对象
 */
- (void)onStartCustomCaptureVideoWithMediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine;

/**
 SDK 通知将要停止采集视频帧
 
 @param mediaEngine CStoreMediaEngineCore对象
 */
- (void)onStopCustomCaptureVideoWithMediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine;

/**
 SDK 通知要修改采集分辨率
 
 SDK内部会综合多种维度对分辨率进行调整，接入方接收到该通知后，需要根据传出的长宽，选择最接近的采集分辨率
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param width 分辨率宽度
 @param height 分辨率调试
 */
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine shouldChangeCustomCaptureResolutionToWidth:(int)width height:(int)height;

/**
 本地视频流统计信息回调。
 
 报告更新本地视频统计信息，该回调方法每3秒触发一次。
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param stats 本地视频的统计信息: CSMLocalVideoStats
 */
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine localVideoStats:(CSMLocalVideoStats *_Nonnull)stats;

/**
 本地音频流的统计信息回调。
 
 该回调描述本地设备发送音频流的统计信息。SDK每3秒触发该回调一次。
 
 @param mediaEngine CStoreMediaEngineCore对象
 @param stats 本地音频统计数据: CSMLocalAudioStats
 */
- (void)mediaEngine:(CStoreMediaEngineCore *_Nonnull)mediaEngine localAudioStats:(CSMLocalAudioStats *_Nonnull)stats;

@end

#endif /* CStoreMediaEngineCoreDelegate_h */

