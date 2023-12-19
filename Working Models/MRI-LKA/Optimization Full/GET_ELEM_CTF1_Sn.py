from odbAccess import *
import time, sys

filename = sys.argv[1]
elemNum = sys.argv[2]
sNum = sys.argv[3]
odb = openOdb(path=filename)

# Want to append node numbers to historyRegionName
stepString = 'Step-' + sNum	
step = odb.steps[stepString]
historyRegionNameTemplate = "Element PART-1-1"
historyOutputName = ["CTF1"]

historyRegionName = historyRegionNameTemplate + '.' + str(elemNum)

for HO in historyOutputName:
	historyRegion = step.historyRegions[historyRegionName]
	
	historyOutput = historyRegion.historyOutputs[HO].data
	for frame in historyOutput:
		b = frame[0]
		c = frame[1]
		print str(b)+','+str(c)		

odb.close()	


