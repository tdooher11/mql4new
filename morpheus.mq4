extern int OpenOrders = 20;
extern double lotsize = 1.0;

extern double Percentage = 0.65;
extern double TrailingStop = 0.0160;
extern double TakeProfit = 0.1200; 
extern int closeallvalue = 75000;
extern int tradeincrement = 3600;


int currentbalance = 0;
int currentdate = 0;
datetime lasttrade = 0;
int lasttradelong=0;
int ticket = 0;

int init()
{
   MathSrand(TimeLocal());  
   return(0);
}

int start()
{

      if(currentdate != TimeDay(TimeCurrent())){
         Print("AccountBalanceEURJPY7 = " + AccountBalance());
         currentdate= TimeDay(TimeCurrent());
      }

      if(AccountEquity()-AccountBalance()>closeallvalue)
      {
         closeall();
      }
      
      if (TimeCurrent() >= lasttrade+tradeincrement)
      {
         
      if(OrdersTotal()<OpenOrders)
      {  
         if(lasttradelong==1)
         {     
            RefreshRates();
            ticket = OrderSend(Symbol(),OP_BUY,lotsize,NormalizeDouble(Ask,5),2,Bid-TrailingStop,Ask+TakeProfit,"ordertype_buy",1);
            if(ticket < 0)
            {
               Print("OrderSend Error: ", GetLastError());
            }
            else
            {
               Print("Order Sent Successfully, Ticket # is: " + string(ticket));  
            }
            lasttrade=TimeCurrent();
            lasttradelong=0;
            return(0);
         }
         if(lasttradelong==0)
         {
            RefreshRates();
            OrderSend(Symbol(),OP_SELL,lotsize,NormalizeDouble(Bid,5),2,Ask+TrailingStop,Bid-TakeProfit,"ordertype_sell",1);
            if(ticket < 0)
            {
               Print("OrderSend Error: ", GetLastError());
            }
            else
            {
               Print("Order Sent Successfully, Ticket # is: " + string(ticket));  
            }
            lasttrade=TimeCurrent();             
            lasttradelong=1;     
         }            
      }  
         
      for(int cnt=0;cnt<OrdersTotal();cnt++)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(Bid>OrderOpenPrice()&&OrderType()==OP_BUY)
         {
            if(Bid<OrderOpenPrice()+TrailingStop/Percentage)
            {
               if(OrderStopLoss()<Bid-TrailingStop)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop,OrderTakeProfit(),0,Blue);
               }
            }
            if(Bid>OrderOpenPrice()+TrailingStop/Percentage)
            {
               if(OrderStopLoss()<Bid-(Bid-OrderOpenPrice()*Percentage))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(Bid-OrderOpenPrice())*Percentage,OrderTakeProfit(),0,Blue);
               }
            }
         }
         
         if(Ask<OrderOpenPrice()&&OrderType()==OP_SELL)
         {
            if(Ask>OrderOpenPrice()-TrailingStop/Percentage)
            {
               if(OrderStopLoss()>Ask+TrailingStop)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop,OrderTakeProfit(),0,Blue);
               }
            }
            if(Ask<OrderOpenPrice()-TrailingStop/Percentage)
            {
               if(OrderStopLoss()>Ask+(OrderOpenPrice()-Ask)*Percentage)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(OrderOpenPrice()-Ask)*Percentage,OrderTakeProfit(),0,Blue);
               }
            }
         }
      }
   }
}
int closeall()
{

  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();
    bool result = false;

    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );                    
    }

    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
  }
  return(0);
}