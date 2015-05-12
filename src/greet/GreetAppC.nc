configuration GreetAppC {}

implementation{ 
  components MooseC, XBeeC, MainC, SimpleReceiver;
  components new TimerMilliC() as Timer0;

  MooseC.Boot  -> MainC.Boot;

  XBeeC.Boot   -> MainC.Boot;
  XBeeC.Timer0 -> Timer0;

  SimpleReceiver.SimpleReceive -> XBeeC.SimpleReceive;
}
