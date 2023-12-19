from odbAccess import *
import time, sys
import numpy as np
from scipy import io

filename = sys.argv[1]
step_name = sys.argv[2]
odb = openOdb(path=filename)


# get elements
#session.openOdb(name='cube.odb').rootAssembly.instances['PART-1-1'].elementSets['CUBE-1_CUBE'].elements[el_numerator].connectivity[nod_numerator]
part=odb.rootAssembly.instances["PART-1-1"]
elem_list=part.elementSets.keys()
elem_contact = [s for s in elem_list if "CART-TIBIA-LAT" in s]
# cart_lat_node=part.nodeSets["NODES-CART-TIBIA-LAT"]
# cart_med_node=part.nodeSets["NODES-CART-TIBIA-MED"]


# print(part.surfaces['SURF-CART-TIBIA-LAT'])
# len(cart_lat_node.nodes)
# get element subsets
names_cart_list=[]
elements_cart_list=[]
nodes_cart_list=[]
node_list=[]

## Get Maximum contact pressure Field Data
frames=odb.steps[step_name].frames

max_press_lat=np.zeros((len(frames),1))
max_press_med=np.zeros((len(frames),1))

    
counter_frame=0
for frame in frames:
    
    coord_field=frame.fieldOutputs['CPRESS   SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
    coord_field_lat=coord_field
    # times[counter_frame,0]=frame.frameValue
    current_coord_value_lat=coord_field_lat.values
    node_num=len(current_coord_value_lat)
    break


lat_CP_data=np.zeros((len(frames),node_num))
node_numbers_lat=np.zeros((node_num,1))
valid_frames=np.zeros((len(frames),1))
times=np.zeros((len(frames),1))
counter_frame=0
for frame in frames:
    try:
        coord_field=frame.fieldOutputs['CPRESS   SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
        coord_field_lat=coord_field
        times[counter_frame,0]=frame.frameValue
        current_coord_value_lat=coord_field_lat.values
        
        counter_node=0
        for current_node in current_coord_value_lat:
            lat_CP_data[counter_frame,counter_node]=current_node.data
            node_numbers_lat[counter_node,0]=current_node.nodeLabel
            counter_node+=1
        
        valid_frames[counter_frame,0]=1
        counter_frame+=1
    except:
        # print('frame does not exist')
        valid_frames[counter_frame,0]=0
        counter_frame
valid_frames2=np.ndarray.flatten(valid_frames==1)
times=times[valid_frames==1]
lat_CP_data=lat_CP_data[valid_frames2,:]

frames=odb.steps[step_name].frames
counter_frame=0






for frame in frames:
    
    coord_field2=frame.fieldOutputs['CPRESS   SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']
    coord_field_med=coord_field2
    # times[counter_frame,0]=frame.frameValue
    current_coord_value_med=coord_field_med.values
    node_num2=len(current_coord_value_med)
    break


med_CP_data=np.zeros((len(frames),node_num2))
node_numbers_med=np.zeros((node_num2,1))
valid_frames=np.zeros((len(frames),1))
times=np.zeros((len(frames),1))
counter_frame=0
for frame in frames:
    try:
        coord_field2=frame.fieldOutputs['CPRESS   SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']
        coord_field_med=coord_field2
        times[counter_frame,0]=frame.frameValue
        current_coord_value_med=coord_field_med.values
        
        counter_node=0
        for current_node in current_coord_value_med:
            med_CP_data[counter_frame,counter_node]=current_node.data
            node_numbers_med[counter_node,0]=current_node.nodeLabel
            counter_node+=1
        
        valid_frames[counter_frame,0]=1
        counter_frame+=1
    except:
        # print('frame does not exist')
        valid_frames[counter_frame,0]=0
        counter_frame

valid_frames2=np.ndarray.flatten(valid_frames==1)
times=times[valid_frames==1]
med_CP_data=med_CP_data[valid_frames2,:]



fname = filename+"_ContactPressureMap.mat"
io.savemat(fname, {'LAT_CP': lat_CP_data,'MED_CP':med_CP_data, 'Times':times,'Valid_Frames':valid_frames,'LAT_Node_Numbers':node_numbers_lat,'MED_Node_Numbers':node_numbers_med})







# get Contact AREA

step=odb.steps[step_name]
region=step.historyRegions

region=step.historyRegions['ElementSet  PIBATCH']
test=region.historyOutputs


CAREA_MED=region.historyOutputs['CAREA    SURF-CART-FEMUR-ART/SURF-CART-TIBIA-MED']
CAREA_LAT=region.historyOutputs['CAREA    SURF-CART-FEMUR-ART/SURF-CART-TIBIA-LAT']


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

    
CAREA_data=np.concatenate((CAREA_lat_output,CAREA_med_output),axis=1)
CAREA_data=CAREA_data[:,[0,1,3]]
#print(np.shape(CAREA_data))

fname = filename+"CAREA.csv"
f1=open(fname,'w')


#Write header
#f1.write(headerline+"\n")

f1.write("Time(s),   LAT CAREA (mm^2), MED CAREA (mm^2)")
f1.write("\n")

# Write Data
for count_frame in range(0,np.shape(CAREA_data)[0]):
    for count_col in range(0,np.shape(CAREA_data)[1]):
        f1.write("%f,   "%(CAREA_data[count_frame,count_col]))
    f1.write("\n")
f1.close()

fname = filename+"_ContactArea.mat"
io.savemat(fname, {'CAREA_LAT': CAREA_lat_output,'CAREA_MED':CAREA_med_output})








# get XN DATA



    # Get Center projection vector

step=odb.steps[step_name]
region=step.historyRegions

region=step.historyRegions['ElementSet  PIBATCH']
test=region.historyOutputs

XN1_LAT=region.historyOutputs['XN1      SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
XN2_LAT=region.historyOutputs['XN2      SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
XN3_LAT=region.historyOutputs['XN3      SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
XN1_MED=region.historyOutputs['XN1      SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']
XN2_MED=region.historyOutputs['XN2      SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']
XN3_MED=region.historyOutputs['XN3      SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']


XN_output=np.zeros((len(XN1_LAT.data),7))

counter=0
for count_xn in XN1_LAT.data:
    current_val_list=list(count_xn)
    current_val_array=np.array(current_val_list)
    XN_output[counter,[0,1]]=current_val_array
    counter+=1

counter=0
for count_xn in XN2_LAT.data:
    current_val_list=list(count_xn)
    current_val_array=np.array(current_val_list)
    XN_output[counter,[0,2]]=current_val_array
    counter+=1
    
counter=0
for count_xn in XN3_LAT.data:
    current_val_list=list(count_xn)
    current_val_array=np.array(current_val_list)
    XN_output[counter,[0,3]]=current_val_array
    counter+=1

counter=0
for count_xn in XN1_MED.data:
    current_val_list=list(count_xn)
    current_val_array=np.array(current_val_list)
    XN_output[counter,[0,4]]=current_val_array
    counter+=1
    
counter=0
for count_xn in XN2_MED.data:
    current_val_list=list(count_xn)
    current_val_array=np.array(current_val_list)
    XN_output[counter,[0,5]]=current_val_array
    counter+=1

counter=0
for count_xn in XN3_MED.data:
    current_val_list=list(count_xn)
    current_val_array=np.array(current_val_list)
    XN_output[counter,[0,6]]=current_val_array
    counter+=1
    


# get Contact FORCES
step=odb.steps[step_name]
region=step.historyRegions

region=step.historyRegions['ElementSet  PIBATCH']
test=region.historyOutputs

CFN1_LAT=region.historyOutputs['CFN1     SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
CFN2_LAT=region.historyOutputs['CFN2     SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
CFN3_LAT=region.historyOutputs['CFN3     SURF-CART-TIBIA-LAT/SURF-CART-FEMUR-ART']
CFN1_MED=region.historyOutputs['CFN1     SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']
CFN2_MED=region.historyOutputs['CFN2     SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']
CFN3_MED=region.historyOutputs['CFN3     SURF-CART-TIBIA-MED/SURF-CART-FEMUR-ART']

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



load_data=np.concatenate((XN_output,CFN_output[:,1:]),axis=1)


fname = filename+"_ContactLoad.csv"
f1=open(fname,'w')

f1.write("Time(s),   XN1_LAT (mm),  XN2_LAT (mm),   XN3_LAT (mm),   XN1_MED (mm),   XN2_MED (mm),   XN3_MED (mm)")
f1.write(",   CFN1_LAT (mm),  CFN2_LAT (mm),   CFN3_LAT (mm),   CFN1_MED (mm),   CFN2_MED (mm),   CFN3_MED (mm)")
f1.write("\n")

# Write Data
for count_frame in range(0,np.shape(load_data)[0]):
    for count_col in range(0,np.shape(load_data)[1]):
        f1.write("%f,   "%(load_data[count_frame,count_col]))
    f1.write("\n")
f1.close()












# Get coordinates of Tibia

tib_coordinates=np.zeros((len(frames),3))
tib_nodes=[1280001,1280002,1280003,1280004]
reference_nodeset=part.nodeSets["REF_FRAMES"]

node_coord_dict={}
temp_mat=tib_coordinates
for count_nodes in tib_nodes:
    node_coord_dict[str(count_nodes)]=tib_coordinates.copy()


counter_frame=0
times=np.zeros((len(frames),1))
valid_frames=np.zeros((len(frames),1))
for frame in frames:
    try:
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
            valid_frames[counter_frame,0]=1
        counter_frame+=1
    except:
        valid_frames[counter_frame,0]=0



# create Transforms for Tibia

def createTForm(origin, x, y):
    try:
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
    except:
        localToGlobalTransMat=np.identity(4)
        globalToLocalTransMat=np.identity(4)
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



valid_frames2=np.ndarray.flatten(valid_frames==1)
times=times[valid_frames==1]
TCS_to_GCS_TransMat=TCS_to_GCS_TransMat[:,:,valid_frames2]
GCS_to_TCS_TransMat=GCS_to_TCS_TransMat[:,:,valid_frames2]

GCS_to_TCS_RotMat=GCS_to_TCS_TransMat[0:3,0:3,:]





# convert force and points to tibial coordinate system


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
    


# transform center point value

XN_output_newcs=XN_output.copy()
for count_xn in range(0,len(XN3_MED.data)):
    current_x_lat=np.zeros((4))+1
    current_x_lat[0:3]=XN_output[count_xn,1:4]
    current_transmat=GCS_to_TCS_TransMat[:,:,count_xn]
    new_x_lat=np.dot(current_transmat,current_x_lat)
    XN_output_newcs[count_xn,1:4]=new_x_lat[0:3]
    

    current_x_lat=np.zeros((4))+1
    current_x_lat[0:3]=XN_output[count_xn,4:]
    current_transmat=GCS_to_TCS_TransMat[:,:,count_xn]
    new_x_lat=np.dot(current_transmat,current_x_lat)
    XN_output_newcs[count_xn,4:]=new_x_lat[0:3]

fname = filename+"_COP.mat"
io.savemat(fname, {'COPTCS': XN_output_newcs,'COPGCS': XN_output, 'Force_Vector_TCS':CFN_output_newcs,'Force_Vector_GCS':CFN_output,'GCS_to_TCS_TransMat':GCS_to_TCS_TransMat})
