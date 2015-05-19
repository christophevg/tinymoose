configuration HeartbeatAppC {}

implementation{ 
  components MooseC, XBeeC, VirtualMeshC, HeartbeatingC, LightReadingC, MainC;
  components new TimerMilliC() as NetworkTimer;
  components new TimerMilliC() as HeartbeatTimer;
  components new TimerMilliC() as ProcessingTimer;
  components new TimerMilliC() as LightReadingTimer;

  MooseC.Boot                     -> MainC.Boot;

  XBeeC.Boot                      -> MainC.Boot;
  XBeeC.Timer0                    -> NetworkTimer;

  VirtualMeshC.FrameSend          -> XBeeC.FrameSend;
  VirtualMeshC.FrameReceive       -> XBeeC.FrameReceive;
  VirtualMeshC.XBeeFrame          -> XBeeC.XBeeFrame;

  HeartbeatingC.HeartbeatTimer    -> HeartbeatTimer;
  HeartbeatingC.ProcessingTimer   -> ProcessingTimer;

  HeartbeatingC.MeshSend          -> VirtualMeshC.MeshSend;
  HeartbeatingC.MeshReceive       -> VirtualMeshC.MeshReceive;
  
  LightReadingC.LightReadingTimer -> LightReadingTimer;

  LightReadingC.MeshSend          -> VirtualMeshC.MeshSend;
  LightReadingC.MeshReceive       -> VirtualMeshC.MeshReceive;
}
