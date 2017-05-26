//+------------------------------------------------------------------+
//|                                      WeatherUpdateServer.mq4.mq4 |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict

#include <Zmq/Zmq.mqh>

#define within(num) (int) ((float) num * MathRand() / (32767 + 1.0))
//+------------------------------------------------------------------+
//| Weather update server in MQL                                     |
//| Binds PUB socket to tcp://*:5556                                 |
//| Publishes random weather updates                                 |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Prepare our context and publisher
   Context context;
   Socket publisher(context,ZMQ_PUB);
   publisher.bind("tcp://*:5556");

   long messages_sent=0;
//--- Initialize random number generator
   MathSrand(GetTickCount());
   while(!IsStopped())
     {
      int zipcode,temperature,relhumidity;

      // Get values that will fool the boss

      // MetaTrader Note:
      // if RAND_MAX < 100000, which is the case for MetaTrader, 
      // you may never get the required value
      // So 30000 might be a good alternative
      zipcode=within(30000);
      temperature=within(215) - 80;
      relhumidity=within(50) + 10;

      // Send message to all subscribers
      ZmqMsg message(StringFormat("%05d %d %d",zipcode,temperature,relhumidity));
      publisher.send(message);
      messages_sent++;

      if(messages_sent%1000000==0)
        {
         PrintFormat("Sent %dM messages now.",messages_sent/1000000);
        }
     }
  }
//+------------------------------------------------------------------+
