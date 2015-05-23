configuration LoopAppC {}

implementation{ 
	components LoopC, ReportingC, MainC;
  components new TimerMilliC() as LoopTimer;
  components new TimerMilliC() as ReportingTimer;

	LoopC.Boot                -> MainC.Boot;
  LoopC.LoopTimer           -> LoopTimer;

  ReportingC.Boot           -> MainC.Boot;
  ReportingC.ReportingTimer -> ReportingTimer;
}
