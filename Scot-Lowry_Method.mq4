//+--------------------------------------+
//|                Scot-Lowry_Method.mq4 |
//| Mathias Donoso - Alejandro Villaseca |
//|                                      |
//+--------------------------------------+
#property copyright "Mathias Donoso - Alejandro Villaseca"
#property link      ""

// Variables Initialization

bool CruceAlzaRoja = false;
bool CruceBajaRoja = false;
bool CruceAlzaVerde = false;
bool CruceBajaVerde = false;
bool ZonaPeligro;

bool VelaNueva;
bool Venta;
bool Compra;

double lotes;
double pipsObjetivo = 1500;
double LotesAumento = 0.1;

double StopLoss = 50;
double TakeProfit = 100;

double TakeProfitCompra;
double TakeProfitVenta;

double ADX;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
    NuevaBarra();

    if(VelaNueva == True)
    {
        int PeriodoLargo = 40;     //Variable para crear la media m�vil de 40 per�odoss
        int PeriodoCorto = 18;     //Variable para crear la media m�vil de 18 per�odoss
        int PeriodoDisparo = 4;    //Variable para crear la media m�vil de 4 per�odoss

        //Creaci�n de las medias m�viles de 40, 18 y per�odos respectivamente
        double MediaLarga = iMA(Symbol(), NULL, PeriodoLargo, 0, MODE_SMA, PRICE_CLOSE, 0);
        double MediaCorta = iMA(Symbol(), NULL, PeriodoCorto, 0, MODE_SMA, PRICE_CLOSE, 0);
        double MediaDisparo = iMA(Symbol(), NULL, PeriodoDisparo, 0, MODE_SMA, PRICE_CLOSE, 0);
        //Creaci�n de las medias m�viles de 40, 18 y per�odos respectivamente en el periodo anterior
        double MediaLargaAnterior = iMA(Symbol(), NULL, PeriodoLargo, 0, MODE_SMA, PRICE_CLOSE, 1);
        double MediaCortaAnterior = iMA(Symbol(), NULL, PeriodoCorto, 0, MODE_SMA, PRICE_CLOSE, 1);
        double MediaDisparoAnterior = iMA(Symbol(), NULL, PeriodoDisparo, 0, MODE_SMA, PRICE_CLOSE, 1);

        ADX = iADX(Symbol(),0,14,PRICE_CLOSE,MODE_MAIN,0);

        // ************************ Ratio Fijo *******************************

        lotes = RatioFijo();

        // *******************************************************************



        for(int i=1; i<=OrdersTotal(); i++) //Recorro todas las operaciones
        {
            if(Venta == true)
            {
                if(OrderSelect(i-1, SELECT_BY_POS)==true)
                {
                    OrderModify(OrderTicket(), Bid, MediaLarga, TakeProfitVenta, 0, Red);
                    if(Bid >= MediaLarga)
                    {
                        Venta = false;
                    }
                }
            }

            if(Compra == true)
            {
                if(OrderSelect(i-1, SELECT_BY_POS)==true)
                {
                    OrderModify(OrderTicket(), Ask, MediaLarga, TakeProfitCompra, 0, Green);
                    if(Ask <= MediaLarga)
                    {
                        Compra = false;
                    }
                }
            }
        }

        //LA AZUL CRUZA AL ALZA A LA ROJA
        if(MediaDisparo > MediaCorta && MediaDisparoAnterior <= MediaCortaAnterior)
        {
            CruceAlzaRoja = true;
            CruceBajaRoja = false;
        }

        //LA AZUL CRUZA A LA BAJA A LA ROJA
        if(MediaDisparo < MediaCorta && MediaDisparoAnterior >= MediaCortaAnterior)
        {
            CruceBajaRoja = true;
            CruceAlzaRoja = false;
        }

        //LA AZUL CRTUZA A LA BAJA LA VERDE
        if(MediaDisparo < MediaLarga && MediaDisparoAnterior >= MediaLargaAnterior)
        {
            CruceBajaVerde = true;
            CruceAlzaVerde = false;
        }

        //LA AZUL CRUZA AL ALZA LA VERDE
        if(MediaDisparo > MediaLarga && MediaDisparoAnterior <= MediaLargaAnterior)
        {
            CruceBajaVerde = false;
            CruceAlzaVerde = true;
        }

        //TENDENCIA ALCISTA
        if(MediaCorta > MediaLarga)
        {
            Label("TENDENCIA ALCISTA");

            //ZONA DE PELIGRO
            if((MediaDisparo > MediaLarga) && (MediaDisparo < MediaCorta) && (CruceBajaRoja == true))
            {
                Label("TENDENCIA ALCISTA: ZONA DE PELIGRO");

                //Alert("TENDENCIA ALCISTA: ZONA DE PELIGRO");
                ZonaPeligro = true;
            }

            //COMPRA
            if((MediaDisparo > MediaCorta) && (ZonaPeligro == true) && (ADX > 25) && (ADX < 60))
            {
                Label("TENDENCIA ALCISTA: COMPRA");

                TakeProfitCompra = Ask + (Ask - MediaLarga) * 2;

                OrderSend(Symbol(), OP_BUY, lotes, Ask, 3, MediaLarga, TakeProfitCompra, "WE ARE BUYING", 0, 0, Green);

                Compra = true;
                CruceBajaRoja = false;
                ZonaPeligro = false;
            } else

            //SYSTEM FAILURE
            if(MediaDisparo < MediaLarga)
            {
                Label("TENDENCIA ALCISTA: SYSTEM FAILURE");

                //Alert("TENDENCIA ALCISTA: SYSTEM FAILURE");
                //CruceAlzaVerde = false;
                CruceBajaRoja = false;
                ZonaPeligro = false;
                Compra = false;
            }

            //TENDENCIA BAJISTA
        } else if(MediaCorta < MediaLarga)
        {
            Label("TENDENCIA BAJISTA");

            //ZONA DE PELIGRO
            if((MediaDisparo < MediaLarga) && (MediaDisparo > MediaCorta) && (CruceAlzaRoja == true))
            {
                Label("TENDENCIA BAJISTA: ZONA DE PELIGRO");

                //Alert("TENDENCIA BAJISTA: ZONA DE PELIGRO");
                ZonaPeligro = true;
            }
            //VENTA
            if((MediaDisparo < MediaCorta) && (ZonaPeligro == true) && (ADX > 25) && (ADX < 60))
            {
                Label("TENDENCIA BAJISTA: VENTA");

                TakeProfitVenta = Bid - (MediaLarga - Bid) * 2;

                OrderSend(Symbol(), OP_SELL, lotes, Bid, 3, MediaLarga, TakeProfitVenta, "WE ARE SELLING", 0, 0, Red);
                Venta = true;
                Alert(OrderPrint());
                CruceAlzaRoja = false;
                ZonaPeligro = false;
            } else
            //SYSTEM FAILURE
            if(MediaDisparo > MediaLarga)
            {
                Label("TENDENCIA BAJISTA: SYSTEM FAILURE");

                            //Alert("TENDENCIA BAJISTA: SYSTEM FAILURE");
                //CruceBajaVerde = false;
                CruceAlzaRoja = false;
                ZonaPeligro = false;
                Venta = false;
            }
        }
    }

    return(0);
}

