import pyshark
import json
import requests
import ipaddress
intelligence = {}
cap = pyshark.FileCapture('dumpfile.pcap')
sources = {'ip': int(ipaddress.IPv4Address('79.181.31.6')), 'incoming_req_count': 0}
for p in cap:
  sources['incoming_req_count'] += 1
  print(f"{p['ip'].src}, {p['ip'].dst}")
print(sources)
try:
  r = requests.post('http://localhost:3000/backend_api/dos_icmp_intelligence', json=sources)
  print(r.status_code)
  print(r.text)
except requests.RequestException as e:
  print(e)
finally:
  pass
