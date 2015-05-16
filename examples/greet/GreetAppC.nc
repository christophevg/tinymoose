configuration GreetAppC {}

implementation{ 
  components MooseC, XBeeC, SimpleXBeeC, GreeterC, MainC;
  components new TimerMilliC() as Timer0;

  MooseC.Boot              -> MainC.Boot;

  XBeeC.Boot               -> MainC.Boot;
  XBeeC.Timer0             -> Timer0;

  GreeterC.SimpleSend      -> SimpleXBeeC.SimpleSend;
  GreeterC.SimpleReceive   -> SimpleXBeeC.SimpleReceive;
  
  SimpleXBeeC.FrameSend    -> XBeeC.FrameSend;
  SimpleXBeeC.FrameReceive -> XBeeC.FrameReceive;
  SimpleXBeeC.XBeeFrame    -> XBeeC.XBeeFrame;
}
