//+------------------------------------------------------------------+
//|                                                       Common.mqh |
//| This file is part of mql4-lib project (Lang/Native.mqh):         |
//| (github.com/dingmaotu/mql4-lib)                                  |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property strict

#include "Errno.mqh"

// Assume MT5 is 64bit, which is the default.
// Even though MT5 can be 32bit, there is no way to detect this
// by using preprocessor macros. Instead, MetaQuotes provides a
// function called IsX64 to detect this dynamically

// This is just absurd. Why do you want to know the bitness of
// the runtime? To define pointer related entities at compile time!
// All integer types in MQL is uniform on both 32bit or 64bit
// architectures, so it is almost useless to have a runtime function IsX64.

// Why not a __X64__?
#ifdef __MQL5__
#define __X64__
#endif

#ifdef __X64__
#define intptr_t long
#define uintptr_t ulong
#define size_t long
#else
#define intptr_t int
#define uintptr_t uint
#define size_t int
#endif

#import "kernel32.dll"
void RtlMoveMemory(intptr_t dest,const uchar &array[],size_t length);
void RtlMoveMemory(uchar &array[],intptr_t src,size_t length);
int lstrlen(intptr_t psz);
int MultiByteToWideChar(uint   codePage,
                        uint   flags,
                        const  intptr_t multiByteString,
                        int    lengthMultiByte,
                        string &str,
                        int    length
                        );
#import
//+------------------------------------------------------------------+
//| Copy the memory contents pointed by src to array                 |
//| array parameter should be initialized to the desired size        |
//+------------------------------------------------------------------+
void ArrayFromPointer(uchar &array[],intptr_t src,int count=WHOLE_ARRAY)
  {
   int size=(count==WHOLE_ARRAY)?ArraySize(array):count;
   RtlMoveMemory(array,src,(size_t)size);
  }
//+------------------------------------------------------------------+
//| Copy array to the memory pointed by dest                         |
//+------------------------------------------------------------------+
void ArrayToPointer(const uchar &array[],intptr_t dest,int count=WHOLE_ARRAY)
  {
   int size=(count==WHOLE_ARRAY)?ArraySize(array):count;
   RtlMoveMemory(dest,array,(size_t)size);
  }
//+------------------------------------------------------------------+
//| Read a valid utf-8 string to the MQL environment                 |
//| With this function, there is no need to copy the string to char  |
//| array, and convert with CharArrayToString                        |
//+------------------------------------------------------------------+
string StringFromUtf8Pointer(intptr_t psz,int len)
  {
   if(len < 0) return NULL;
   string res;
   int required=MultiByteToWideChar(CP_UTF8,0,psz,len,res,0);
   StringInit(res,required);
   int resLength = MultiByteToWideChar(CP_UTF8,0,psz,len,res,required);
   if(resLength != required)
     {
      return NULL;
     }
   else
     {
      return res;
     }
  }
//+------------------------------------------------------------------+
//| for null-terminated string                                       |
//+------------------------------------------------------------------+
string StringFromUtf8Pointer(intptr_t psz)
  {
   int len=lstrlen(psz);
   return StringFromUtf8Pointer(psz, len);
  }
//+------------------------------------------------------------------+
//| Convert a utf-8 byte array to a string                           |
//+------------------------------------------------------------------+
string StringFromUtf8(const uchar &utf8[])
  {
   return CharArrayToString(utf8, 0, -1, CP_UTF8);
  }
//+------------------------------------------------------------------+
//| Convert a string to a utf-8 byte array                           |
//+------------------------------------------------------------------+
void StringToUtf8(const string str,uchar &utf8[],bool ending=true)
  {
   int count=ending ? -1 : StringLen(str);
   StringToCharArray(str,utf8,0,count,CP_UTF8);
  }

#ifdef _DEBUG
#define Debug(msg) Print(">>> DEBUG: In ",__FUNCTION__,"(",__FILE__,":",__LINE__,") [", msg, "]")
#else
#define Debug(msg)
#endif
//+------------------------------------------------------------------+
