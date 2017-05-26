//+------------------------------------------------------------------+
//|                                             HelloWorldServer.mq5 |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"

#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Hello World server in MQL                                        |
//| Binds REP socket to tcp://*:5555                                 |
//| Expects "Hello" from client, replies with "World"                |
//+------------------------------------------------------------------+
void OnStart()
  {
   Context context("helloworld");
   Socket socket(context,ZMQ_REP);

   socket.bind("tcp://*:5555");

   while(!IsStopped())
     {
      ZmqMsg request;

      // Wait for next request from client

      // MetaTrader note: this will block the script thread
      // and if you try to terminate this script, MetaTrader
      // will hang (and crash if you force closing it)
      socket.recv(request);
      Print("Receive Hello");

      Sleep(1000);

      ZmqMsg reply("World");
      // Send reply back to client
      socket.send(reply);
     }
  }
//+------------------------------------------------------------------+
