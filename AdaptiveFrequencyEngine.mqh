//==============================================================
// AdaptiveFrequencyEngine.mqh (LOGGING VERSION)
//==============================================================

#ifndef __ADAPTIVE_FREQUENCY_ENGINE_MQH__
#define __ADAPTIVE_FREQUENCY_ENGINE_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// GLOBAL STATE
//==============================================================

double gFreqSpreadMultiplier = 1.0;
double gFreqVolumeMultiplier = 1.0;
double gFreqMLThreshold = 0.58;
double gFreqAntiChase = 1.0;

bool gFreqAllowNewsTrade = false;
bool gFreqUseStrictMTF = true;
bool gFreqUseSRFilter = true;


//==============================================================
// SPREAD MULTIPLIER
//==============================================================

double GetAdaptiveSpreadMultiplier()
{
   switch(InpFrequencyMode)
   {
      case FREQ_HIGH:
         return 1.8;
      case FREQ_MED:
         return 1.4;
      default:
         return 1.0;
   }
}


//==============================================================
// VOLUME MULTIPLIER
//==============================================================

double GetAdaptiveVolumeMultiplier()
{
   switch(InpFrequencyMode)
   {
      case FREQ_HIGH:
         return 1.3;
      case FREQ_MED:
         return 1.15;
      default:
         return 1.0;
   }
}


//==============================================================
// ML THRESHOLD
//==============================================================

double GetAdaptiveMLThreshold()
{
   switch(InpFrequencyMode)
   {
      case FREQ_HIGH:
         return 0.42;
      case FREQ_MED:
         return 0.50;
      default:
         return 0.58;
   }
}


//==============================================================
// ANTI CHASE
//==============================================================

double GetAdaptiveAntiChase()
{
   switch(InpFrequencyMode)
   {
      case FREQ_HIGH:
         return 2.2;
      case FREQ_MED:
         return 1.5;
      default:
         return 1.0;
   }
}


//==============================================================
// FILTER FLAGS
//==============================================================

bool UsePriceActionConfirm()
{
   if(InpFrequencyMode == FREQ_HIGH)
      return false;

   return true;
}

bool UseTrendIndicators()
{
   if(InpFrequencyMode == FREQ_HIGH)
      return false;

   return true;
}

bool UseSRFilter()
{
   if(InpFrequencyMode == FREQ_HIGH)
      return false;

   return true;
}

bool UseStrictMTF()
{
   if(InpFrequencyMode == FREQ_HIGH)
      return false;

   if(InpFrequencyMode == FREQ_MED)
      return false;

   return true;
}


//==============================================================
// NEWS POLICY
//==============================================================

bool AllowNewsTrade(int impact)
{
   if(InpFrequencyMode == FREQ_HIGH)
      return impact >= 3;

   if(InpFrequencyMode == FREQ_MED)
      return impact >= 2;

   return impact >= 1;
}


//==============================================================
// UPDATE SETTINGS (LOGGING)
//==============================================================

void UpdateFrequencyBoostSettings()
{
   gFreqSpreadMultiplier = GetAdaptiveSpreadMultiplier();
   gFreqVolumeMultiplier = GetAdaptiveVolumeMultiplier();

   gFreqMLThreshold = GetAdaptiveMLThreshold();
   gFreqAntiChase = GetAdaptiveAntiChase();

   gFreqAllowNewsTrade = (InpFrequencyMode == FREQ_HIGH);
   gFreqUseStrictMTF = UseStrictMTF();
   gFreqUseSRFilter = UseSRFilter();

   // 🔥 LOG QUAN TRỌNG
   LogTag("FREQ",
      StringFormat("Cập nhật chế độ: Mode=%d | Spread=%.2f | Volume=%.2f | ML=%.2f",
         InpFrequencyMode,
         gFreqSpreadMultiplier,
         gFreqVolumeMultiplier,
         gFreqMLThreshold));
}


//==============================================================
// FREQUENCY GATE (LOG)
//==============================================================

bool FrequencyAdaptiveGate()
{
   if(InpFrequencyMode == FREQ_OFF)
   {
      LogDebug("FREQ OFF → sử dụng bộ lọc đầy đủ");
      return true;
   }

   if(InpFrequencyMode == FREQ_MED)
   {
      LogDebug("FREQ MED → nới lỏng một phần điều kiện");
      return true;
   }

   if(InpFrequencyMode == FREQ_HIGH)
   {
      LogDebug("FREQ HIGH → tối đa hóa cơ hội vào lệnh");
      return true;
   }

   return true;
}


#endif