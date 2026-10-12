//+------------------------------------------------------------------+
//| Module: Z85.mqh                                                  |
//| This file is part of the mql-zmq project:                        |
//|     https://github.com/dingmaotu/mql-zmq                         |
//+------------------------------------------------------------------+
#property strict

#include <Mql/Lang/Native.mqh>

#import "libzmq.dll"
intptr_t zmq_z85_encode(uchar &str[],const uchar &data[],size_t size);
intptr_t zmq_z85_decode(uchar &dest[],const uchar &str[]);
int zmq_curve_keypair(uchar &z85_public_key[],uchar &z85_secret_key[]);
int zmq_curve_public(uchar &z85_public_key[],const uchar &z85_secret_key[]);
#import

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

bool Z85::encode(string &secret,const uchar &data[])
  {
   int size=ArraySize(data);
   if(size%4 != 0) return false;

   uchar str[]; // Changed from char to uchar
   ArrayResize(str,(int)(1.25*size+1));

   intptr_t res=zmq_z85_encode(str,data,size);
   if(res == 0) 
     {
      ArrayFree(str);
      return false;
     }
   secret = StringFromUtf8(str);
   ArrayFree(str);
   return true;
  }

bool Z85::decode(const string secret,uchar &data[])
  {
   int len=StringLen(secret);
   if(len%5 != 0) return false;

   uchar str[]; // Changed from char to uchar
   StringToUtf8(secret,str);
   ArrayResize(data,(int)(0.8*len));
   intptr_t res = zmq_z85_decode(data,str);
   ArrayFree(str);
   return 0 != res;
  }

string Z85::encode(string data)
  {
   uchar str[]; // Changed from char to uchar
   StringToUtf8(data,str,false);
   string res;
   if(encode(res,str))
     {
      ArrayFree(str);
      return res;
     }
   else
     {
      ArrayFree(str);
      return "";
     }
  }

string  Z85::decode(string secret)
  {
   uchar data[];
   decode(secret,data);
   string res = StringFromUtf8(data);
   ArrayFree(data);
   return res;
  }

bool Z85::generateKeyPair(uchar &publicKey[],uchar &secretKey[])
  {
   ArrayResize(publicKey,41);
   ArrayResize(secretKey,41);
   return 0==zmq_curve_keypair(publicKey, secretKey);
  }

bool Z85::derivePublic(uchar &publicKey[],const uchar &secretKey[])
  {
   ArrayResize(publicKey,41);
   return 0==zmq_curve_public(publicKey, secretKey);
  }

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