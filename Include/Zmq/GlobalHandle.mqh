//+------------------------------------------------------------------+
//|                                                 GlobalHandle.mqh |
//| This file is part of mql4-lib project (Lang/GlobalVariable.mqh): |
//| (github.com/dingmaotu/mql4-lib)                                  |
//|                                          Copyright 2017, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Wraps global variable functions                                  |
//+------------------------------------------------------------------+
class GlobalVariable
  {
public:
   static int        total() {return GlobalVariablesTotal();}
   static string     name(int index) {return GlobalVariableName(index);}
   static void       flush() {GlobalVariablesFlush();}

   static bool       exists(string name) {return GlobalVariableCheck(name);}
   static datetime   lastAccess(string name) {return GlobalVariableTime(name);}

   static bool       makeTemp(string name) {return GlobalVariableTemp(name);}
   static double     get(string name) {return GlobalVariableGet(name);}
   static bool       get(string name,double &value) {return GlobalVariableGet(name,value);}
   static datetime   set(string name,double value) {return GlobalVariableSet(name,value);}
   static bool       setOn(string name,double value,double check) {return GlobalVariableSetOnCondition(name,value,check);}

   static bool       remove(string name) {return GlobalVariableDel(name);}
   static bool       removeAll(string prefix=NULL,datetime before=0) {return GlobalVariablesDeleteAll(prefix,before);}
  };
//+------------------------------------------------------------------+
//| CriticalSection object for making atomic operations              |
//|                                                                  |
//| An exmaple of creating a global context (the creation and destroy|
//| are both enclosed between the SAME critical section):            |
//|                                                                  |
//| enter()                                                          |
//|   if(refcount==0) create context                                 |
//|   else refcontext                                                |
//|   increase refcount                                              |
//| leave()                                                          |
//|                                                                  |
//| enter()                                                          |
//|   decrease refcount                                              |
//|   if(refcount==0) context destroy                                |
//| leave()                                                          |
//+------------------------------------------------------------------+
class CriticalSection
  {
private:
   const string      m_name;
public:
                     CriticalSection(string name):m_name(name){}

   bool              isValid() const {return m_name!=NULL;}
   string            getName() const {return m_name;}

   void              enter() { while(!GlobalVariable::makeTemp(m_name) && !IsStopped())Sleep(100); }
   bool              tryEnter() { return GlobalVariable::makeTemp(m_name); }
   void              leave() { GlobalVariable::remove(m_name);}
  };
//+------------------------------------------------------------------+
//| A reference counted global pointer (or handle)                   |
//| HandleManager should implement 2 static methods: create & destroy|
//+------------------------------------------------------------------+
template<typename T,typename HandleManager>
class GlobalHandle
  {
private:
   CriticalSection   m_cs;
   string            m_refName;
   string            m_counterName;
protected:
   T                 m_ref;
public:
                     GlobalHandle(string sharedKey=NULL):m_cs(sharedKey)
     {
      m_refName=m_cs.getName()+"_Ref";
      m_counterName=m_cs.getName()+"_Count";
      if(!m_cs.isValid()) m_ref=HandleManager::create();
      else
        {
         m_cs.enter();
         if(!GlobalVariable::exists(m_counterName))
           {
            GlobalVariable::makeTemp(m_counterName);
            GlobalVariable::set(m_counterName,0);
           }
         if(long(GlobalVariable::get(m_counterName))==0)
           {
            m_ref=HandleManager::create();
            if(!GlobalVariable::exists(m_refName))
              {
               GlobalVariable::makeTemp(m_refName);
               GlobalVariable::set(m_refName,m_ref);
              }
           }
         else
           {
            m_ref=(T)(GlobalVariable::get(m_refName));
           }
         GlobalVariable::set(m_counterName,GlobalVariable::get(m_counterName)+1);
         m_cs.leave();
        }
     }
                    ~GlobalHandle()
     {
      if(!m_cs.isValid()) {HandleManager::destroy(m_ref); return;}
      m_cs.enter();
      GlobalVariable::set(m_counterName,GlobalVariable::get(m_counterName)-1);
      if(long(GlobalVariable::get(m_counterName))==0)
        {
         HandleManager::destroy(m_ref);
         GlobalVariable::remove(m_refName);
         GlobalVariable::remove(m_counterName);
        }
      m_cs.leave();
     }

   T                 ref() const {return m_ref;}
  };
//+------------------------------------------------------------------+
