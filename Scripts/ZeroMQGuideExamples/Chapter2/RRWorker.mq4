//+------------------------------------------------------------------+
//|                                                     RRWorker.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Request-reply service in MQL (adapted from C++ version)          |
//| Connects REP socket to tcp://localhost:5560                      |
//| Expects "Hello" from client, replies with "World"                |
//|                                                                  |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
   Context context;

   Socket responder(context,ZMQ_REP);
   responder.connect("tcp://localhost:5560");

   while(!IsStopped())
     {
      //  Wait for next request from client
      ZmqMsg req;
      responder.recv(req);
      Print("Received request: ",req.getData());

      // Do some 'work'
      Sleep(1000);

      ZmqMsg reply("World");

      //  Send reply back to client
      responder.send(reply);
     }
  }
//+------------------------------------------------------------------+
