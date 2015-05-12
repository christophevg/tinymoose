module SimpleReceiver {
  uses interface SimpleReceive;
}

implementation {
  event void SimpleReceive.received(uint8_t *bytes, const uint8_t size) {
    int i;
    printf("received %d bytes : ", size);
    for(i=0; i<size; i++) {
      printf("%c", bytes[i]);
    }
    printf("\n");
  }
}
