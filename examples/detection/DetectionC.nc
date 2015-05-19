module DetectionC {
  uses interface SimpleSend;
}

implementation {
  event void SimpleSend.ready() {
    SimpleSend.send_str("We're watching you...\n");
  }
}
