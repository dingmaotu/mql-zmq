//+------------------------------------------------------------------+
//|                                                     RRBroker.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Simple request-reply broker in MQL (adapted from C++ version)    |
//|                                                                  |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
//  Prepare our context and sockets
   Context context;
   Socket frontend(context,ZMQ_ROUTER);
   Socket backend(context,ZMQ_DEALER);

   frontend.bind("tcp://*:5559");
   backend.bind("tcp://*:5560");

//  Initialize poll set
   PollItem items[2];
   frontend.fillPollItem(items[0],ZMQ_POLLIN);
   backend.fillPollItem(items[1],ZMQ_POLLIN);

//  Switch messages between sockets
   while(!IsStopped())
     {
      ZmqMsg message;
      bool more=false;               //  Multipart detection

      Socket::poll(items,500);

      if(items[0].hasInput())
        {
         //  Process all parts of the message
         do
           {
            frontend.recv(message);
            if(message.more()) backend.sendMore(message);
            else backend.send(message);
           }
         while(more);
        }
      if(items[1].hasInput())
        {
         //  Process all parts of the message
         do
           {
            backend.recv(message);
            if(message.more()) frontend.sendMore(message);
            else frontend.send(message);
           }
         while(more);
        }
     }
  }
//+------------------------------------------------------------------+
