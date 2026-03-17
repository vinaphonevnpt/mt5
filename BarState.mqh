//==============================================================
// BarState.mqh (DEBUG VERSION)
//==============================================================

#ifndef __BAR_STATE_MQH__
#define __BAR_STATE_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// GLOBAL
//==============================================================

datetime gLastBarTime = 0;


//==============================================================
// UPDATE BAR STATE
//==============================================================

void UpdateBarState()
{
   datetime currentBar = iTime(_Symbol,InpTimeframe,0);

   if(currentBar != gLastBarTime)
   {
      gLastBarTime = currentBar;

      LogTag("BAR","Nến mới xuất hiện");
   }
}


//==============================================================
// IS NEW BAR
//==============================================================

bool IsNewBar()
{
   datetime currentBar = iTime(_Symbol,InpTimeframe,0);

   if(currentBar != gLastBarTime)
      return true;

   return false;
}


//==============================================================
// SHOULD PROCESS TICK
//==============================================================

bool ShouldProcessTick()
{
   if(!InpTradeOnNewBar)
   {
      LogDebug("Chế độ tick: xử lý mọi tick");
      return true;
   }

   if(IsNewBar())
   {
      LogDebug("Chế độ new bar: xử lý nến mới");
      return true;
   }

   LogDebug("Bỏ qua tick (chưa có nến mới)");
   return false;
}


//==============================================================
// BAR AGE (SECONDS)
//==============================================================

int GetBarAgeSeconds()
{
   datetime now = TimeCurrent();
   datetime bar = iTime(_Symbol,InpTimeframe,0);

   return (int)(now - bar);
}


//==============================================================
// BAR PROGRESS
//==============================================================

double GetBarProgress()
{
   int period = PeriodSeconds(InpTimeframe);

   if(period <= 0)
      return 0;

   double progress = (double)GetBarAgeSeconds() / period;

   LogDebug(StringFormat("Tiến độ nến = %.2f",progress));

   return progress;
}


#endif