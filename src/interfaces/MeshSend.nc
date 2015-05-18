#include <TinyError.h>

interface MeshSend {
  event void ready(void);

  event void transmitted(uint16_t from, uint16_t to, uint16_t hop,
                         uint8_t *bytes, uint8_t size);

  command error_t broadcast(uint8_t *bytes, uint8_t size);
  command error_t broadcast_str(const char *string);

  command error_t send(uint16_t to, uint8_t *bytes, uint8_t size);
  command error_t send_str(uint16_t to, const char *string);
}
