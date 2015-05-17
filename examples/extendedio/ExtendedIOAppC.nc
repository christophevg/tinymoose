configuration ExtendedIOAppC {}

implementation{ 
  components MooseC, XBeeC, ExtendedXBeeC, GreeterC, MainC;
  components new TimerMilliC() as Timer0;

  MooseC.Boot  -> MainC.Boot;

  XBeeC.Boot   -> MainC.Boot;
  XBeeC.Timer0 -> Timer0;

  ExtendedXBeeC.FrameSend    -> XBeeC.FrameSend;
  ExtendedXBeeC.FrameReceive -> XBeeC.FrameReceive;
  ExtendedXBeeC.XBeeFrame    -> XBeeC.XBeeFrame;

  GreeterC.ExtendedSend       -> ExtendedXBeeC.ExtendedSend;
  GreeterC.ExtendedReceive    -> ExtendedXBeeC.ExtendedReceive;
}
