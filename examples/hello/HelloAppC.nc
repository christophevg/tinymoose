configuration HelloAppC {}

implementation{ 
	components HelloC, MainC;

	HelloC.Boot -> MainC.Boot;
}
