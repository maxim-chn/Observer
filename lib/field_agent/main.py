import pyshark
import json
import requests
import ipaddress
import os
import time

def captureFileUpdated(lastTime, filename):
  updated = False
  try:
    latestTime = os.path.getmtime(filename)
    if latestTime > lastTime:
      updated = True
  except TypeError:
    updated = True
  return updated, latestTime

def getCaptureData(filename):
  captureData = None
  continueReporting = True
  try:
    captureData = pyshark.FileCapture(filename)
  except FileNotFoundError as e:
    print(f"Failed to acces a file with capture data. Reason, {e}.")
    continueReporting = False
  return captureData, continueReporting

def getIntelligence(captureData):
  intelligence = {'ip': int(ipaddress.IPv4Address(currentIp)), 'incoming_req_count': 0}
  for p in captureData:
    intelligence['incoming_req_count'] += 1
  return intelligence

def reportIntelligence(intelligence, observerUrl):
  continueReporting = True
  try:
    res = requests.post(observerUrl, json=intelligence)
    if res.status_code != 200:
      continueReporting = False
    message = json.loads(res.text)
    continueReporting = message['continue_collection']
  except requests.RequestException as e:
    print(f"Failed to POST Observer. Reason, {e}.")
    continueReporting = False
  return continueReporting

captureFilename = 'dumpfile.pcap'
currentIp = '79.181.31.6'
observerUrl = 'http://localhost:3000/backend_api/dos_icmp_intelligence'
continueReporting = True
lastModificationTime = None
delayInSeconds = 10

while continueReporting:
  time.sleep(delayInSeconds)
  captureUpdated, lastModificationTime = captureFileUpdated(lastModificationTime, captureFilename)
  captureData = None
  if captureUpdated:
    captureData, continueReporting = getCaptureData(captureFilename)
  if captureData is not None:
    intelligence = getIntelligence(captureData)
    print(intelligence)
    continueReporting = reportIntelligence(intelligence, observerUrl)
