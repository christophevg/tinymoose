configuration ClockAppC {}

implementation{ 
	components ClockC, MainC;
  components new TimerMilliC() as ClockTimer;

	ClockC.Boot       -> MainC.Boot;
  ClockC.ClockTimer -> ClockTimer;
}
