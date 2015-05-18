interface MeshReceive {
  event void received(uint16_t source,
                      uint16_t from, uint16_t to, uint16_t hop,
                      uint8_t *bytes, uint8_t size);
}
