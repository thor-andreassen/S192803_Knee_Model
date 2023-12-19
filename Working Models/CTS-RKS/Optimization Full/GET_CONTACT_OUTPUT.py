from odbAccess import *
import time, sys
import numpy as np


filename = sys.argv[1]
sNum = sys.argv[2]
odb = openOdb(path=filename)


# get elements
#session.openOdb(name='cube.odb').rootAssembly.instances['PART-1-1'].elementSets['CUBE-1_CUBE'].elements[el_numerator].connectivity[nod_numerator]
part=odb.rootAssembly.instances["PART-1-1"]
elem_list=part.elementSets.keys()
elem_contact = [s for s in elem_list if "CART-TIBIA-LAT" in s]
cart_lat_node=part.nodeSets["NODES-CART-TIBIA-LAT"]
cart_med_node=part.nodeSets["NODES-CART-TIBIA-MED"]

len(cart_lat_node.nodes)
# get element subsets
names_cart_list=[]
elements_cart_list=[]
nodes_cart_list=[]
node_list=[]

## Get Maximum contact pressure Field Data
frames=odb.steps['Step-2'].frames

max_press_lat=np.zeros((len(frames),1))
max_press_med=np.zeros((len(frames),1))

counter_frame=0
times=np.zeros((len(frames),1))
current_press=np.zeros((len(cart_lat_node.nodes),1))
for frame in frames:
    coord_field=frame.fieldOutputs['CPRESS']
    coord_field_lat=coord_field.getSubset(region=cart_lat_node)
    coord_field_med=coord_field.getSubset(region=cart_med_node)
    
    times[counter_frame,0]=frame.frameValue
    current_coord_value_lat=coord_field_lat.values
    current_coord_value_med=coord_field_med.values
    counter_node=0
    for current_node in current_coord_value_lat:
        current_press[counter_node]=current_node.data
        counter_node+=1
    frame_max=np.amax(current_press)
    max_press_lat[counter_frame]=frame_max
    
    counter_node=0
    for current_node in current_coord_value_med:
        current_press[counter_node]=current_node.data
        counter_node+=1
    frame_max=np.amax(current_press)
    max_press_med[counter_frame]=frame_max
    
    counter_frame+=1

#print(max_press_lat)
#print(max_press_med)

contact_mat=np.concatenate((np.array(times),max_press_lat,max_press_med),axis=1)
#print(np.shape(contact_mat))
#print(contact_mat)


fname = filename+"ContactPressure.csv"
f1=open(fname,'w')


#Write header
#f1.write(headerline+"\n")

f1.write("Time(s),   Lateral (MPa),   Medial (MPa)")
f1.write("\n")

# Write Data
for count_frame in range(0,len(frames)):
    for count_col in range(0,np.shape(contact_mat)[1]):
        f1.write("%f,   "%(contact_mat[count_frame,count_col]))
    f1.write("\n")
f1.close()











# Get coordinates of Tibia

tib_coordinates=np.zeros((len(frames),3))
tib_nodes=[1280001,1280002,1280003,1280004]
reference_nodeset=part.nodeSets["REF_FRAMES"]
print(reference_nodeset)

node_coord_dict={}
temp_mat=tib_coordinates
for count_nodes in tib_nodes:
    node_coord_dict[str(count_nodes)]=tib_coordinates.copy()


counter_frame=0
times=np.zeros((len(frames),1))
for frame in frames:
    coord_field=frame.fieldOutputs['COORD']
    coord_field_ref=coord_field.getSubset(region=reference_nodeset)
    
    times[counter_frame,0]=frame.frameValue
    current_coord_value_ref=coord_field_ref.values
    
    for current_node in current_coord_value_ref:
        current_coord=current_node.data
        current_label=current_node.nodeLabel
        if node_coord_dict.has_key(str(current_label)):
            temp_mat=node_coord_dict[str(current_label)]
            temp_mat[counter_frame,:]=current_coord
            node_coord_dict[str(current_label)]=temp_mat
    counter_frame+=1



