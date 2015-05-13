module GreeterC {
  uses interface SimpleSend;
  uses interface SimpleReceive;
}

implementation {
  // helper function wrapping strlen
  void send_str(const char *string) {
    call SimpleSend.send((uint8_t*)string, strlen(string));
  }

  event void SimpleSend.ready() {
    printf("sending hello to parent...\n");
    send_str("hello parent!");
  }

  event void SimpleReceive.received(uint8_t *bytes, const uint8_t size) {
    int i;
    printf("received %d bytes : ", size);
    for(i=0; i<size; i++) {
      printf("%c", bytes[i]);
    }
    printf("\n");
  }
}
