configuration DetectionAppC {}

implementation{ 
  components MooseC, Engine1C, Engine2C, MainC;

  MooseC.Boot   -> MainC.Boot;
  Engine1C.Boot -> MainC.Boot;
  Engine2C.Boot -> MainC.Boot;
}
