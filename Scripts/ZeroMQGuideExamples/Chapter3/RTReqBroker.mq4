//+------------------------------------------------------------------+
//|                                                  RTReqBroker.mq4 |
//|                                          Copyright 2017, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//| This example comes from the "Load Balancing Pattern"             |
//| The original example creates threads for workers and spawn them  |
//| in the broker main thread. MetaTrader Terminal does not support  |
//| thread creation. So we split the broker and worker code to two   |
//| scripts. Since we splitted the code, we need to wait all workers |
//| connect.                                                         |
//| This is the broker part.                                         |
//+------------------------------------------------------------------+
#include <Zmq/Zmq.mqh>
input int InpNumberWorkers=5;
//+------------------------------------------------------------------+
//| Custom routing Router to Mama (ROUTER to REQ) (adapted from C++) |
//| Olivier Chamoux <olivier.chamoux@fr.thalesgroup.com>             |
//+------------------------------------------------------------------+
void OnStart()
  {
   Context context("rtreq");
   Socket broker(context,ZMQ_ROUTER);
   broker.bind("inproc://rtreq");

   string identities[];
   ArrayResize(identities,InpNumberWorkers);
// Wait until InpNumberWorkers workers connected
   for(int i=0; i<InpNumberWorkers; i++)
     {
      ZmqMsg msg;
      broker.recv(msg);
      string identity=msg.getData();
      broker.recv(msg);     //  Envelope delimiter
      broker.recv(msg);     //  Response from worker
      identities[i]=identity;
      Print("Broker: Worker ",identity," connected.");
     }
   Print("Broker: All workers connected!");
// Notify all workers that it is ready to dispatch work
   for(int i=0; i<InpNumberWorkers; i++)
     {
      broker.sendMore(identities[i]);
      broker.sendMore();
      broker.send("Go!");
     }

//  Run for five seconds and then tell workers to end
   long endTime=TimeLocal()+5;
   int workersFired=0;
   while(!IsStopped())
     {
      ZmqMsg msg;
      //  Next message gives us least recently used worker
      broker.recv(msg);
      string identity=msg.getData();
      Print("Broker: Get available worker [",identity,"]");
      broker.recv(msg);     //  Envelope delimiter
      broker.recv(msg);     //  Response from worker
      Print("Broker: And he says ",msg.getData());

      if(!broker.sendMore(identity)) {Print("Error sending identity.");}
      if(!broker.sendMore("")) {Print("Error sending delimeter.");}
      //  Encourage workers until it's time to fire them
      if(TimeLocal()<endTime)
        {
         Print("Send work!");
         if(!broker.send("Work harder")) {Print("Error sending work.");}
        }
      else
        {
         Print("Send fire!");
         if(!broker.send("Fired!")) {Print("Error sending fired.");}
         if(++workersFired==InpNumberWorkers)
            break;
        }
     }
  }
//+------------------------------------------------------------------+
