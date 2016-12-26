//+------------------------------------------------------------------+
//|                                                          Z85.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Common.mqh"

#import "libzmq.dll"
// Encode data with Z85 encoding. Returns 0(NULL) if failed
intptr_t zmq_z85_encode(char &str[],const uchar &data[],size_t size);

// Decode data with Z85 encoding. Returns 0(NULL) if failed
intptr_t zmq_z85_decode(uchar &dest[],const char &str[]);

// Generate z85-encoded public and private keypair with tweetnacl/libsodium
int zmq_curve_keypair(char &z85_public_key[],char &z85_secret_key[]);

// Derive the z85-encoded public key from the z85-encoded secret key
int zmq_curve_public(char &z85_public_key[],const char &z85_secret_key[]);
#import
//+------------------------------------------------------------------+
//| Z85 encoding/decoding                                            |
//+------------------------------------------------------------------+
class Z85
  {
public:
   static bool       encode(string &secret,const uchar &data[]);
   static bool       decode(const string secret,uchar &data[]);

   static string     encode(string data);
   static string     decode(string secret);

   static bool       generateKeyPair(uchar &publicKey[],uchar &secretKey[]);
   static bool       derivePublic(uchar &publicKey[],const uchar &secretKey[]);

   static bool       generateKeyPair(string &publicKey,string &secretKey);
   static string     derivePublic(const string secretKey);
  };
//+------------------------------------------------------------------+
//| data must have size multiple of 4                                |
//+------------------------------------------------------------------+
bool Z85::encode(string &secret,const uchar &data[])
  {
   int size=ArraySize(data);
   if(size%4 != 0) return false;

   char str[];
   ArrayResize(str,(int)(1.25*size+1));

   intptr_t res=zmq_z85_encode(str,data,size);
   if(res == 0) return false;
   secret = StringFromUtf8(str);
   return true;
  }
//+------------------------------------------------------------------+
//| secret must be multiples of 5                                    |
//+------------------------------------------------------------------+
bool Z85::decode(const string secret,uchar &data[])
  {
   int len=StringLen(secret);
   if(len%5 != 0) return false;

   char str[];
   StringToUtf8(secret,str);
   ArrayResize(data,(int)(0.8*len));
   return 0 != zmq_z85_decode(data,str);
  }
//+------------------------------------------------------------------+
//| data length should be multiples of 4 and only ascii is supported |
//+------------------------------------------------------------------+
string Z85::encode(string data)
  {
   char str[];
   StringToUtf8(data,str,false);
   string res;
   if(encode(res,str))
      return res;
   else
      return "";
  }
//+------------------------------------------------------------------+
//| secret must be multiples of 5                                    |
//+------------------------------------------------------------------+
string  Z85::decode(string secret)
  {
   uchar data[];
   decode(secret,data);
   return StringFromUtf8(data);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Z85::generateKeyPair(uchar &publicKey[],uchar &secretKey[])
  {
   ArrayResize(publicKey,41);
   ArrayResize(secretKey,41);
   return 0==zmq_curve_keypair(publicKey, secretKey);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Z85::derivePublic(uchar &publicKey[],const uchar &secretKey[])
  {
   ArrayResize(publicKey,41);
   return 0==zmq_curve_public(publicKey, secretKey);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Z85::generateKeyPair(string &publicKey,string &secretKey)
  {
   uchar sec[],pub[];
   bool res=generateKeyPair(pub,sec);
   if(res)
     {
      secretKey=StringFromUtf8(sec);
      publicKey=StringFromUtf8(pub);
     }
   ArrayFree(sec);
   ArrayFree(pub);
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Z85::derivePublic(const string secrect)
  {
   uchar sec[],pub[];
   StringToUtf8(secrect,sec);
   derivePublic(pub,sec);
   string pubstr=StringFromUtf8(pub);
   ArrayFree(sec);
   ArrayFree(pub);
   return pubstr;
  }
//+------------------------------------------------------------------+
