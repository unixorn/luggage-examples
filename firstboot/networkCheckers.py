#!/usr/bin/python

import subprocess, time

def networkUp():
# Determine if networking interfaces are up by looking for a valid ethernet address.
# Returns: Boolean. True if MAC address is found, False otherwise.
	cmd = ['/sbin/ifconfig', '-a', 'ether']
	proc = subprocess.Popen(cmd, shell=False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(output, err) = proc.communicate()
	lines = str(output).splitlines()
	for line in lines:
		if 'ether' in line:
			parts = line.split()
			addr = parts[1]
			if not addr in ['', '00:00:00:00:00']:
				return True
	return False

network_up = False
for i in range(360):
   if not networkUp():
       time.sleep(.5)
   else:
	network_up = True
   break

if network_up:
  cmd = ['/usr/bin/touch', '/Users/Shared/.networkup.txt']
  proc = subprocess.Popen(cmd, shell=False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  (output, err) = proc.communicate()
