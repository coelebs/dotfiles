#!/bin/sh

PID=$(pgrep -f usb-FTDI_Dual_RS232-if00-port0)

if [ -n "$PID" ]; then
  kill "$PID"
  echo "Waiting for current microcom to end"
  sleep 0.5
fi

microcom -p /dev/serial/by-id/usb-FTDI_Dual_RS232-if00-port0
#microcom -p /dev/serial/by-id/usb-Cypress_Semiconductor_USB-Serial__Dual_Channel_-if00
