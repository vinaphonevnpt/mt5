//==============================================================
// SessionAndTimeFilter.mqh
// SESSION FILTER (MQL5 FINAL FIX)
//==============================================================

#ifndef __SESSION_TIME_FILTER_MQH__
#define __SESSION_TIME_FILTER_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// RUNTIME VARIABLES (KHÔNG SỬA INPUT)
//==============================================================

double gSessionRSIBuy  = 0;
double gSessionRSISell = 0;

//==============================================================
// GET CURRENT TIME SAFE (MQL5)
//==============================================================

void GetCurrentTime(int &hour,int &minute)
{
   MqlDateTime t;
   TimeToStruct(TimeCurrent(),t);

   hour   = t.hour;
   minute = t.min;
}

//==============================================================
// SESSION DETECTION
//==============================================================

bool IsAsiaSession()
{
   int h,m;
   GetCurrentTime(h,m);

   return (h < InpEUSessionStartHour);
}

//--------------------------------------------------------------

bool IsEUSession()
{
   int h,m;
   GetCurrentTime(h,m);

   return (h >= InpEUSessionStartHour && h < InpUSSessionStartHour);
}

//--------------------------------------------------------------

bool IsUSSession()
{
   int h,m;
   GetCurrentTime(h,m);

   return (h >= InpUSSessionStartHour && h <= InpUSSessionEndHour);
}

//==============================================================
// SESSION ACTIVE
//==============================================================

bool IsSmartSessionActive()
{
   return (IsEUSession() || IsUSSession());
}

//==============================================================
// APPLY SESSION ADAPTIVE (SAFE)
//==============================================================

void ApplySessionAdaptiveParameters()
{
   // reset từ input
   gSessionRSIBuy  = InpTrendTight_RSI_BuyMin;
   gSessionRSISell = InpTrendTight_RSI_SellMax;

   if(IsAsiaSession())
   {
      Log("🌏 Phiên Á → nới điều kiện");

      gSessionRSIBuy  *= 0.95;
      gSessionRSISell *= 1.05;
   }
   else if(IsUSSession())
   {
      Log("🇺🇸 Phiên US → siết điều kiện");

      gSessionRSIBuy  *= 1.05;
      gSessionRSISell *= 0.95;
   }
   else
   {
      Log("🇪🇺 Phiên EU → điều kiện chuẩn");
   }

   //===========================================================
   // CLAMP SAFE
   //===========================================================

   if(gSessionRSIBuy < 44) gSessionRSIBuy = 44;
   if(gSessionRSIBuy > 54) gSessionRSIBuy = 54;

   if(gSessionRSISell < 46) gSessionRSISell = 46;
   if(gSessionRSISell > 56) gSessionRSISell = 56;
}

//==============================================================
// TIME FILTER
//==============================================================

bool IsWithinTradingHours()
{
   if(!InpUseTimeFilter)
      return true;

   int h,m;
   GetCurrentTime(h,m);

   if(h < InpTradeStartHour || h > InpTradeEndHour)
   {
      Log("❌ Ngoài giờ giao dịch");
      return false;
   }

   return true;
}

//==============================================================
// BLOCK BEFORE SESSION
//==============================================================

bool NextAllowedTradeTime_PreSession()
{
   if(!InpBlockBeforeSessions)
      return false;

   int h,m;
   GetCurrentTime(h,m);

   int nowMin = h*60 + m;

   int euStart = InpEUSessionStartHour * 60;
   int usStart = InpUSSessionStartHour * 60;

   if(MathAbs(nowMin - euStart) <= InpBlockBeforeEU_Min)
   {
      Log("⛔ Block trước phiên EU");
      return true;
   }

   if(MathAbs(nowMin - usStart) <= InpBlockBeforeUS_Min)
   {
      Log("⛔ Block trước phiên US");
      return true;
   }

   return false;
}

//==============================================================
// NEWS BLOCK (LIGHT CHECK)
//==============================================================

bool NextAllowedTradeTime_News()
{
   if(!InpBlockAroundNews)
      return false;

   if(StringLen(InpHighImpactNewsTimes) > 0)
   {
      Log("⛔ Block do cấu hình giờ tin");
      return true;
   }

   return false;
}

#endif