//+------------------------------------------------------------------+
//|                                                     MSPoller.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Reading from multiple sockets in MQL (adapted from C++ version)  |
//| This version uses zmq_poll()                                     |
//|                                                                  |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Context context;

//  Connect to task ventilator
   Socket receiver(context,ZMQ_PULL);
   receiver.connect("tcp://localhost:5557");

//  Connect to weather server
   Socket subscriber(context,ZMQ_SUB);
   subscriber.connect("tcp://localhost:5556");
   subscriber.subscribe("10001 ");

//  Initialize poll set
   PollItem items[2];
   receiver.fillPollItem(items[0],ZMQ_POLLIN);
   subscriber.fillPollItem(items[1],ZMQ_POLLIN);
//  Process messages from both sockets
   while(!IsStopped())
     {
      ZmqMsg message;
      //--- MQL Note: To handle Script exit properly, we set a timeout of 500 ms instead of infinite wait
      Socket::poll(items,500);

      if(items[0].hasInput())
        {
         receiver.recv(message);
         //  Process task
        }
      if(items[1].hasInput())
        {
         subscriber.recv(message);
         //  Process weather update
        }
     }
  }
//+------------------------------------------------------------------+
