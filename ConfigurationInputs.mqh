#ifndef __CONFIGURATION_INPUTS_MQH__
#define __CONFIGURATION_INPUTS_MQH__

//==============================================================
// ENUM
//==============================================================

// Chế độ preset cấu hình
enum ENUM_PRESET_MODE
{
   PRESET_AUTO=0,      // EA tự điều chỉnh theo thị trường
   PRESET_MANUAL=1     // Người dùng tự cấu hình
};

// Chế độ tăng tần suất giao dịch
enum ENUM_FREQ_BOOST
{
   FREQ_OFF=0,         // Không tăng tần suất
   FREQ_MED=1,         // Tăng tần suất trung bình
   FREQ_HIGH=2         // Tăng tần suất cao
};

// Chế độ hỗ trợ kháng cự (Support/Resistance)
enum ENUM_SR_MODE
{
   SR_OFF=0,           // Không sử dụng SR
   SR_SOFT=1,          // SR mềm (linh hoạt)
   SR_HARD=2           // SR cứng (nghiêm ngặt)
};

// Timezone hiển thị log
enum ENUM_DISPLAY_TIMEZONE
{
   TZ_SERVER=0,        // Giờ server broker
   TZ_UTC=1,           // Giờ UTC
   TZ_GMT=2,           // Giờ GMT
   TZ_EST=3,           // Giờ New York
   TZ_CET=4,           // Giờ Châu Âu
   TZ_VN=5             // Giờ Việt Nam
};

//==============================================================
// 01) CÀI ĐẶT CHUNG & QUẢN LÝ VỐN
//==============================================================

input group "01) Cài đặt chung & quản lý vốn";

input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M5;
// Khung thời gian chính EA sử dụng để tính tín hiệu

input long InpMagicNumber = 20260224;
// Magic Number dùng để nhận diện lệnh của EA

input double InpFixedLot = 0.01;
// Khối lượng vào lệnh cố định

input double InpMaxRiskPercent = 2.0;
// Phần trăm rủi ro tối đa cho mỗi lệnh

input bool InpBlockTradeIfRiskTooHigh = true;
// Chặn lệnh nếu rủi ro vượt ngưỡng cho phép

input bool InpOnePositionPerSymbol = false;
// Mỗi symbol chỉ giữ 1 lệnh

input int InpMaxOpenPositions = 2;
// Số lượng lệnh tối đa được mở cùng lúc

input bool InpCloseOppositePositions = false;
// Đóng lệnh ngược chiều trước khi mở lệnh mới


//==============================================================
// 02) STOPLOSS / TAKEPROFIT / BE / TRAILING
//==============================================================

input group "02) StopLoss / TakeProfit / BE / Trailing";

input int InpSpreadBufferPips = 15;
// Khoảng đệm StopLoss theo spread

input bool InpEnableBreakEven = true;
// Bật chức năng dời StopLoss về hòa vốn

input double InpBEThreshold = 0.50;
// Khi giá đi được X phần TP thì kích hoạt BE

input double InpBE_RR_Trigger = 1.00;
// Chỉ BE khi lợi nhuận đạt RR tối thiểu

input double InpBE_OffsetPrice = 0.35;
// Khoảng offset thêm khi dời BE

input bool InpFixStops = false;
// Sử dụng StopLoss/TakeProfit cố định

input double InpStopLossStepPrice = 7.5;
// Khoảng cách StopLoss cố định

input double InpTakeProfitStepPrice = 4.5;
// Khoảng cách TakeProfit cố định

input bool InpAllowRROverrideFixStops = false;
// Cho phép RR override chế độ FixStops

input bool InpUseTrailingStop = true;
// Bật trailing stop

input double InpTrailStartPrice = 3.2;
// Bắt đầu trailing khi lợi nhuận đạt mức này

input double InpTrailStepPrice = 1.2;
// Khoảng bước dịch StopLoss khi trailing


//==============================================================
// 03) TẦN SUẤT & LOG
//==============================================================

input group "03) Tần suất vào lệnh & ghi log";

input bool InpTradeOnNewBar = true;
// Chỉ vào lệnh khi có nến mới

input bool InpUseClosedBarSignals = true;
// Chỉ dùng tín hiệu từ nến đã đóng

input int InpMinSecondsBetweenEntries = 30;
// Khoảng cách tối thiểu (giây) giữa 2 lần vào lệnh

input int InpMinMinutesBetweenPositions = 1;
// Khoảng cách tối thiểu (phút) giữa các lệnh

input bool InpEnableBlockLogs = true;
// Ghi log khi EA chặn lệnh

input bool InpLogNoSignal = true;
// Ghi log khi không có tín hiệu


//==============================================================
// 04) SPREAD FILTER
//==============================================================

input group "04) Bộ lọc Spread";

