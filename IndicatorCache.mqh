//==============================================================
// IndicatorCache.mqh
// CACHE INDICATOR CHUẨN MQL5 (FINAL FIX)
//==============================================================

#ifndef __INDICATOR_CACHE_MQH__
#define __INDICATOR_CACHE_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// HANDLES
//==============================================================

int hEMA_Fast;
int hEMA_Slow;
int hRSI;
int hATR;
int hADX;
int hStoch;

//==============================================================
// INIT
//==============================================================

bool InitIndicatorCache()
{
   Log("Khởi tạo Indicator Cache...");

   hEMA_Fast = iMA(_Symbol,InpTimeframe,InpFastMAPeriod,0,InpMAMethod,InpMAPrice);
   hEMA_Slow = iMA(_Symbol,InpTimeframe,InpSlowMAPeriod,0,InpMAMethod,InpMAPrice);
   hRSI      = iRSI(_Symbol,InpTimeframe,InpRSIPeriod,InpMAPrice);
   hATR      = iATR(_Symbol,InpTimeframe,InpATRPeriod);
   hADX      = iADX(_Symbol,InpTimeframe,InpADXPeriod);
   hStoch    = iStochastic(_Symbol,InpTimeframe,
                          InpStochK,
                          InpStochD,
                          InpStochSlowing,
                          MODE_SMA,
                          STO_LOWHIGH);

   if(hEMA_Fast==INVALID_HANDLE ||
      hEMA_Slow==INVALID_HANDLE ||
      hRSI==INVALID_HANDLE ||
      hATR==INVALID_HANDLE ||
      hADX==INVALID_HANDLE ||
      hStoch==INVALID_HANDLE)
   {
      LogError("Lỗi tạo indicator handle");
      return false;
   }

   Log("Indicator Cache OK");
   return true;
}

//==============================================================
// RELEASE
//==============================================================

void ReleaseIndicatorCache()
{
   IndicatorRelease(hEMA_Fast);
   IndicatorRelease(hEMA_Slow);
   IndicatorRelease(hRSI);
   IndicatorRelease(hATR);
   IndicatorRelease(hADX);
   IndicatorRelease(hStoch);

   Log("Đã giải phóng Indicator Cache");
}

//==============================================================
// CORE
//==============================================================

double GetBufferValue(int handle,int buffer,int shift)
{
   double data[];

   if(CopyBuffer(handle,buffer,shift,1,data)<=0)
   {
      LogError("CopyBuffer lỗi");
      return 0;
   }

   return data[0];
}

//==============================================================
// EMA
//==============================================================

double GetEMAFast(int shift=0)
{
   return GetBufferValue(hEMA_Fast,0,shift);
}

double GetEMASlow(int shift=0)
{
   return GetBufferValue(hEMA_Slow,0,shift);
}

//==============================================================
// RSI
//==============================================================

double GetRSI(int shift=0)
{
   return GetBufferValue(hRSI,0,shift);
}

//==============================================================
// ATR
//==============================================================

double GetATR(int shift=0)
{
   return GetBufferValue(hATR,0,shift);
}

//==============================================================
// ADX
//==============================================================

double GetADX(int shift=0)
{
   return GetBufferValue(hADX,0,shift);
}

//==============================================================
// STOCH
//==============================================================

double GetStochK(int shift=0)
{
   return GetBufferValue(hStoch,0,shift);
}

double GetStochD(int shift=0)
{
   return GetBufferValue(hStoch,1,shift);
}

//==============================================================
// REGIME
//==============================================================

int GetVolatilityRegime()
{
   double atr = GetATR();

   if(atr >= InpATRHighThreshold)
      return 2;

   if(atr <= InpLowATRRangeThreshold)
      return 0;

   return 1;
}

//==============================================================
// TREND
//==============================================================

int GetTrendDirection()
{
   double fast = GetEMAFast();
   double slow = GetEMASlow();

   if(fast > slow) return 1;
   if(fast < slow) return -1;

   return 0;
}

#endif