# create Transforms for Tibia

def createTForm(origin, x, y):
    vecx=(x-origin)/np.linalg.norm(x-origin) 
    tempy=(y-origin)/np.linalg.norm(y-origin)
    vecz=np.cross(vecx,tempy)/(np.linalg.norm(np.cross(vecx,tempy)))
    vecy=np.cross(vecz,vecx)/(np.linalg.norm(np.cross(vecz,vecx)))
    trans_vec=origin
    rotmat=np.empty((3,3))
    rotmat[:, 0]=vecx
    rotmat[:, 1]=vecy
    rotmat[:, 2]=vecz
    TransMat=np.identity(4)
    TransMat[0:3, 0:3]=rotmat
    TransMat[0:3, -1]=np.transpose(trans_vec)
    localToGlobalTransMat=TransMat
    globalToLocalTransMat=np.linalg.inv(TransMat)
    return localToGlobalTransMat, globalToLocalTransMat


origin_pt=node_coord_dict["1280001"]
x_pt=node_coord_dict["1280002"]
y_pt=node_coord_dict["1280003"]

TCS_to_GCS_TransMat=np.zeros((4,4,len(times)))
GCS_to_TCS_TransMat=np.zeros((4,4,len(times)))

for count_frame in range(0,len(times)):
    x_pt_temp=x_pt[count_frame,:]
    y_pt_temp=y_pt[count_frame,:]
    origin_pt_temp=origin_pt[count_frame,:]
    (temp_TCS_to_GCS,temp_GCS_to_TCS)=createTForm(origin_pt_temp,x_pt_temp,y_pt_temp)
    
    TCS_to_GCS_TransMat[:,:,count_frame]=temp_TCS_to_GCS
    GCS_to_TCS_TransMat[:,:,count_frame]=temp_GCS_to_TCS


GCS_to_TCS_RotMat=GCS_to_TCS_TransMat[0:3,0:3,:]



# get Contact AREA

step=odb.steps['Step-2']
region=step.historyRegions

region=step.historyRegions['ElementSet  PIBATCH']
test=region.historyOutputs

CAREA_FEM=region.historyOutputs['CAREA on surface SURF-CART-FEMUR']
CAREA_MED=region.historyOutputs['CAREA on surface SURF-CART-TIBIA-MED']
CAREA_LAT=region.historyOutputs['CAREA on surface SURF-CART-TIBIA-LAT']


CAREA_med_output=np.zeros((len(CAREA_MED.data),2))
counter=0
for count_med in CAREA_MED.data:
    current_val_list=list(count_med)
    current_val_array=np.array(current_val_list)
    CAREA_med_output[counter,:]=current_val_array
    counter+=1


CAREA_lat_output=np.zeros((len(CAREA_LAT.data),2))
counter=0
for count_lat in CAREA_LAT.data:
    current_val_list=list(count_lat)
    current_val_array=np.array(current_val_list)
    CAREA_lat_output[counter,:]=current_val_array
    counter+=1

CAREA_fem_output=np.zeros((len(CAREA_FEM.data),2))
counter=0
for count_fem in CAREA_FEM.data:
    current_val_list=list(count_fem)
    current_val_array=np.array(current_val_list)
    CAREA_fem_output[counter,:]=current_val_array
    counter+=1
    
CAREA_data=np.concatenate((CAREA_fem_output,CAREA_lat_output,CAREA_med_output),axis=1)
CAREA_data=CAREA_data[:,[0,1,3,5]]
#print(np.shape(CAREA_data))

fname = filename+"CAREA.csv"
f1=open(fname,'w')


#Write header
#f1.write(headerline+"\n")

f1.write("Time(s),   FEM CAREA (mm^2),   LAT CAREA (mm^2), MED CAREA (mm^2)")
f1.write("\n")

