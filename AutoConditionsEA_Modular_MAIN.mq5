//==============================================================
// AutoConditionsEA_Modular_MAIN.mq5
// FINAL VERSION - CLEAN ARCHITECTURE
//==============================================================

#property strict

//==============================================================
// INCLUDE ALL MODULES (THỨ TỰ QUAN TRỌNG)
//==============================================================

#include "ConfigurationInputs.mqh"

#include "LoggingAndTimeUtils.mqh"
#include "BarState.mqh"

#include "IndicatorCache.mqh"
#include "TrendAndMTFAnalysis.mqh"
#include "SignalCore.mqh"
#include "InstitutionalSMC.mqh"
#include "NewsAndSentiment.mqh"
#include "MLAndONNX.mqh"

#include "RiskManagementAndExit.mqh"
#include "SessionAndTimeFilter.mqh"

#include "TradeManager.mqh"
#include "ExecutionEngine.mqh"

//==============================================================
// INIT
//==============================================================

int OnInit()
{
   Log("🚀 EA INIT THÀNH CÔNG");

   // init indicator cache nếu có
   InitIndicatorCache();

   return(INIT_SUCCEEDED);
}

//==============================================================
// DEINIT
//==============================================================

void OnDeinit(const int reason)
{
   Log("🛑 EA STOP");
}

//==============================================================
// ON TICK
//==============================================================

void OnTick()
{
   //===========================================================
   // CORE EXECUTION FLOW
   //===========================================================

   EvaluateSignals();        // Entry logic
   ManageOpenPositions();    // Exit / trailing / BE

   //===========================================================
   // DEBUG (OPTIONAL)
   //===========================================================

   // PrintSmartMoneyDiagnostics(); // bật khi cần debug SMC
}

//==============================================================
// TRADE TRANSACTION (OPTIONAL DEBUG)
//==============================================================

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(InpVerboseLogs)
   {
      Log("📌 TradeTransaction | type=" + IntegerToString(trans.type));
   }
}