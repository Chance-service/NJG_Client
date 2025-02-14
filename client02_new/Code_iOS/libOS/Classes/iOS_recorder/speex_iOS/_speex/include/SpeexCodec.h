//
//  SpeexCodec.h
//  TEST_Speex_001
//
//  Created by cai xuejun on 12-9-4.
//  Copyright (c) 2012年 caixuejun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeexAllHeader.h"

//#if !(TARGET_IPHONE_SIMULATOR)
//#define speex_encode speex_encode_int
//#define speex_decode speex_decode_int
//#endif

#define FRAME_SIZE 160 // PCM音频8khz*20ms -> 8000*0.02=160
#define MAX_NB_BYTES 200
#define SPEEX_SAMPLE_RATE 8000


typedef struct
{
	char chChunkID[4];
	int nChunkSize;
}XCHUNKHEADER;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
}WAVEFORMAT;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
	short nExSize;
}WAVEFORMATX;

typedef struct
{
	char chRiffID[4];
	int nRiffSize;
	char chRiffFormat[4];
}RIFFHEADER;

typedef struct
{
	char chFmtID[4];
	int nFmtSize;
	WAVEFORMAT wf;
}FMTBLOCK;

@class SpeexCodec;

@protocol SpeexCodecEncodeDelegate <NSObject>
@optional
- (void)encodeSucceed:(SpeexCodec* )speexCodec WithData:(NSData*)outSpeexData;
- (void)encodeFailed:(SpeexCodec* )speexCodec;

@end

@protocol SpeexCodecDecodeDelegate <NSObject>
@optional
- (void)decodeSucceed:(SpeexCodec* )speexCodec WithData:(NSData*)outPCMData;
- (void)decodeFailed:(SpeexCodec* )speexCodec;

@end


@interface SpeexCodec : NSObject

@property(assign) id<SpeexCodecEncodeDelegate> delegateEncode;
@property(assign) id<SpeexCodecDecodeDelegate> delegateDecode;

//int EncodeWAVEFileToSpeexFile(const char* pchWAVEFilename, const char* pchAMRFileName, int nChannels, int nBitsPerSample);

//int DecodeSpeexFileToWAVEFile(const char* pchAMRFileName, const char* pchWAVEFilename);

//NSData* DecodeSpeexToWAVE(NSData* data);
//NSData* EncodeWAVEToSpeex(NSData* data, int nChannels, int nBitsPerSample);

- (id)init;

-(NSData* )DecodeSpeexToWAVE:(NSData* )data;
-(NSData* )EncodeWAVEToSpeex:(NSData* )data withChannels:(int)nChannels andBitsPerSample:(int)nBitsPerSample;

// 根据帧头计算当前帧大小
float CalculatePlayTime(NSData *speexData, int frame_size);

@end
