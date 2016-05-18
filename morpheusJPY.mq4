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

int init()
{
   MathSrand(TimeLocal());  
   return(0);
}

int start()
{
      /*lotsize = MathRound(AccountBalance()/15000);
      if (lotsize > 25 ){
         lotsize = 25;
      }
      
     if(AccountBalance() >= 100000 && AccountBalance() < 200000){
         lotsize = 2;
      }
      else if( AccountBalance() >= 200000 && AccountBalance() < 300000){
         lotsize = 3;
      }
      else if( AccountBalance() >= 300000 && AccountBalance() < 400000){
         lotsize = 4;
      }
      else if( AccountBalance() >= 400000 && AccountBalance() < 500000){
         lotsize = 5;
      }     
       else if( AccountBalance() >= 500000 && AccountBalance() < 600000){
         lotsize = 6;
      }
       else if( AccountBalance() >= 600000 && AccountBalance() < 700000){
         lotsize = 7;
      }
      else if( AccountBalance() >= 700000 && AccountBalance() < 800000){
         lotsize = 8;
      }  
      else if( AccountBalance() >= 800000 && AccountBalance() < 900000){
         lotsize = 9;
      }
      else if( AccountBalance() >= 900000 && AccountBalance() < 1000000){
         lotsize = 10;
      }*/
      
     

      if(currentdate != TimeDay(TimeCurrent())){
        // Print("AccountBalanceEURJPY1 = " + AccountBalance());
         currentdate= TimeDay(TimeCurrent());
      }

      if (TimeCurrent() >= lasttrade+tradeincrement)
      {
         
      if(OrdersTotal()<OpenOrders)
      {  
      
         OrderSelect(OrdersHistoryTotal()-1, SELECT_BY_POS,MODE_HISTORY);
         //Print("Order profit :" + OrderProfit() + " OrderTicket :" + OrderTicket());
         if (OrderProfit()>0 && OrderType()==OP_BUY)
         {
            nexttrade="short";
         }
         if (OrderProfit()<0 && OrderType()==OP_BUY)
         {
            nexttrade="short";
         }
          if (OrderProfit()>0 && OrderType()==OP_SELL)
         {
            nexttrade="short";
         }
         if (OrderProfit()<0 && OrderType()==OP_SELL)
         {
            nexttrade="short";
         }
         
         
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
