//+------------------------------------------------------------------+
//|                                                   TaskWorker.mq4 |
//|                  Copyright 2017, Bear Two Technologies Co., Ltd. |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Bear Two Technologies Co., Ltd."
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Task worker in MQL (adapted from C++ version)                    |
//| Connects PULL socket to tcp://localhost:5557                     |
//| Collects workloads from ventilator via that socket               |
//| Connects PUSH socket to tcp://localhost:5558                     |
//| Sends results to sink via that socket                            |
//|                                                                  |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Share a single context in the terminal by the key "work"
   Context context("work");

//--- Socket to receive messages on
   Socket receiver(context,ZMQ_PULL);
   receiver.connect("tcp://localhost:5557");

//--- Socket to send messages to
   Socket sender(context,ZMQ_PUSH);
   sender.connect("tcp://localhost:5558");

//--- Process tasks forever
   string progress="";
   while(!IsStopped())
     {
      ZmqMsg message;
      receiver.recv(message);
      //--- Workload in msecs
      int workload=(int)StringToInteger(message.getData());
      //--- Do the work
      Sleep(workload);
      //--- Send results to sink
      message.rebuild();
      sender.send(message);

      //  Simple progress indicator for the viewer
      progress+=".";
      Comment(progress);
     }
  }
//+------------------------------------------------------------------+
