# cstore-example-ios

## 使用不同的target可以编出不同的demo
1. 在控制台中新建项目，复制appId和cer到CSDataStore.m文件的指定位置中
2. 根据需求选中不同的target，在签名配置中修改bundle id和team，自动签名成功。然后点击run运行即可
> 不同的target可以编出不同的demo
>1. video-live-basic-beauty：多人直播（只有基础美颜）
>2. video-call-1v1-basic-beauty：1v1视频通话（只有基础美颜）
>3. audio-call-1v1：1v1语音通话
>4. audio-live：多人语音

注意：由于Demo暂不支持高级美颜，video-live和video-call-1v1两个Target无法运行

## 工程结构说明
1. common目录：在多个demo间复用的代码与资源
2. common/Utils：工具类集合
3. common/Thirdparty：第三方库
4. common/Beauty：美颜模块
5. common/Beauty/BeautyResource：美颜模块的资源文件，包含贴纸素材、滤镜素材、人脸识别模型等
6. video-live、audio-live、video-call-1v1、audio-call-1v1目录：各demo独有的代码与资源

## SDK版本目录

* CStoreMediaEngineKit_BasicBeauty/CStoreMediaEngineKit.framework：基础美颜版SDK，包含音视频和基础美颜
* CStoreMediaEngineKit_Audio/CStoreMediaEngineKit.framework：纯语音版SDK，只有音频模块
