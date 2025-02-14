一、
Proto 生成 lua

將 *.proto 放到 Code_Client\protobuf-lua\BuildProto 目錄下

執行 Code_Client\protobuf-lua\BuildProto\buildproto.bat

生成 *_pb.lua 在 Code_Client\protobuf-lua\BuildProto\lua 下

、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、


二、lua 斷點調試

安裝 VS2012/2013/2015,下載 babelua 對應支持的版本，作為 VS 的插件，網上搜索 斷點調試方法

注意：1.將需要調試的 lua 項目設置為 默認啟動項，
      2.babelua 不能調試 X64 的 exe，要使用 (X86) Win32
      3.出現類似 Warning 1000: Lua functions were not found during debugging session 警告，需要將 exe 文件對應的 pdb文件(和exe文件同時編譯出來的pdb文件)拷貝到 exe文件所在目錄下，然後再啟動調試。