input bool InpUseMaxSpread = true;
// Bật giới hạn spread tối đa

input int InpMaxSpreadPoints = 250;
// Spread tối đa cho phép (points)

input int InpSlippagePoints = 50;
// Slippage tối đa khi vào lệnh

input double InpSpreadAtrPct = 0.10;
// Spread động theo ATR

input int InpMinSpreadCapPoints = 35;
// Mức sàn spread tối thiểu

input bool InpUseDynamicSpreadAbnormalBlock = true;
// Chặn nếu spread bất thường

input int InpSpreadTelemetrySamples = 24;
// Số mẫu dùng để tính spread trung bình

input double InpSpreadAbnormalMultiplier = 1.80;
// Hệ số xác định spread bất thường


//==============================================================
// 05) TREND FILTER
//==============================================================

input group "05) Bộ lọc xu hướng";

input bool InpForceTrendEverywhere = true;
// Luôn ưu tiên giao dịch theo xu hướng

input double InpTrendTight_RSI_BuyMin = 52.0;
// RSI tối thiểu để BUY theo trend

input double InpTrendTight_RSI_SellMax = 48.0;
// RSI tối đa để SELL theo trend

input double InpTightPullback_MinADX = 8.0;
// ADX tối thiểu cho pullback

input int InpPullbackRecentCrossBars = 3;
// Số nến để xác nhận EMA cross

input bool InpEnablePullbackTrendFollowFallback = true;
// Cho phép fallback khi không có pullback đẹp


//==============================================================
// 05A) MTF
//==============================================================

input group "05A) Multi Timeframe";

input bool InpUseStrictMTF = true;
// Bật lọc đa khung thời gian

input ENUM_TIMEFRAMES InpMTF_HigherTF = PERIOD_H1;
// Khung timeframe cao hơn

input ENUM_TIMEFRAMES InpMTF_MidTF = PERIOD_M15;
// Khung timeframe trung gian

input double InpM15Plus_PullbackBuyRSIMax = 46.0;
// RSI tối đa để BUY pullback

input double InpM15Plus_PullbackSellRSIMin = 54.0;
// RSI tối thiểu để SELL pullback


//==============================================================
// 06) MACHINE LEARNING
//==============================================================

input group "06) Machine Learning";

input bool InpUseMLFilter = true;
// Bật bộ lọc Machine Learning

input double InpMLScoreThreshold_Buy = 0.58;
// Ngưỡng ML để cho phép BUY

input double InpMLScoreThreshold_Sell = 0.58;
// Ngưỡng ML để cho phép SELL

input double InpMLTrendWeight = 0.24;
// Trọng số yếu tố xu hướng

input double InpMLMomentumWeight = 0.18;
// Trọng số momentum

input double InpMLVolWeight = 0.12;
// Trọng số volatility

input double InpMLMTFWeight = 0.18;
// Trọng số đa khung

input double InpMLPAWeight = 0.14;
// Trọng số price action


//==============================================================
// 06A) INDICATOR CORE
//==============================================================

input group "06A) Tham số chỉ báo";

input int InpFastMAPeriod = 12;        // EMA nhanh
input int InpSlowMAPeriod = 26;        // EMA chậm
input ENUM_MA_METHOD InpMAMethod = MODE_EMA; // Loại MA
input ENUM_APPLIED_PRICE InpMAPrice = PRICE_CLOSE; // Giá áp dụng
input int InpRSIPeriod = 14;           // Chu kỳ RSI
input int InpATRPeriod = 14;           // Chu kỳ ATR
input int InpADXPeriod = 14;           // Chu kỳ ADX
input double InpATRHighThreshold = 6.8; // ATR cao
input double InpLowATRRangeThreshold = 3.8; // ATR thấp
input double InpADXSidewaysMax = 19.0; // ADX sideways


//==============================================================
// 06B) SIGNAL FILTER
//==============================================================

input group "06B) Bộ lọc tín hiệu";

input bool InpUseStochFilter = true;     // Bật Stochastic
input int InpStochK = 5;                 // Chu kỳ K
input int InpStochD = 3;                 // Chu kỳ D
input int InpStochSlowing = 3;           // Slowing
input double InpTF_StochBuy_MinK = 28.0; // K tối thiểu BUY
input double InpTF_StochSell_MaxK = 72.0;// K tối đa SELL
input double InpRSIOversold = 42.0;      // RSI quá bán
input double InpRSIOverbought = 58.0;    // RSI quá mua
//==============================================================
// 07) PARTIAL CLOSE
//==============================================================

input group "07) Đóng lệnh từng phần (Partial Close)";

input bool InpEnablePartialClose = true;
// Cho phép EA tự động đóng một phần khối lượng khi đạt lợi nhuận

