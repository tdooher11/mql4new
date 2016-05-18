extern int OpenOrders = 20;
extern double lotsize = 1.0;

extern double Percentage = 0.65;
extern double TrailingStop = 0.0160;
extern double TakeProfit = 0.1200; 
extern int closeallvalue = 75000;
extern int tradeincrement = 3600;
extern int magicnum = 0;


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
     /* if(AccountBalance() >= 100000 && AccountBalance() < 125000){
         lotsize = 1;
      }
      else if( AccountBalance() >= 125000 && AccountBalance() < 150000){
         lotsize = 2;
      }
      else if( AccountBalance() >= 150000 && AccountBalance() < 175000){
         lotsize = 3;
      }
      else if( AccountBalance() >= 175000 && AccountBalance() < 200000){
         lotsize = 4;
      }     
       else if( AccountBalance() >= 200000 && AccountBalance() < 300000){
         lotsize = 5;
      }
       else if( AccountBalance() >= 300000 && AccountBalance() < 400000){
         lotsize = 6;
      }
       else if( AccountBalance() >= 400000 ){
         lotsize = 7;
      } */
     

      if(currentdate != TimeDay(TimeCurrent())){
         Print("AccountBalanceGBPJPY2 = " + AccountBalance());
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
            ticket = OrderSend(Symbol(),OP_BUY,lotsize,NormalizeDouble(Ask,5),2,Bid-TrailingStop,Ask+TakeProfit,"ordertype_buy",magicnum);
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
            OrderSend(Symbol(),OP_SELL,lotsize,NormalizeDouble(Bid,5),2,Ask+TrailingStop,Bid-TakeProfit,"ordertype_sell",magicnum);
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
               if(OrderStopLoss()<Bid-TrailingStop)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop,OrderTakeProfit(),0,Blue);
               }

         }
         
         if(Ask<OrderOpenPrice()&&OrderType()==OP_SELL)
         {
 
               if(OrderStopLoss()>Ask+TrailingStop)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop,OrderTakeProfit(),0,Blue);
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