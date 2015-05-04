#include <stdio.h>

module HelloC{
	uses interface Boot;
}

implementation{
	event void Boot.booted() {
    printf("Hello World\n");
	}
}
