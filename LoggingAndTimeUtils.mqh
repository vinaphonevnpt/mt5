//==============================================================
// LoggingAndTimeUtils.mqh (FINAL DEBUG VERSION)
//==============================================================

#ifndef __LOGGING_TIME_UTILS_MQH__
#define __LOGGING_TIME_UTILS_MQH__

#include "ConfigurationInputs.mqh"

//==============================================================
// GLOBAL
//==============================================================

datetime gLastBlockLogTime = 0;
string   gLastBlockMessage = "";

//==============================================================
// TIMEZONE OFFSET
//==============================================================

int GetTimezoneOffsetHours(ENUM_DISPLAY_TIMEZONE tz)
{
   switch(tz)
   {
      case TZ_SERVER: return 0;
      case TZ_UTC:    return -TimeGMTOffset()/3600;
      case TZ_GMT:    return 0;
      case TZ_EST:    return -5;
      case TZ_CET:    return +1;
      case TZ_VN:     return +7;
   }
   return 0;
}


//==============================================================
// CONVERT TIME
//==============================================================

datetime ConvertServerTime(datetime serverTime)
{
   int offset = GetTimezoneOffsetHours(InpDisplayTimezone);
   return serverTime + offset * 3600;
}


//==============================================================
// FORMAT TIME STRING
//==============================================================

string GetDisplayTimeString()
{
   datetime t = ConvertServerTime(TimeCurrent());

   MqlDateTime s;
   TimeToStruct(t,s);

   return StringFormat("%02d:%02d:%02d",s.hour,s.min,s.sec);
}


//==============================================================
// PREFIX (NGẮN GỌN)
//==============================================================

string Prefix()
{
   return StringFormat("[%s]",_Symbol);
}


//==============================================================
// CORE PRINT
//==============================================================

void PrintLog(string level,string msg)
{
   Print(Prefix()," ",GetDisplayTimeString()," [",level,"] ",msg);
}


//==============================================================
// INFO LOG (LUÔN HIỂN THỊ)
//==============================================================

void Log(string msg)
{
   PrintLog("INFO",msg);
}


//==============================================================
// DEBUG LOG (PHỤ THUỘC INPUT)
//==============================================================

void LogDebug(string msg)
{
   if(!InpVerboseLogs)
      return;

   PrintLog("DEBUG",msg);
}


//==============================================================
// ERROR LOG
//==============================================================

void LogError(string msg)
{
   PrintLog("ERROR",msg);
}


//==============================================================
// TAG LOG
//==============================================================

void LogTag(string tag,string msg)
{
   Print(Prefix()," ",GetDisplayTimeString()," [",tag,"] ",msg);
}


//==============================================================
// ENTRY LOG
//==============================================================

void LogEntry(string type,double price,double lot)
{
   PrintLog("ENTRY",
      StringFormat("%s | Giá=%.2f | Lot=%.2f",
         type,
         price,
         lot));
}


//==============================================================
// EXIT LOG
//==============================================================

void LogExit(string type,double profit)
{
   PrintLog("EXIT",
      StringFormat("%s | Lợi nhuận=%.2f",
         type,
         profit));
}


//==============================================================
// ANTI-SPAM BLOCK LOG
//==============================================================

bool ShouldLogBlock(string msg)
{
   datetime now = TimeCurrent();

   if(msg == gLastBlockMessage && (now - gLastBlockLogTime) < 10)
      return false;

   gLastBlockMessage = msg;
   gLastBlockLogTime = now;

   return true;
}


//==============================================================
// BLOCK REASON
//==============================================================

void LogNoTradeReason(string reason)
{
   if(!InpEnableBlockLogs)
      return;

   if(!ShouldLogBlock(reason))
      return;

   PrintLog("BLOCK",reason);
}


//==============================================================
// QUICK TIME (HHMM)
//==============================================================

int HHMM(datetime t)
{
   MqlDateTime s;
   TimeToStruct(t,s);
   return s.hour*100 + s.min;
}


//==============================================================
// SHOULD LOG NO TRADE
//==============================================================

bool ShouldLogNoTrade()
{
   return InpEnableBlockLogs;
}


#endif