input double InpPartialClose_RR = 1.0;
// Tỷ lệ Risk:Reward để kích hoạt đóng một phần lệnh

input double InpPartialClose_Fraction = 0.5;
// Tỷ lệ khối lượng sẽ được đóng (0.5 = đóng 50%)

input double InpPartialClose_MinLot = 0.01;
// Khối lượng tối thiểu để thực hiện đóng một phần


//==============================================================
// 08) DRAWDOWN
//==============================================================

input group "08) Bảo vệ tài khoản (Drawdown Guard)";

input bool InpEnableDrawdownGuard = true;
// Bật cơ chế bảo vệ tài khoản khi bị sụt giảm vốn

input double InpDrawdownWarnPercent = 8;
// Mức drawdown (%) bắt đầu cảnh báo

input double InpDrawdownPausePercent = 12;
// Mức drawdown (%) tại đó EA sẽ tạm dừng giao dịch

input double InpDrawdownLotReducePercent = 50;
// Giảm khối lượng giao dịch (%) khi drawdown tăng cao


//==============================================================
// 09) VOLATILITY TP
//==============================================================

input group "09) Điều chỉnh TakeProfit theo biến động";

input bool InpEnableVolatilityTPAdjust = true;
// Cho phép điều chỉnh TakeProfit theo độ biến động thị trường (ATR)

input double InpVolatilityTPFactor = 0.35;
// Hệ số nhân ATR để mở rộng hoặc thu hẹp TakeProfit


//==============================================================
// 10) SESSION FILTER
//==============================================================

input group "10) Bộ lọc phiên giao dịch";

input bool InpUseTimeFilter = false;
// Bật/tắt bộ lọc theo thời gian giao dịch

input int InpTradeStartHour = 7;
// Giờ bắt đầu cho phép giao dịch (giờ server)

input int InpTradeEndHour = 22;
// Giờ kết thúc giao dịch (giờ server)

input int InpEUSessionStartHour = 14;
// Giờ bắt đầu phiên Châu Âu (London)

input int InpEUSessionEndHour = 17;
// Giờ kết thúc phiên Châu Âu

input int InpUSSessionStartHour = 19;
// Giờ bắt đầu phiên Mỹ (New York)

input int InpUSSessionEndHour = 22;
// Giờ kết thúc phiên Mỹ


//==============================================================
// 11) SESSION BLOCK
//==============================================================

input group "11) Chặn giao dịch trước phiên";

input bool InpBlockBeforeSessions = true;
// Bật chặn giao dịch trước khi vào phiên lớn (EU/US)

input int InpBlockBeforeEU_Min = 30;
// Số phút chặn giao dịch trước khi phiên EU bắt đầu

input int InpBlockBeforeUS_Min = 30;
// Số phút chặn giao dịch trước khi phiên US bắt đầu


//==============================================================
// 12) NEWS FILTER
//==============================================================

input group "12) Bộ lọc tin tức";

input bool InpBlockAroundNews = true;
// Chặn giao dịch xung quanh thời điểm có tin tức quan trọng

input int InpNewsBlockBefore_Min = 30;
// Số phút chặn trước khi tin ra

input int InpNewsBlockAfter_Min = 60;
// Số phút chặn sau khi tin ra

input string InpHighImpactNewsTimes = "";
// Danh sách thời điểm tin mạnh (format: "HH:MM;HH:MM")

input bool InpUseMT5DynamicNewsFilter = false;
// Sử dụng lịch tin tức tự động của MT5


//==============================================================
// 13) FREQUENCY
//==============================================================

input group "13) Tăng tần suất giao dịch";

input bool InpHighFrequencyMode = true;
// Bật chế độ giao dịch tần suất cao

input ENUM_FREQ_BOOST InpFrequencyMode = FREQ_HIGH;
// Mức tăng tần suất: OFF / MED / HIGH


//==============================================================
// 14) SESSION ADAPTIVE
//==============================================================

input group "14) Tối ưu theo phiên giao dịch";

input bool InpEnableSessionAdaptiveThresholds = true;
// Cho phép EA tự động điều chỉnh điều kiện theo từng phiên

input double InpAsiaSessionLoosenFactor = 0.92;
// Hệ số nới lỏng điều kiện trong phiên Á (ít biến động)

input double InpLondonNYSessionTightFactor = 1.05;
// Hệ số siết chặt điều kiện trong phiên Âu/Mỹ (biến động mạnh)


//==============================================================
// 18) LOGGING
//==============================================================

input group "18) Ghi log & debug";

input ENUM_DISPLAY_TIMEZONE InpDisplayTimezone = TZ_SERVER;
// Chọn múi giờ hiển thị trong log

input bool InpVerboseLogs = true;
// Bật ghi log chi tiết (debug toàn bộ hoạt động EA)

#endif