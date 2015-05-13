configuration GreetAppC {}

implementation{ 
  components MooseC, XBeeC, GreeterC, MainC;
  components new TimerMilliC() as Timer0;

  MooseC.Boot  -> MainC.Boot;

  XBeeC.Boot   -> MainC.Boot;
  XBeeC.Timer0 -> Timer0;

  GreeterC.SimpleSend    -> XBeeC.SimpleSend;
  GreeterC.SimpleReceive -> XBeeC.SimpleReceive;
}
