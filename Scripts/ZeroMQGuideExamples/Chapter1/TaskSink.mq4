//+------------------------------------------------------------------+
//|                                                     TaskSink.mq4 |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Bear Two Technologies Co., Ltd."
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict

#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//|  Task sink in MQL (adapted from C++ version)                     |
//|  Binds PULL socket to tcp://localhost:5558                       |
//|  Collects results from workers via that socket                   |
//|                                                                  |
//|  Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>            |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
//  Prepare our context and socket
   Context context;
   Socket receiver(context,ZMQ_PULL);
   receiver.bind("tcp://*:5558");

//  Wait for start of batch
   ZmqMsg message;
   receiver.recv(message);

//  Start our clock now
   uint tstart=GetTickCount();
//  Process 100 confirmations
   string progress="";
   for(int i=0; i<100; i++)
     {
      receiver.recv(message);
      if((i/10)*10==i)
         progress+=":";
      else
         progress+=".";
      Comment(progress);
     }
//  Calculate and report duration of batch
   uint tend=GetTickCount();
   Print(">>> Total elapsed time: ",tend-tstart," msec");
  }
//+------------------------------------------------------------------+
