configuration DetectionWithReputationAppC {}

implementation{ 
  components MooseC, XBeeC, VirtualMeshC,
             LightReadingC,
             ReputationC,
             ReportingC,
             MainC;

  components new TimerMilliC() as NetworkTimer;

  components new TimerMilliC() as LightReadingTimer;

  components new TimerMilliC() as ValidationTimer;
  components new TimerMilliC() as SharingTimer;

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

  ReputationC.ValidationTimer     -> ValidationTimer;
  ReputationC.SharingTimer        -> SharingTimer;

  ReputationC.MeshSend            -> VirtualMeshC.MeshSend;
  ReputationC.MeshReceive         -> VirtualMeshC.MeshReceive;
  
  ReportingC.Boot                 -> MainC.Boot;
  ReportingC.ReportingTimer       -> ReportingTimer;
}
