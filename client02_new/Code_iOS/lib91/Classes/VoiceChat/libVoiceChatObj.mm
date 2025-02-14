
#import "libVoiceChatObj.h"
#import "libVoiceChat.h"

@implementation libVoiceChatObj

- (void)initVoiceChatObj
{
    
}

//登录结果回调
-(void)loginResult:(int)result MSG:(NSString*)msg YunvaID:(long)yunvaID
{
    std::string strmsg = [msg UTF8String];

    libVoiceChat::getInstance()->notifyLoginResult(result,strmsg,yunvaID);
}
//注销结果回调
-(void)logoutResult:(int)result MSG:(NSString*)msg
{
    std::string strmsg = [msg UTF8String];
    libVoiceChat::getInstance()->notifyLougoutResult(result, strmsg);
}
//上传语音结果回调
-(void)uploadVoiceResult:(int)result URL:(NSString*)voiceURL Time:(long)voiceTime Info:(NSString*)voiceInfo
{
    if (voiceURL && voiceInfo) {
        std::string strURL = [voiceURL UTF8String];
        std::string strInfo = [voiceInfo UTF8String];
        libVoiceChat::getInstance()->notifyUploadVoiceMessage(result,strURL, voiceTime, strInfo);
    }
}
//发送文本结果回调
-(void)sendTextResult:(int)result MSG:(NSString*)msg
{
    std::string strmsg = [msg UTF8String];
    libVoiceChat::getInstance()->notifySendTextMessage(result,strmsg);
}
//发送文本和语音结果回调
-(void)sendtextAndVoiceResult:(int)result MSG:(NSString*)msg URL:(NSString*)url voiceDuration:(int)voiceduration FilePath:(NSString*)filepath Expand:(NSString*)expand Text:(NSString*)text
{
   // std::string strmsg = [msg UTF8String];
    std::string strURL = [url UTF8String];
    std::string strPath = [filepath UTF8String];
    std::string strExpand = [expand UTF8String];
    std::string strText = [text UTF8String];
    libVoiceChat::getInstance()->notifyUploadBdVoiceMessage(result, "", strURL, voiceduration, strPath, strExpand, strText);
    
}
//收到文本消息
-(void)receiveTextTroopsID:(NSString*)troopsID Text:(NSString*)text Expand:(NSString*)expand
{
    std::string strtRoopsID = [troopsID UTF8String];
    std::string strText = [text UTF8String];
    std::string strExpand = [expand UTF8String];
    libVoiceChat::getInstance()->notifyReceiveTextMessage(strtRoopsID, strText, strExpand);
}
//收到语音信息
-(void)receiveVoiceTroopsID:(NSString*)troopsID Path:(NSString*)voicePath Time:(long)voiceTime text:(NSString*)text Info:(NSString*)voiceInfo
{
    std::string strtRoopsID = [troopsID UTF8String];
    std::string strPath = [voicePath UTF8String];
    std::string strText = [text UTF8String];
    std::string strInfo = [voiceInfo UTF8String];
    libVoiceChat::getInstance()->notifyVoiceMessage(strtRoopsID, strPath, voiceTime, strText, strInfo);
}
//语音识别后，如果只发送文字，将文字返回
-(void)BDMineText:(NSString*)msg
{
    std::string strmsg = [msg UTF8String];
    libVoiceChat::getInstance()->notifyBdMineTxtMsg(strmsg);
}

@end