//==============================================================
// ExecutionEngine.mqh
// FINAL ORCHESTRATOR (INSTITUTIONAL)
//==============================================================

#ifndef __EXECUTION_ENGINE_MQH__
#define __EXECUTION_ENGINE_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"
#include "BarState.mqh"
#include "IndicatorCache.mqh"
#include "SessionAndTimeFilter.mqh"
#include "NewsAndSentiment.mqh"
#include "RiskManagementAndExit.mqh"
#include "SignalCore.mqh"
#include "InstitutionalSMC.mqh"
#include "TradeManager.mqh"

//==============================================================
// GLOBAL STATE
//==============================================================

datetime gLastTradeTime = 0;

//==============================================================
// ENTRY COOLDOWN
//==============================================================

bool IsEntryCooldownOK()
{
   datetime now = TimeCurrent();

   if((now - gLastTradeTime) < InpMinSecondsBetweenEntries)
   {
      Log("⏳ Chưa đủ thời gian giữa 2 lệnh");
      return false;
   }

   return true;
}

//==============================================================
// POSITION LIMIT CHECK
//==============================================================

bool IsPositionAllowed()
{
   if(InpOnePositionPerSymbol && PositionsTotal() > 0)
   {
      Log("❌ Đã có position → không mở thêm");
      return false;
   }

   if(PositionsTotal() >= InpMaxOpenPositions)
   {
      Log("❌ Đạt max positions");
      return false;
   }

   return true;
}

//==============================================================
// MAIN EXECUTION
//==============================================================

void EvaluateSignals()
{
   Log("===== 🔄 EXECUTION LOOP =====");

   //===========================================================
   // 1. BAR FILTER
   //===========================================================

   UpdateBarState();

   if(InpTradeOnNewBar && !IsNewBar())
   {
      Log("⏸ Chờ nến mới");
      return;
   }

   //===========================================================
   // 2. SESSION FILTER
   //===========================================================

   if(!IsWithinTradingHours())
      return;

   if(NextAllowedTradeTime_PreSession())
      return;

   //===========================================================
   // 3. NEWS FILTER
   //===========================================================

   if(CheckNewsBlock())
   {
      Log("📰 Bị chặn bởi news");
      return;
   }

   //===========================================================
   // 4. RISK CHECK
   //===========================================================

   if(!IsDrawdownSafe())
      return;

   if(!IsEntryCooldownOK())
      return;

   if(!IsPositionAllowed())
      return;

   //===========================================================
   // 5. SESSION ADAPTIVE
   //===========================================================

   ApplySessionAdaptiveParameters();

   //===========================================================
   // 6. SIGNAL CHECK
   //===========================================================

   bool buySignal  = CheckBuySignal();
   bool sellSignal = CheckSellSignal();

   //===========================================================
   // 7. SMC CONFIRMATION
   //===========================================================

   if(buySignal)
   {
      double smc = GetInstitutionalScore(true);

      if(smc < 0.4)
      {
         Log("❌ BUY bị từ chối bởi SMC");
         buySignal = false;
      }
   }

   if(sellSignal)
   {
      double smc = GetInstitutionalScore(false);

      if(smc < 0.4)
      {
         Log("❌ SELL bị từ chối bởi SMC");
         sellSignal = false;
      }
   }

   //===========================================================
   // 8. EXECUTE TRADE
   //===========================================================

   if(buySignal)
   {
      Log("🚀 EXECUTE BUY");

      if(OpenBuy())
         gLastTradeTime = TimeCurrent();
   }
   else if(sellSignal)
   {
      Log("🚀 EXECUTE SELL");

      if(OpenSell())
         gLastTradeTime = TimeCurrent();
   }
   else
   {
      if(InpLogNoSignal)
         Log("❌ Không có tín hiệu hợp lệ");
   }
}

#endif