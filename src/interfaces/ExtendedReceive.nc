interface ExtendedReceive {
  event void received(uint64_t address, uint16_t nw_address,
                      uint8_t *bytes, uint8_t size);
}
