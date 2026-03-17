//==============================================================
// RiskManagementAndExit.mqh
// PROFESSIONAL EXIT & RISK ENGINE
//==============================================================

#ifndef __RISK_MANAGEMENT_EXIT_MQH__
#define __RISK_MANAGEMENT_EXIT_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"
#include "IndicatorCache.mqh"

//==============================================================
// GLOBAL TRACK
//==============================================================

double gPeakProfit = 0;

//==============================================================
// UPDATE PEAK PROFIT
//==============================================================

void UpdatePeakProfit()
{
   double total = AccountInfoDouble(ACCOUNT_PROFIT);

   if(total > gPeakProfit)
      gPeakProfit = total;
}

//==============================================================
// BREAK EVEN
//==============================================================

void ApplyBreakEvenLogic()
{
   if(!InpEnableBreakEven)
      return;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;

      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl    = PositionGetDouble(POSITION_SL);
      double profit= PositionGetDouble(POSITION_PROFIT);

      if(profit <= 0) continue;

      if(profit >= InpBE_RR_Trigger)
      {
         double newSL = entry + InpBE_OffsetPrice;

         if(sl < newSL)
         {
            ModifySL(ticket,newSL);
            Log("✔ Dời BE ticket=" + IntegerToString(ticket));
         }
      }
   }
}

//==============================================================
// TRAILING
//==============================================================

void ApplyTrailing()
{
   if(!InpUseTrailingStop)
      return;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;

      double profit = PositionGetDouble(POSITION_PROFIT);
      if(profit < InpTrailStartPrice) continue;

      double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double newSL = price - InpTrailStepPrice;

      ModifySL(ticket,newSL);

      Log("🔄 Trailing SL ticket=" + IntegerToString(ticket));
   }
}

//==============================================================
// PARTIAL CLOSE
//==============================================================

void ApplyPartialCloseLogic()
{
   if(!InpEnablePartialClose)
      return;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;

      double volume = PositionGetDouble(POSITION_VOLUME);
      double profit = PositionGetDouble(POSITION_PROFIT);

      if(profit < InpPartialClose_RR)
         continue;

      double closeLot = volume * InpPartialClose_Fraction;

      if(closeLot < InpPartialClose_MinLot)
         continue;

      ClosePartial(ticket,closeLot);

      Log("✂ Partial Close ticket=" + IntegerToString(ticket));
   }
}

//==============================================================
// PROFIT DROP EXIT
//==============================================================

bool CheckProfitDropExit()
{
   double current = AccountInfoDouble(ACCOUNT_PROFIT);

   if(gPeakProfit > 0 &&
      current < gPeakProfit * 0.8)
   {
      Log("⚠ Profit giảm >20% → đóng toàn bộ");
      return true;
   }

   return false;
}

//==============================================================
// DRAWDOWN GUARD
//==============================================================

bool IsDrawdownSafe()
{
   if(!InpEnableDrawdownGuard)
      return true;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   double dd = (balance - equity) / balance * 100;

   if(dd >= InpDrawdownPausePercent)
   {
      Log("❌ Drawdown vượt ngưỡng → dừng trade");
      return false;
   }

   if(dd >= InpDrawdownWarnPercent)
   {
      Log("⚠ Drawdown cao: " + DoubleToString(dd,1) + "%");
   }

   return true;
}

//==============================================================
// ADAPTIVE LOT
//==============================================================

double AdaptiveLot()
{
   double lot = InpFixedLot;

   if(!InpEnableDrawdownGuard)
      return lot;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   double dd = (balance - equity) / balance * 100;

   if(dd >= InpDrawdownWarnPercent)
   {
      lot = lot * (1.0 - InpDrawdownLotReducePercent/100.0);
   }

   return lot;
}

//==============================================================
// TP WITH VOLATILITY / ML
//==============================================================

double CalculateTPWithML(double entryPrice)
{
   double atr = GetATR();

   double tp = entryPrice + atr * InpVolatilityTPFactor;

   if(InpEnableVolatilityTPAdjust)
      return tp;

   return entryPrice + 5*_Point;
}

//==============================================================
// MODIFY SL
//==============================================================

void ModifySL(ulong ticket,double newSL)
{
   MqlTradeRequest req;
   MqlTradeResult res;

   ZeroMemory(req);
   ZeroMemory(res);

   req.action = TRADE_ACTION_SLTP;
   req.position = ticket;
   req.sl = newSL;

   if(!OrderSend(req,res))
      LogError("❌ Lỗi Modify SL");
}

//==============================================================
// CLOSE PARTIAL
//==============================================================

void ClosePartial(ulong ticket,double volume)
{
   MqlTradeRequest req;
   MqlTradeResult res;

   ZeroMemory(req);
   ZeroMemory(res);

   req.action   = TRADE_ACTION_DEAL;
   req.position = ticket;
   req.volume   = volume;
   req.symbol   = _Symbol;
   req.type     = ORDER_TYPE_SELL;

   OrderSend(req,res);
}

#endif