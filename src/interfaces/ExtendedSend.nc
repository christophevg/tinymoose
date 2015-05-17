#include <TinyError.h>

interface ExtendedSend {
  event void ready(void);

  command error_t broadcast(uint8_t *bytes, uint8_t size);
  command error_t broadcast_str(const char *string);

  command error_t send(uint64_t address, uint16_t nw_address,
                       uint8_t *bytes, uint8_t size);
  command error_t send_str(uint64_t address, uint16_t nw_address,
                           const char *string);
}
