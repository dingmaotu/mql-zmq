//+------------------------------------------------------------------+
//|                                                  RTReqWorker.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#include <Zmq/Zmq.mqh>
#property show_inputs
//+------------------------------------------------------------------+
//| This example comes from the "Load Balancing Pattern"             |
//| The original example creates threads for workers and spawn them  |
//| in the broker main thread. MetaTrader Terminal does not support  |
//| thread creation. So we split the broker and worker code to two   |
//| scripts. Since we splitted the code, we need to wait all workers |
//| connect.                                                         |
//| This is the worker part.                                         |
//| For the worker, we can use either ZMQ_REQ or ZMQ_DEALER, the     |
//| difference is minimal. When using a dealer socket, remember to   |
//| send an empty frame to emulate the REQ behavior.                 |
//+------------------------------------------------------------------+

#define within(num) (int) ((float) num * MathRand() / (32767 + 1.0))

input string InpWorkerIdentity="worker1";
//+------------------------------------------------------------------+
//| Custom routing Router to Mama (ROUTER to REQ) (adapted from C++) |
//| The worker                                                       |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- use inproc
   Context context("rtreq");
   Socket worker(context,ZMQ_REQ);
//---  We use a string identity for ease here
   worker.setIdentity(InpWorkerIdentity);
   worker.connect("inproc://rtreq");

   ZmqMsg msg("Connect!");
   worker.send(msg);
   worker.recv(msg);
   Print(InpWorkerIdentity," connect: ",msg.getData());

   int total=0;
   while(!IsStopped())
     {
      //  Tell the broker we're ready for work
      worker.send("Hi Boss");

      //  Get workload from broker, until finished
      worker.recv(msg);
      string workload=msg.getData();
      if("Fired!"==workload)
        {
         Print(InpWorkerIdentity," is fired!");
         Print(InpWorkerIdentity," processed: ",total," tasks");
         break;
        }
      else
        {
         Print(InpWorkerIdentity," received work!");
        }
      total++;

      //  Do some random work
      Sleep(within(500)+1);
     }
  }
//+------------------------------------------------------------------+
