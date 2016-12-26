# mql-zmq

ZMQ binding for the MQL language (both 32bit MT4 and 64bit MT5)

## Introduction

This is a complete binding of the [ZeroMQ](http://zeromq.org/) library
for the MQL4/5 language provided by MetaTrader4/5.

Traders with programming abilities have always wanted a messaging solution
like ZeroMQ, simple and powerful, far better than the PIPE trick as 
suggested by the official articles. However, bindings for MQL were either outdated or not complete (a lot of functionalities are missing). This binding is based on latest 4.2 version of the library, and provided all functionalities as specified in the API documentation.

This binding tries to remain compatible between MQL4/5. Users of both versions can use this binding, with a single set of headers. MQL4 and MQL5 are basically the same in that they are merged in recent versions. The difference is in the runtime environment (MetaTrader5 is 64bit by default, while MetaTrader4 is 32bit). The trading system is also different, but it is no concern of this binding.

## Files 

This binding contains three sets of files:

1. The binding itself is in the `Include/Zmq` directory.

2. The testing scripts and zmq guide examples are in `Scripts` directory. The script files are mq4 by default, but you can change the extension to mq5 to use them in MetaTrader5.

3. Precompiled DLLs of both 64bit (`Library/MT5`) and 32bit (`Library/MT4`) ZeroMQ and libsodium are provided. Copy the corresponding DLLs to the `Library` folder of your MetaTrader terminal. If you are using MT5 32bit, use the 32bit version from `Library/MT4`. The DLLs require that you have the latest Visual C++ runtime (2015). *Note* that these DLLs are compiled from official sources, without any modification. You can compile your own if you don't trust these binaries. The `libsodium.dll` is copied from the official binary release. If you want to support security mechanisms other than `curve`, or you want to use transports like OpenPGM, you need to compile your own DLL.

## About string encoding

MQL strings are Win32 UNICODE strings (basically 2-byte UTF-16). In this binding all strings are converted to utf-8 strings before sending to the dll layer. The ZmqMsg supports a constructor from MQL strings, the default is _NOT_ null-terminated.

## Usage

You can find a simple test script in `Scripts/Test`, and you can find examples of the official guide in Scripts/ZeroMQGuideExamples. I intend to translate all examples to this binding, but now only the hello world example is provided. I will gradually add those examples. Of course forking this binding if you are interested and welcome to send pull requests.

## TODO

1. Write more tests.
2. Add more examples from the official ZMQ guide.

## Changes

2016-12-27: Released 1.0.