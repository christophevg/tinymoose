configuration DetectionWithHeartbeatAppC {}

implementation{ 
  components MooseC, XBeeC, VirtualMeshC,
             LightReadingC,
             HeartbeatingC,
             ReportingC,
             MainC;

  components new TimerMilliC() as NetworkTimer;

  components new TimerMilliC() as LightReadingTimer;

  components new TimerMilliC() as HeartbeatTimer;
  components new TimerMilliC() as ProcessingTimer;

  components new TimerMilliC() as ReportingTimer;

  MooseC.Boot                     -> MainC.Boot;

  XBeeC.Boot                      -> MainC.Boot;
  XBeeC.Timer0                    -> NetworkTimer;

  VirtualMeshC.FrameSend          -> XBeeC.FrameSend;
  VirtualMeshC.FrameReceive       -> XBeeC.FrameReceive;
  VirtualMeshC.XBeeFrame          -> XBeeC.XBeeFrame;

  LightReadingC.LightReadingTimer -> LightReadingTimer;

  LightReadingC.MeshSend          -> VirtualMeshC.MeshSend;
  LightReadingC.MeshReceive       -> VirtualMeshC.MeshReceive;

  HeartbeatingC.HeartbeatTimer    -> HeartbeatTimer;
  HeartbeatingC.ProcessingTimer   -> ProcessingTimer;

  HeartbeatingC.MeshSend          -> VirtualMeshC.MeshSend;
  HeartbeatingC.MeshReceive       -> VirtualMeshC.MeshReceive;
  
  ReportingC.Boot                 -> MainC.Boot;
  ReportingC.ReportingTimer       -> ReportingTimer;
}
