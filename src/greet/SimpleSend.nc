#include <TinyError.h>

interface SimpleSend {
  command error_t send(uint8_t *bytes, uint8_t size);
}
