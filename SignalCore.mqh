//==============================================================
// SignalCore.mqh
// FINAL SIGNAL ENGINE (FIXED - NO MISSING FUNCTIONS)
//==============================================================

#ifndef __SIGNAL_CORE_MQH__
#define __SIGNAL_CORE_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"
#include "IndicatorCache.mqh"
#include "TrendAndMTFAnalysis.mqh"

//==============================================================
// ML PREDICT (PLACEHOLDER - SAFE)
//==============================================================

double MLPredict(bool isBuy)
{
   // Placeholder đơn giản (có thể thay ONNX sau)
   double rsi = GetRSI();

   if(isBuy)
      return (rsi > 50) ? 0.65 : 0.45;
   else
      return (rsi < 50) ? 0.65 : 0.45;
}

//==============================================================
// STOCHASTIC (MQL5 SAFE)
//==============================================================

double GetStochMain()
{
   int handle = iStochastic(_Symbol,_Period,
                           5,3,3,
                           MODE_SMA,
                           STO_LOWHIGH);

   if(handle == INVALID_HANDLE)
   {
      Log("❌ Lỗi handle Stochastic");
      return 50;
   }

   double buffer[];

   if(CopyBuffer(handle,0,0,1,buffer) <= 0)
   {
      Log("❌ CopyBuffer Stoch fail");
      return 50;
   }

   return buffer[0];
}

//==============================================================
// RSI FILTER
//==============================================================

bool RSIFilter(bool isBuy)
{
   double rsi = GetRSI();

   if(isBuy && rsi < InpRSIOversold)
   {
      Log("❌ RSI không đủ điều kiện BUY");
      return false;
   }

   if(!isBuy && rsi > InpRSIOverbought)
   {
      Log("❌ RSI không đủ điều kiện SELL");
      return false;
   }

   return true;
}

//==============================================================
// STOCH FILTER
//==============================================================

bool StochFilter(bool isBuy)
{
   if(!InpUseStochFilter)
      return true;

   double k = GetStochMain();

   if(isBuy && k < InpTF_StochBuy_MinK)
   {
      Log("❌ Stoch BUY fail");
      return false;
   }

   if(!isBuy && k > InpTF_StochSell_MaxK)
   {
      Log("❌ Stoch SELL fail");
      return false;
   }

   return true;
}

//==============================================================
// MTF FILTER
//==============================================================

bool MTFFilter(bool isBuy)
{
   if(!InpUseStrictMTF)
      return true;

   int dir = GetMTFTrend();

   if(isBuy && dir < 0)
   {
      Log("❌ MTF không ủng hộ BUY");
      return false;
   }

   if(!isBuy && dir > 0)
   {
      Log("❌ MTF không ủng hộ SELL");
      return false;
   }

   return true;
}

//==============================================================
// ML FILTER
//==============================================================

bool MLFilter(bool isBuy)
{
   if(!InpUseMLFilter)
      return true;

   double score = MLPredict(isBuy);

   if(isBuy && score < InpMLScoreThreshold_Buy)
   {
      Log("❌ ML từ chối BUY");
      return false;
   }

   if(!isBuy && score < InpMLScoreThreshold_Sell)
   {
      Log("❌ ML từ chối SELL");
      return false;
   }

   return true;
}

//==============================================================
// SCORE SYSTEM
//==============================================================

double CalculateSignalScore(bool isBuy)
{
   double score = 0;

   int trend = GetTrendDirection();

   if((isBuy && trend > 0) || (!isBuy && trend < 0))
      score += InpMLTrendWeight;

   double rsi = GetRSI();

   if((isBuy && rsi > 50) || (!isBuy && rsi < 50))
      score += InpMLMomentumWeight;

   double atr = GetATR();

   if(atr > InpLowATRRangeThreshold)
      score += InpMLVolWeight;

   if(GetMTFTrend() == trend)
      score += InpMLMTFWeight;

   score += InpMLPAWeight * 0.5;

   return score;
}

//==============================================================
// BUY SIGNAL
//==============================================================

bool CheckBuySignal()
{
   Log("🔍 Kiểm tra BUY");

   if(!MTFFilter(true))  return false;
   if(!RSIFilter(true))  return false;
   if(!StochFilter(true))return false;
   if(!MLFilter(true))   return false;

   double score = CalculateSignalScore(true);

   if(score < 0.5)
   {
      Log("❌ Score BUY thấp");
      return false;
   }

   Log("🚀 BUY hợp lệ");
   return true;
}

//==============================================================
// SELL SIGNAL
//==============================================================

bool CheckSellSignal()
{
   Log("🔍 Kiểm tra SELL");

   if(!MTFFilter(false))  return false;
   if(!RSIFilter(false))  return false;
   if(!StochFilter(false))return false;
   if(!MLFilter(false))   return false;

   double score = CalculateSignalScore(false);

   if(score < 0.5)
   {
      Log("❌ Score SELL thấp");
      return false;
   }

   Log("🚀 SELL hợp lệ");
   return true;
}

#endif