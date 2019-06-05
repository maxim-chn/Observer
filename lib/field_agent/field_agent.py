import pyshark
import json
import requests
import ipaddress
import os
import time
import sys
import urllib

def printHelp():
  print('This is a field agent that consumes .pcap file and reports its relevant contents to the Observer.')
  print('Running the program without any arguments or \'help\' will show this message.')
  print('Arguments must be provided in the following order, separated by a single space:')
  print('\t1. The name of the directory where .pcap files are stored. It must be in the same directory with this program!')
  print('\t2. IPv4 address of this machine.')
  print('\t3. The http address of the Observer server.')
  print('An example of a valid command:')
  print('\tC:\\Users\\ardor\\Desktop\\Observer\\lib\\field_agent 79.181.31.1 http://localhost:3000')

def lastModifiedFilename(dirPath):
  files = [f for f in os.listdir(dirPath) if os.path.isfile(os.path.join(dirPath, f))]
  sortedByLastModificationFiles = sorted(files, key=lambda f: os.path.getmtime(os.path.join(dirPath, f)))
  return os.path.join(dirPath, sortedByLastModificationFiles[-1])


def captureFileUpdated(lastTime, dirPath):
  latestModifiedFile = lastModifiedFilename(dirPath)
  updated = False
  try:
    latestTime = os.path.getmtime(latestModifiedFile)
    if latestTime > lastTime:
      updated = True
  except TypeError:
    updated = True
  return updated, latestTime, latestModifiedFile

def getCaptureData(filename):
  captureData = None
  continueReporting = True
  try:
    captureData = pyshark.FileCapture(filename)
  except FileNotFoundError as e:
    print(f"Failed to acces a file with capture data. Reason, {e}.")
    continueReporting = False
  return captureData, continueReporting

def getIcmpFloodIntelligence(captureData):
  result = {'ip': int(ipaddress.IPv4Address(currentIp)), 'incoming_req_count': 0}
  for packet in captureData:
    if 'icmp' in [ l.layer_name for l in packet.layers ]:
      if packet['dst'] == currentIp:
        result['incoming_req_count'] += 1
  return result

def getSqlInjectionIntelligence(captureData):
  result = {'ip': int(ipaddress.IPv4Address(currentIp)), 'uris': []}
  for packet in captureData:
    if 'http' in [ l.layer_name for l in packet.layers ]:
      try:
        request_uri = urllib.parse.unquote(packet.http.get('request_uri'))
        result['uris'].append(request_uri)
      except Exception:
        pass
  return result

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

if len(sys.argv) == 1:
  printHelp()
elif sys.argv[1] == 'help':
  printHelp()
else:
  captureFilename = ''
  captureDir = sys.argv[1]
  currentIp = sys.argv[2]
  observerUrl = sys.argv[3]
  routeBackendApi = '/backend_api'
  routeDosIcmpIntelligence = '/dos_icmp_intelligence'
  routeSqlInjectionIntelligence = '/sql_injection_intelligence'
  continueIcmpFloodIntelligence = True
  continueSqlInjectionIntelligence = True
  lastModificationTime = None
  delayInSeconds = 10

  while continueIcmpFloodIntelligence and continueSqlInjectionIntelligence:
    time.sleep(delayInSeconds)
    captureUpdated, lastModificationTime, captureFilename = captureFileUpdated(lastModificationTime, captureDir)
    captureData = None
    if captureUpdated:
      captureData, continueReporting = getCaptureData(captureFilename)
    if captureData is not None:
      if continueIcmpFloodIntelligence == True:
        icmpFloodIntelligence = {}
        icmpFloodIntelligence = getIcmpFloodIntelligence(captureData)
        print(icmpFloodIntelligence)
        backendApiAddressIcmpDosIntelligence = observerUrl + routeBackendApi + routeDosIcmpIntelligence
        continueIcmpFloodIntelligence = reportIntelligence(
          icmpFloodIntelligence,
          backendApiAddressIcmpDosIntelligence
        )
      if continueSqlInjectionIntelligence == True:
        sqlInjectionIntelligence = {}
        sqlInjectionIntelligence = getSqlInjectionIntelligence(captureData)
        backendApiAddressSqlInjectionIntelligence = observerUrl + routeBackendApi + routeSqlInjectionIntelligence
        print(sqlInjectionIntelligence)
        continueSqlInjectionIntelligence = reportIntelligence(
          sqlInjectionIntelligence,
          backendApiAddressSqlInjectionIntelligence
        )
  print('The script is finishing, because the monitoring has been stopped')
