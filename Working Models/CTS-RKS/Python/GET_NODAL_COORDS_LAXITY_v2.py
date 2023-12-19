from odbAccess import *
import time, sys

filename = sys.argv[1]
num_nodes_input = int(sys.argv[2])
size_nodes_input = int(sys.argv[3])
node_start = []
print(range(num_nodes_input))
for counti in range(num_nodes_input):
    node_start.append(int(sys.argv[counti+4]))
numNodes = num_nodes_input*size_nodes_input
position = int(sys.argv[4+num_nodes_input])

print(numNodes)

odb = openOdb(path=filename)

# Want to append node numbers to historyRegionName
historyRegionNameTemplate = "Node PART-1-1"
historyOutputName = ["COOR1", "COOR2", "COOR3"]
step = odb.steps['LAXITY']

# Get number of frames from historyOutput
numframes=len(odb.steps['LAXITY'].frames)
#print numframes

flag=1
DataLength=0
data = [[0 for x in xrange(numframes)] for x in xrange(6*numNodes)]
counter1 = 0
counter2 = 0
headerline = ""

nodes = []
for countnodes in node_start:
    for current_node in range(size_nodes_input):
        nodes.append(countnodes+current_node)
print(nodes)

for node in nodes:
    historyRegionName = historyRegionNameTemplate + '.' + str(node)
    #print historyRegionName
    #print "\n"
	
    for HO in historyOutputName:
        historyRegion = step.historyRegions[historyRegionName]
		
        historyOutput = historyRegion.historyOutputs[HO].data
        #print historyOutput
        #print "\n"
	
        headerline += str(node)+"."+HO+".X\t" +str(node)+"."+HO+".Y\t"
        val_length = len(historyOutput)
        for (i,j) in historyOutput:
			
	         #print "i:" + str(i) + ",j:" + str(j)
	         #print str(counter1) + "," + str(counter2)
	         data[counter1][counter2] = i
	         #print str(counter1+1) + "," + str(counter2)
	         data[counter1+1][counter2] = j
	         counter2+=1
			
        counter1 = counter1+2
        counter2 = 0		
			


fname = "data" + str(position) + ".txt"
f1=open(fname,'w')

#Write header
#f1.write(headerline+"\n")
#Write data
for i in range(0,val_length):
	for j in range(0,len(data)):
		f1.write("%9.5f\t"%(data[j][i]))
	f1.write("\n")	
	
f1.close()
odb.close()	


