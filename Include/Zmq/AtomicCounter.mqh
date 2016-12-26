//+------------------------------------------------------------------+
//|                                                AtomicCounter.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Common.mqh"

#import "libzmq.dll"
intptr_t zmq_atomic_counter_new(void);
void zmq_atomic_counter_set(intptr_t counter,int value);
int zmq_atomic_counter_inc(intptr_t counter);
int zmq_atomic_counter_dec(intptr_t counter);
int zmq_atomic_counter_value(intptr_t counter);
void zmq_atomic_counter_destroy(intptr_t &counter_p);
#import
//+------------------------------------------------------------------+
//| Atomic counter utility                                           |
//+------------------------------------------------------------------+
class AtomicCounter
  {
private:
   intptr_t          m_ref;

public:
                     AtomicCounter() {m_ref=zmq_atomic_counter_new();}
                    ~AtomicCounter() {zmq_atomic_counter_destroy(m_ref);}

   int               increase() {return zmq_atomic_counter_inc(m_ref);}
   int               decrease() {return zmq_atomic_counter_dec(m_ref);}
   int               get() {return zmq_atomic_counter_value(m_ref);}
   void              set(int value) {zmq_atomic_counter_set(m_ref,value);}
  };
//+------------------------------------------------------------------+
