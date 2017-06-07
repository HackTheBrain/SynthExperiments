import argparse

from pythonosc import dispatcher
from pythonosc import osc_server
from pythonosc import osc_message_builder
from pythonosc import udp_client

import numpy as np

eegdata = []

def nextpow2(i):
  """
  Find the next power of 2 for number i
  """
  n = 1
  while n < i:
    n *= 2
  return n

def print_eeg(unused_addr, *args):
  global eegdata
  eegdata.append(args[0])
  if len(eegdata) == 2000:
    data = eegdata[:]
    eegdata = eegdata[50:]

    winSampleLength = len(data)
    NFFT = nextpow2(winSampleLength)
    Y = np.fft.fft(data, n=NFFT, axis=0)/winSampleLength
    PSD = 2*np.abs(Y[0:int(NFFT/2)])
    print(PSD)

    global client
    client.send_message("/openbci/fft", PSD[0:250])




if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--ip",
      default="127.0.0.1", help="The ip to listen on")
  parser.add_argument("--port",
      type=int, default=5005, help="The port to listen on")
  args = parser.parse_args()

  dispatcher = dispatcher.Dispatcher()
  dispatcher.map("/openbci", print_eeg)

  global client
  client = udp_client.SimpleUDPClient("localhost", 12346)

  server = osc_server.ThreadingOSCUDPServer(
      (args.ip, args.port), dispatcher)
  print("Serving on {}".format(server.server_address))
  server.serve_forever()
