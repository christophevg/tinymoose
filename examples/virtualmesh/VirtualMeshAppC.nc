configuration VirtualMeshAppC {}

implementation{ 
  components MooseC, XBeeC, VirtualMeshC, GreeterC, MainC;
  components new TimerMilliC() as Timer0;

  MooseC.Boot  -> MainC.Boot;

  XBeeC.Boot   -> MainC.Boot;
  XBeeC.Timer0 -> Timer0;

  VirtualMeshC.FrameSend    -> XBeeC.FrameSend;
  VirtualMeshC.FrameReceive -> XBeeC.FrameReceive;
  VirtualMeshC.XBeeFrame    -> XBeeC.XBeeFrame;

  GreeterC.MeshSend         -> VirtualMeshC.MeshSend;
  GreeterC.MeshReceive      -> VirtualMeshC.MeshReceive;
}
