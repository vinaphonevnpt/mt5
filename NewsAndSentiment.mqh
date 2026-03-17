//==============================================================
// NewsAndSentiment.mqh
// NEWS + SENTIMENT ENGINE (MQL5 FINAL FIX)
//==============================================================

#ifndef __NEWS_SENTIMENT_MQH__
#define __NEWS_SENTIMENT_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// TIME SAFE (MQL5)
//==============================================================

void GetCurrentTimeStruct(MqlDateTime &t)
{
   TimeToStruct(TimeCurrent(),t);
}

//==============================================================
// PARSE MANUAL NEWS TIME
//==============================================================

bool IsInManualNewsWindow()
{
   if(StringLen(InpHighImpactNewsTimes) < 4)
      return false;

   MqlDateTime t;
   GetCurrentTimeStruct(t);

   int nowMin = t.hour * 60 + t.min;

   string arr[];
   int count = StringSplit(InpHighImpactNewsTimes,';',arr);

   for(int i=0;i<count;i++)
   {
      string s = arr[i];

      int pos = StringFind(s,":");
      if(pos < 0) continue;

      int h = (int)StringToInteger(StringSubstr(s,0,pos));
      int m = (int)StringToInteger(StringSubstr(s,pos+1));

      int newsMin = h*60 + m;

      if(MathAbs(nowMin - newsMin) <= InpNewsBlockBefore_Min)
      {
         Log("📰 Đang trong vùng tin manual");
         return true;
      }
   }

   return false;
}

//==============================================================
// MT5 CALENDAR (SAFE)
//==============================================================

bool IsHighImpactNewsSoon()
{
   if(!InpUseMT5DynamicNewsFilter)
      return false;

   datetime now = TimeCurrent();

   MqlCalendarValue values[];

   int total = CalendarValueHistory(values,
                                    now,
                                    now + InpNewsBlockBefore_Min * 60);

   for(int i=0;i<total;i++)
   {
      int imp = values[i].importance;

      if(imp >= 2)
      {
         Log("📰 Có tin impact cao sắp ra");
         return true;
      }
   }

   return false;
}

//==============================================================
// MAIN NEWS BLOCK
//==============================================================

bool CheckNewsBlock()
{
   if(!InpBlockAroundNews)
      return false;

   if(IsInManualNewsWindow())
      return true;

   if(IsHighImpactNewsSoon())
      return true;

   return false;
}

//==============================================================
// RSI (MQL5 SAFE)
//==============================================================

double GetRSI_ForSentiment()
{
   int handle = iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);

   if(handle == INVALID_HANDLE)
   {
      Log("❌ RSI handle lỗi");
      return 50;
   }

   double buf[];

   if(CopyBuffer(handle,0,0,1,buf) <= 0)
   {
      Log("❌ CopyBuffer RSI fail");
      return 50;
   }

   return buf[0];
}

//==============================================================
// SENTIMENT ENGINE
//==============================================================

double GetMarketSentiment()
{
   double rsi = GetRSI_ForSentiment();

   if(rsi > 60)
      return 0.7;

   if(rsi < 40)
      return 0.3;

   return 0.5;
}

//==============================================================
// SENTIMENT FILTER
//==============================================================

bool SentimentFilter(bool isBuy)
{
   double s = GetMarketSentiment();

   if(isBuy && s < 0.4)
   {
      Log("❌ Sentiment không ủng hộ BUY");
      return false;
   }

   if(!isBuy && s > 0.6)
   {
      Log("❌ Sentiment không ủng hộ SELL");
      return false;
   }

   Log("✔ Sentiment OK: " + DoubleToString(s,2));
   return true;
}

#endif