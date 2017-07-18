//+------------------------------------------------------------------+
//|                                                     RRClient.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Request-reply client in MQL (adapted from C++ version)           |
//| Connects REQ socket to tcp://localhost:5559                      |
//| Sends "Hello" to server, expects "World" back                    |
//|                                                                  |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
   Context context;

   Socket requester(context,ZMQ_REQ);
   requester.connect("tcp://localhost:5559");

   for(int request=0; request<10; request++)
     {
      ZmqMsg message("Hello");
      requester.send(message);

      ZmqMsg reply;
      requester.recv(reply,true);

      Print("Received reply ",reply.getData());
     }
  }
//+------------------------------------------------------------------+