void Label(string Texto) {
    ObjectsDeleteAll();
    ObjectCreate(Texto,OBJ_LABEL, 0 , 0, 0);
    ObjectSet(Texto,OBJPROP_CORNER,1);
    ObjectSet(Texto,OBJPROP_XDISTANCE,30);
    ObjectSet(Texto,OBJPROP_YDISTANCE,30);
    ObjectSetText(Texto, Texto, 10, "Arial", Black);
}

void NuevaBarra() {
    static datetime NuevoTime = 0; //Detecci�n de un nuevo tiempo

    VelaNueva = false; // 0 - misma vela , 1 - vela nueva

    if(NuevoTime!=Time[0])
    {
        NuevoTime = Time[0];
        VelaNueva = True;
    }
}


double RatioFijo() {
    int dineroObjetivo[10];

    for(int i = 0; i < 10; i++)
    {
        if(i == 0)
        {
            dineroObjetivo[i] = 10000;
        } else {
            dineroObjetivo[i] = dineroObjetivo[i-1] + pipsObjetivo * (1.0 + (LotesAumento * (i-1)));
        }
    }


    for(i = 0; i < 10; i++)
    {
        if(AccountBalance() < 10000)
        {
            lotes = (0.9);
        }

        if((dineroObjetivo[i] <= AccountBalance()) && (dineroObjetivo[i+1] > AccountBalance()))
        {
            lotes = (i/10.0 + 1.0);
        }
    }

    return (lotes);

    //pips objetivo 2.000
    //lotes aumento 0.1
    //lotes = 1.0
}
