//+------------------------------------------------------------------+
//|                                                      Context.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+

#include "Common.mqh"
#include "SocketOptions.mqh"

//--- Context options
#define ZMQ_IO_THREADS 1
#define ZMQ_MAX_SOCKETS 2
#define ZMQ_SOCKET_LIMIT 3
#define ZMQ_THREAD_PRIORITY 3
#define ZMQ_THREAD_SCHED_POLICY 4
#define ZMQ_MAX_MSGSZ 5

//--- Default for new contexts
#define ZMQ_IO_THREADS_DFLT  1
#define ZMQ_MAX_SOCKETS_DFLT 1023
#define ZMQ_THREAD_PRIORITY_DFLT -1
#define ZMQ_THREAD_SCHED_POLICY_DFLT -1

#import "libzmq.dll"
intptr_t zmq_ctx_new(void);
int zmq_ctx_term(intptr_t context);
int zmq_ctx_shutdown(intptr_t context);
int zmq_ctx_set(intptr_t context,int option,int optval);
int zmq_ctx_get(intptr_t context,int option);
#import
//+------------------------------------------------------------------+
//| Wraps a 0MZ context                                              |
//+------------------------------------------------------------------+
class Context
  {
private:
   intptr_t          m_ref;
protected:
   int               get(int option) {return zmq_ctx_get(m_ref,option);}
   bool              set(int option,int optval) {return 0==zmq_ctx_set(m_ref,option,optval);}
public:
                     Context() {m_ref=zmq_ctx_new();}
                    ~Context() {if(0!=zmq_ctx_term(m_ref)){Debug("failed to terminate context");}}
   // for better cooperation between objects
   intptr_t          ref() const {return m_ref;}
   bool              shutdown() {return 0==zmq_ctx_shutdown(m_ref);}

   int               getIoThreads() {return get(ZMQ_IO_THREADS);}
   void              setIoThreads(int value) {if(!set(ZMQ_IO_THREADS,value)){Debug("failed to set ZMQ_IO_THREADS");}}

   int               getMaxSockets() {return get(ZMQ_MAX_SOCKETS);}
   void              setMaxSockets(int value) {if(!set(ZMQ_MAX_SOCKETS,value)){Debug("failed to set ZMQ_MAX_SOCKETS");}}

   int               getMaxMessageSize() {return get(ZMQ_MAX_MSGSZ);}
   void              setMaxMessageSize(int value) {if(!set(ZMQ_MAX_MSGSZ,value)){Debug("failed to set ZMQ_MAX_MSGSZ");}}

   int               getSocketLimit() {return get(ZMQ_SOCKET_LIMIT);}

   int               getIpv6Options() {return get(ZMQ_IPV6);}
   void              setIpv6Options(int value) {if(!set(ZMQ_IPV6,value)){Debug("failed to set ZMQ_IPV6");}}

   bool              isBlocky() {return 1==get(ZMQ_BLOCKY);}
   void              setBlocky(bool value) {if(!set(ZMQ_BLOCKY,value?1:0)){Debug("failed to set ZMQ_BLOCKY");}}

   //--- Following options is not supported on windows
   void              setSchedulingPolicy(int value) {/*ZMQ_THREAD_SCHED_POLICY*/}
   void              setThreadPriority(int value) {/*ZMQ_THREAD_PRIORITY*/}
  };
//+------------------------------------------------------------------+
