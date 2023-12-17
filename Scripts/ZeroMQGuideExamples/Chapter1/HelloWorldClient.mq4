﻿//+------------------------------------------------------------------+
//|                                             HelloWorldClient.mq4 |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Hello World client in MQL                                        |
//| Connects REQ socket to tcp://localhost:5555                      |
//| Sends "Hello" to server, expects "World" back                    |
//+------------------------------------------------------------------+
void OnStart()
  {
// Prepare our context and socket
   Context context("helloworld");
   Socket socket(context,ZMQ_REQ);

   Print("Connecting to hello world server…");
   socket.connect("tcp://localhost:5555");

// Do 10 requests, waiting each time for a response
   for(int request_nbr=0; request_nbr!=10 && !IsStopped(); request_nbr++)
     {
      ZmqMsg request("Hello");
      Print("Sending: ",(string)request.getData()," ",request_nbr);
      socket.send(request);

      // Get the reply.
      ZmqMsg reply;
      socket.recv(reply);
      Print("Received: ",(string)reply.getData());
     }
  }
//+------------------------------------------------------------------+
