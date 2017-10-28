//+------------------------------------------------------------------+
//|                                                      WUProxy.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Weather proxy device MQL (adapted from C++)                      |
//|                                                                  |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Context context;

//  This is where the weather server sits
   Socket frontend(context,ZMQ_XSUB);
   frontend.connect("tcp://192.168.55.210:5556");

//  This is our public endpoint for subscribers
   Socket backend(context,ZMQ_XPUB);
   backend.bind("tcp://10.1.1.0:8100");

//  Subscribe on everything
   frontend.subscribe("");

//  Shunt messages out to our own subscribers
   while(!IsStopped())
     {
      //  Process all parts of the message
      ZmqMsg message;
      bool more;
      do
        {
         frontend.recv(message);
         if(message.more()) backend.sendMore(message);
         else backend.send(message);
        }
      while(more);
     }
  }
//+------------------------------------------------------------------+
