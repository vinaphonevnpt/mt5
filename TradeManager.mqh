//==============================================================
// TradeManager.mqh
// PROFESSIONAL TRADE EXECUTION (FINAL FIX)
//==============================================================

#ifndef __TRADE_MANAGER_MQH__
#define __TRADE_MANAGER_MQH__

#include "ConfigurationInputs.mqh"
#include "LoggingAndTimeUtils.mqh"

//==============================================================
// CONFIG
//==============================================================

#define MAX_RETRY 3

//==============================================================
// CHECK TRADING ENVIRONMENT
//==============================================================

bool IsTradingAllowed()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Log("❌ Terminal không cho phép trade");
      return false;
   }

   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   {
      Log("❌ Account không cho phép trade");
      return false;
   }

   return true;
}

//==============================================================
// BUILD REQUEST
//==============================================================

void BuildRequest(MqlTradeRequest &req,
                  ENUM_ORDER_TYPE type,
                  double volume,
                  double price)
{
   ZeroMemory(req);

   req.action   = TRADE_ACTION_DEAL;
   req.symbol   = _Symbol;
   req.volume   = volume;
   req.type     = type;
   req.price    = price;
   req.deviation= InpSlippagePoints;
   req.magic    = InpMagicNumber;
   req.type_filling = ORDER_FILLING_IOC;
}

//==============================================================
// SEND ORDER (WITH RETRY)
//==============================================================

bool SendOrder(MqlTradeRequest &req)
{
   MqlTradeResult res;

   for(int i=0;i<MAX_RETRY;i++)
   {
      if(OrderSend(req,res))
      {
         if(res.retcode == TRADE_RETCODE_DONE ||
            res.retcode == TRADE_RETCODE_PLACED)
         {
            Log("✔ Order thành công | ticket=" + IntegerToString(res.order));
            return true;
         }
         else
         {
            Log("❌ Order fail retcode=" + IntegerToString(res.retcode));
         }
      }
      else
      {
         Log("❌ OrderSend lỗi (retry " + IntegerToString(i+1) + ")");
      }

      Sleep(200);
   }

   return false;
}

//==============================================================
// OPEN BUY
//==============================================================

bool OpenBuy()
{
   if(!IsTradingAllowed())
      return false;

   double price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   MqlTradeRequest req;
   BuildRequest(req,ORDER_TYPE_BUY,InpFixedLot,price);

   Log("➡️ Gửi BUY");

   return SendOrder(req);
}

//==============================================================
// OPEN SELL
//==============================================================

bool OpenSell()
{
   if(!IsTradingAllowed())
      return false;

   double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   MqlTradeRequest req;
   BuildRequest(req,ORDER_TYPE_SELL,InpFixedLot,price);

   Log("➡️ Gửi SELL");

   return SendOrder(req);
}

//==============================================================
// CLOSE ALL POSITIONS
//==============================================================

void CloseAllPositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      ENUM_POSITION_TYPE type =
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double volume = PositionGetDouble(POSITION_VOLUME);

      double price = (type==POSITION_TYPE_BUY) ?
                     SymbolInfoDouble(_Symbol,SYMBOL_BID) :
                     SymbolInfoDouble(_Symbol,SYMBOL_ASK);

      MqlTradeRequest req;
      MqlTradeResult res;

      ZeroMemory(req);
      ZeroMemory(res);

      req.action   = TRADE_ACTION_DEAL;
      req.position = ticket;
      req.symbol   = _Symbol;
      req.volume   = volume;
      req.type     = (type==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
      req.price    = price;
      req.deviation= InpSlippagePoints;
      req.magic    = InpMagicNumber;

      if(OrderSend(req,res))
      {
         Log("✔ Đóng lệnh ticket=" + IntegerToString(ticket));
      }
      else
      {
         Log("❌ Lỗi đóng lệnh ticket=" + IntegerToString(ticket));
      }
   }
}

//==============================================================
// MANAGE OPEN POSITIONS
//==============================================================

void ManageOpenPositions()
{
   UpdatePeakProfit();

   ApplyBreakEvenLogic();
   ApplyTrailing();
   ApplyPartialCloseLogic();

   if(CheckProfitDropExit())
   {
      Log("⚠ Profit giảm mạnh → đóng toàn bộ");
      CloseAllPositions();
   }
}

#endif