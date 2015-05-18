#!/usr/bin/python

# coordinate
# tool to functionally dunp frames arriving at the demo's coordinator
# author: Christophe VG

import serial
import time
import binascii

from xbee import ZigBee

ser  = serial.Serial("/dev/tty.usbserial-AD025LL3", 9600)
xbee = ZigBee(ser)

def handle(handlers={}):
  # continuously read and print packets
  while True:
    try:
      frame = xbee.wait_read_frame()

      # basic frame handling: unknown frames are dumped and skipped
      try:
        frame = {
          "rx"        : handle_rx,
          "tx_status" : handle_tx_status
        }[frame["id"]](frame)
      except KeyError:
        print "Unknown frame:", frame
        continue

    except KeyboardInterrupt: break
  ser.close()

def handle_rx(frame):
  # convert all bytestrings into bytearrays
  frame = dict(frame.items() + {'_'+key:map(ord, value) \
    for key, value in frame.items()}.items())

  # parse out options into dict
  frame["_options"] = _parse(frame["_options"][0], {
    "acked"     : 0x01,
    "broadcast" : 0x02,
    "encrypted" : 0x20,
    "end-device": 0x40
  })

  _dump("RX", {
        "length" : len(frame["_rf_data"]),
        "source" : _ba2str(frame["_source_addr_long"]) + " / " + \
                   _ba2str(frame["_source_addr"]),
        "options": ' '.join([o for o, val in frame["_options"].items() if val]),
        "data"   : _ba2str(frame["_rf_data"][6:]),
        "raw"    : frame["_rf_data"][6:],
        "from"   : _ba2str(frame["_rf_data"][0:2]),
        "hop"    : _ba2str(frame["_rf_data"][2:4]),
        "to"     : _ba2str(frame["_rf_data"][4:6])
      })

  return frame

def handle_tx_status(frame):
  # TODO: handle status
  return frame

def _parse(data, config):
  return {key: data & byte == byte for key,byte in config.items()}

def _ba2str(bytearray):
  return ' '.join("%02x" % i for i in bytearray)

def _dump(type, data):
  # determine max length of a label
  pad = max(11, max([len(label) for label in data]))

  # pretty print the data
  print "-" * 80
  print type
  print "-" * 80
  # add a local timestamp
  print "time", " " * (pad-4), ":", time.strftime("%a, %d %b %Y %H:%M:%S +0000",
                                                  time.gmtime())
  for label, value in data.items():
    print label, " " * (pad-len(label)), ":", str(value) \
      if label != "raw" else ''.join(chr(i) for i in value)
  print "-" * 80

if __name__ == "__main__":
  handle()
