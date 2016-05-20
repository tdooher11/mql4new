extern double lotsize = 1.0;
extern double TrailingStop = 1.0;
extern double TakeProfit = 4.0; 
extern int tradeincrement = 3600;
extern int magicnum = 0;

int currentdate = 0;
int OpenOrders = 1;
datetime lasttrade = 0;
int lasttradelong=0;
int ticket = 0;
string nexttrade="long";
bool currentorderopen = false;

int init()
{
   MathSrand(TimeLocal());  
   return(0);
}

int start()
{
      //lotsize = MathRound(AccountBalance()/15000);
      //if (lotsize > 25 ){
      //   lotsize = 25;
      //}

      if(currentdate != TimeDay(TimeCurrent())){
        // Print("AccountBalanceUSDJPY1 = " + AccountBalance());
         currentdate= TimeDay(TimeCurrent());
      }

      if (TimeCurrent() >= lasttrade+tradeincrement)
      {
      
      currentorderopen=false;
      for(int i=0;i<OrdersTotal();i++)
      {
         Print("inside for loop");
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         Print("order symbol " + OrderSymbol());
         Print("symbol : " + Symbol());
         if(OrderSymbol()==Symbol())
         {
            Print("inside order open = true");
            currentorderopen=true;
            break;
         }    
      }
         
      if(currentorderopen==false)
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
