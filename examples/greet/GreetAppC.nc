configuration GreetAppC {}

implementation{ 
  components MooseC, XBeeC, SimpleReceiverC, MainC;
  components new TimerMilliC() as Timer0;

  MooseC.Boot  -> MainC.Boot;

  XBeeC.Boot   -> MainC.Boot;
  XBeeC.Timer0 -> Timer0;

  SimpleReceiverC.SimpleReceive -> XBeeC.SimpleReceive;
}
