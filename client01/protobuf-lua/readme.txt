安裝protobuf-lua的步驟

1.安裝python2.7和lua51
2.如果環境變量沒有正確設置，需要在環境變量裡面正確設置python和lua的路徑。
3.用cmd進入protobuf-2.5.0rc1\python目錄，運行"python setup.py build"和"python setup.py install"
4.在proto文件的路徑，用luaout方式運行protoc的生成proto的lua文件(類似BuildProto-lua-signal.bat等方法)