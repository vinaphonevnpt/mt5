//==============================================================
// MLAndONNX.mqh (DEBUG VERSION)
//==============================================================

#ifndef __ML_ONNX_MQH__
#define __ML_ONNX_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"
#include "IndicatorCache.mqh"
#include "TrendAndMTFAnalysis.mqh"

//==============================================================
// ML PREDICT BUY (CORE)
//==============================================================

double MLPredictBuy()
{
   if(!InpUseMLFilter)
      return 1.0;

   double score = 0.0;

   // Trend weight
   int trend = GetEMATrendDir();
   if(trend == 1)
      score += InpMLTrendWeight;

   // Momentum (RSI)
   double rsi = GetRSI();
   if(rsi > 50)
      score += InpMLMomentumWeight;

   // Volatility
   double atr = GetATR();
   if(atr > InpLowATRRangeThreshold)
      score += InpMLVolWeight;

   // MTF alignment
   if(IsMTFAligned(true))
      score += InpMLMTFWeight;

   // Price Action (giả lập)
   score += InpMLPAWeight * 0.5;

   LogDebug(StringFormat("ML Score BUY = %.2f",score));

   return score;
}


//==============================================================
// MAX EXCURSION PREDICTION
//==============================================================

double PredictMaxExcursion()
{
   double atr = GetATR();

   double excursion = atr * 2.5;

   LogDebug(StringFormat("ML Excursion = %.2f",excursion));

   return excursion;
}


//==============================================================
// APPLY ML TP
//==============================================================

double ApplyMLExcursionTP(double baseTP)
{
   double mlTP = PredictMaxExcursion();

   double finalTP = MathMax(baseTP,mlTP);

   LogDebug(StringFormat("TP điều chỉnh ML: %.2f -> %.2f",
      baseTP,finalTP));

   return finalTP;
}


//==============================================================
// CORRELATION (GIẢ LẬP)
//==============================================================

double GetRealCorrelation()
{
   double corr = 0.65;

   LogDebug(StringFormat("Correlation = %.2f",corr));

   return corr;
}


//==============================================================
// INIT MODEL (PLACEHOLDER)
//==============================================================

bool InitExcursionModel()
{
   Log("Khởi tạo ML model (giả lập)");

   return true;
}


//==============================================================
// RELEASE MODEL
//==============================================================

void ReleaseExcursionModel()
{
   Log("Giải phóng ML model");
}


#endif