# Write Data
for count_frame in range(0,len(frames)):
    for count_col in range(0,np.shape(CAREA_data)[1]):
        f1.write("%f,   "%(CAREA_data[count_frame,count_col]))
    f1.write("\n")
f1.close()





# get Contact FORCES
step=odb.steps['Step-2']
region=step.historyRegions

region=step.historyRegions['ElementSet  PIBATCH']
test=region.historyOutputs
print(test)

CFN1_LAT=region.historyOutputs['CFN1 on surface SURF-CART-TIBIA-LAT']
CFN2_LAT=region.historyOutputs['CFN2 on surface SURF-CART-TIBIA-LAT']
CFN3_LAT=region.historyOutputs['CFN3 on surface SURF-CART-TIBIA-LAT']
CFN1_MED=region.historyOutputs['CFN1 on surface SURF-CART-TIBIA-MED']
CFN2_MED=region.historyOutputs['CFN2 on surface SURF-CART-TIBIA-MED']
CFN3_MED=region.historyOutputs['CFN3 on surface SURF-CART-TIBIA-MED']

CFN_output=np.zeros((len(CFN1_LAT.data),7))
counter=0
for count_cfn in CFN1_LAT.data:
    current_val_list=list(count_cfn)
    current_val_array=np.array(current_val_list)
    CFN_output[counter,[0,1]]=current_val_array
    counter+=1

counter=0
for count_cfn in CFN2_LAT.data:
    current_val_list=list(count_cfn)
    current_val_array=np.array(current_val_list)
    CFN_output[counter,2]=current_val_array[1]
    counter+=1
  
counter=0  
for count_cfn in CFN3_LAT.data:
    current_val_list=list(count_cfn)
    current_val_array=np.array(current_val_list)
    CFN_output[counter,3]=current_val_array[1]
    counter+=1
   
counter=0   
for count_cfn in CFN1_MED.data:
    current_val_list=list(count_cfn)
    current_val_array=np.array(current_val_list)
    CFN_output[counter,4]=current_val_array[1]
    counter+=1
    
counter=0
for count_cfn in CFN2_MED.data:
    current_val_list=list(count_cfn)
    current_val_array=np.array(current_val_list)
    CFN_output[counter,5]=current_val_array[1]
    counter+=1
    
counter=0
for count_cfn in CFN3_MED.data:
    current_val_list=list(count_cfn)
    current_val_array=np.array(current_val_list)
    CFN_output[counter,6]=current_val_array[1]
    counter+=1




CFN_output_newcs=CFN_output.copy()
for count_cfn in range(0,len(CFN3_MED.data)):
    current_force_lat=CFN_output[count_cfn,1:4]
    current_rotmat=GCS_to_TCS_RotMat[:,:,count_cfn]
    new_force_lat=np.dot(current_rotmat,current_force_lat)
    CFN_output_newcs[count_cfn,1:4]=new_force_lat
    
    current_force_med=CFN_output[count_cfn,4:]
    current_rotmat=GCS_to_TCS_RotMat[:,:,count_cfn]
    new_force_lat=np.dot(current_rotmat,current_force_med)
    CFN_output_newcs[count_cfn,4:]=new_force_lat
    
#print(np.shape(CFN_output_newcs))



fname = filename+"ContactForce.csv"
f1=open(fname,'w')


#Write header
#f1.write(headerline+"\n")

f1.write("Time(s),   Lat CTFN1 TCS (N),   Lat CTFN2 TCS (N), Lat CTFN3 TCS (N),   Med CTFN1 TCS (N),   Med CTFN2 TCS (N), Med CTFN3 TCS (N),")
f1.write("\n")

# Write Data
for count_frame in range(0,len(frames)):
    for count_col in range(0,np.shape(CFN_output_newcs)[1]):
        f1.write("%f,   "%(CFN_output_newcs[count_frame,count_col]))
    f1.write("\n")
f1.close()
