//+------------------------------------------------------------------+
//|                                         VersionReporting.mq4.mq4 |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Report 0MQ version                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print(Zmq::getVersion());
  }
//+------------------------------------------------------------------+
