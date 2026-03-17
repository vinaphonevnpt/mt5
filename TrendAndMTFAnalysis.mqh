//==============================================================
// TrendAndMTFAnalysis.mqh
// TREND + MTF ANALYSIS (MQL5 FIXED VERSION)
//==============================================================

#ifndef __TREND_MTF_ANALYSIS_MQH__
#define __TREND_MTF_ANALYSIS_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// GENERIC EMA (MQL5 SAFE)
//==============================================================

double GetEMA(ENUM_TIMEFRAMES tf,int period)
{
   int handle = iMA(_Symbol,tf,period,0,InpMAMethod,InpMAPrice);

   if(handle == INVALID_HANDLE)
   {
      Log("❌ Lỗi tạo handle EMA");
      return 0;
   }

   double buffer[];

   if(CopyBuffer(handle,0,0,1,buffer) <= 0)
   {
      Log("❌ CopyBuffer EMA fail");
      return 0;
   }

   return buffer[0];
}

//==============================================================
// CURRENT TF EMA
//==============================================================

double GetFastEMA()
{
   return GetEMA(_Period,InpFastMAPeriod);
}

double GetSlowEMA()
{
   return GetEMA(_Period,InpSlowMAPeriod);
}

//==============================================================
// MTF TREND
//==============================================================

int GetMTFTrend()
{
   if(!InpUseStrictMTF)
      return GetTrendDirection();

   double fastH = GetEMA(InpMTF_HigherTF,InpFastMAPeriod);
   double slowH = GetEMA(InpMTF_HigherTF,InpSlowMAPeriod);

   double fastM = GetEMA(InpMTF_MidTF,InpFastMAPeriod);
   double slowM = GetEMA(InpMTF_MidTF,InpSlowMAPeriod);

   int dirH = (fastH > slowH) ? 1 : (fastH < slowH ? -1 : 0);
   int dirM = (fastM > slowM) ? 1 : (fastM < slowM ? -1 : 0);

   if(dirH == dirM)
      return dirH;

   return 0;
}

//==============================================================
// EMA CROSS DETECTION
//==============================================================

bool recentCrossUp(int lookback=3)
{
   for(int i=1;i<=lookback;i++)
   {
      double fastPrev = iMA(_Symbol,_Period,InpFastMAPeriod,0,InpMAMethod,InpMAPrice,i);
      double slowPrev = iMA(_Symbol,_Period,InpSlowMAPeriod,0,InpMAMethod,InpMAPrice,i);

      double fastNow  = iMA(_Symbol,_Period,InpFastMAPeriod,0,InpMAMethod,InpMAPrice,i-1);
      double slowNow  = iMA(_Symbol,_Period,InpSlowMAPeriod,0,InpMAMethod,InpMAPrice,i-1);

      if(fastPrev < slowPrev && fastNow > slowNow)
         return true;
   }

   return false;
}

//--------------------------------------------------------------

bool recentCrossDown(int lookback=3)
{
   for(int i=1;i<=lookback;i++)
   {
      double fastPrev = iMA(_Symbol,_Period,InpFastMAPeriod,0,InpMAMethod,InpMAPrice,i);
      double slowPrev = iMA(_Symbol,_Period,InpSlowMAPeriod,0,InpMAMethod,InpMAPrice,i);

      double fastNow  = iMA(_Symbol,_Period,InpFastMAPeriod,0,InpMAMethod,InpMAPrice,i-1);
      double slowNow  = iMA(_Symbol,_Period,InpSlowMAPeriod,0,InpMAMethod,InpMAPrice,i-1);

      if(fastPrev > slowPrev && fastNow < slowNow)
         return true;
   }

   return false;
}

//==============================================================
// HEIKEN ASHI (SIMPLE)
//==============================================================

bool IsBullishHeikenAshi()
{
   double close = iClose(_Symbol,_Period,0);
   double open  = iOpen(_Symbol,_Period,0);

   return (close > open);
}

//==============================================================
// FVG (GIỮ Ở MODULE NÀY - KHÔNG TRÙNG)
//==============================================================

bool DetectBullishFVG()
{
   double high2 = iHigh(_Symbol,_Period,2);
   double low0  = iLow(_Symbol,_Period,0);

   if(low0 > high2)
   {
      Log("📊 Bullish FVG");
      return true;
   }

   return false;
}

//--------------------------------------------------------------

bool DetectBearishFVG()
{
   double low2  = iLow(_Symbol,_Period,2);
   double high0 = iHigh(_Symbol,_Period,0);

   if(high0 < low2)
   {
      Log("📊 Bearish FVG");
      return true;
   }

   return false;
}

#endif