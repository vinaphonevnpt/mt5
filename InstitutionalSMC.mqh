//==============================================================
// InstitutionalSMC.mqh
// SMART MONEY CONCEPTS ENGINE (FIXED - NO DUPLICATE)
//==============================================================

#ifndef __INSTITUTIONAL_SMC_MQH__
#define __INSTITUTIONAL_SMC_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// LIQUIDITY SWEEP
//==============================================================

bool DetectLiquiditySweepBuy()
{
   double prevLow1 = iLow(_Symbol,_Period,1);
   double prevLow2 = iLow(_Symbol,_Period,2);
   double currLow  = iLow(_Symbol,_Period,0);

   if(currLow < prevLow1 && currLow < prevLow2)
   {
      Log("💧 Sweep BUY (quét thanh khoản đáy)");
      return true;
   }

   return false;
}

//--------------------------------------------------------------

bool DetectLiquiditySweepSell()
{
   double prevHigh1 = iHigh(_Symbol,_Period,1);
   double prevHigh2 = iHigh(_Symbol,_Period,2);
   double currHigh  = iHigh(_Symbol,_Period,0);

   if(currHigh > prevHigh1 && currHigh > prevHigh2)
   {
      Log("💧 Sweep SELL (quét thanh khoản đỉnh)");
      return true;
   }

   return false;
}

//==============================================================
// ORDER BLOCK (SIMPLE INSTITUTIONAL)
//==============================================================

bool DetectBullishOrderBlock()
{
   double open1  = iOpen(_Symbol,_Period,1);
   double close1 = iClose(_Symbol,_Period,1);
   double low0   = iLow(_Symbol,_Period,0);

   // Nến trước là bearish → OB
   if(close1 < open1 && low0 > open1)
   {
      Log("🏦 Bullish Order Block");
      return true;
   }

   return false;
}

//--------------------------------------------------------------

bool DetectBearishOrderBlock()
{
   double open1  = iOpen(_Symbol,_Period,1);
   double close1 = iClose(_Symbol,_Period,1);
   double high0  = iHigh(_Symbol,_Period,0);

   // Nến trước là bullish → OB
   if(close1 > open1 && high0 < open1)
   {
      Log("🏦 Bearish Order Block");
      return true;
   }

   return false;
}

//==============================================================
// LIQUIDITY CLUSTER
//==============================================================

bool DetectLiquidityCluster()
{
   double high1 = iHigh(_Symbol,_Period,1);
   double low1  = iLow(_Symbol,_Period,1);

   double range = high1 - low1;

   if(range < 5 * _Point)
   {
      Log("📦 Liquidity Cluster (sideway tích lũy)");
      return true;
   }

   return false;
}

//==============================================================
// INSTITUTIONAL SCORE
//==============================================================

double GetInstitutionalScore(bool isBuy)
{
   double score = 0.0;

   if(isBuy)
   {
      if(DetectLiquiditySweepBuy()) score += 0.4;
      if(DetectBullishOrderBlock()) score += 0.4;
   }
   else
   {
      if(DetectLiquiditySweepSell()) score += 0.4;
      if(DetectBearishOrderBlock())  score += 0.4;
   }

   if(DetectLiquidityCluster()) score += 0.2;

   Log("📊 SMC Score = " + DoubleToString(score,2));

   return score;
}

//==============================================================
// DEBUG
//==============================================================

void PrintSmartMoneyDiagnostics()
{
   Log("===== DEBUG SMC =====");

   DetectLiquiditySweepBuy();
   DetectLiquiditySweepSell();

   DetectBullishOrderBlock();
   DetectBearishOrderBlock();

   DetectLiquidityCluster();
}

#endif