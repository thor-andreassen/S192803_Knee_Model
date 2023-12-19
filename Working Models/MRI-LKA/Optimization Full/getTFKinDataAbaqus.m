function [gskin_sim]=getTFKinDataAbaqus(jobName)
    system(['abaqus python GET_NODAL_COORDS_LAXITY_v2.py ',jobName,'.odb 2 4 1280001 1980001 1']);
    data_raw = dlmread('data1.txt','\t');
    data_raw = data_raw(:,[1,2:2:end]);
    
    times=data_raw;
    
    for count_times=1:size(data_raw,1)
        temp_data = data_raw(count_times,2:end);
        data(:,:,count_times) = reshape(temp_data,3,size(temp_data,2)/3)';
    end
    
    for count_times=1:size(data,3)
        tib_origin=data(1,:,count_times);
        tib_plusx=data(2,:,count_times);
        tib_plusy=data(3,:,count_times);
        tib_plusz=data(4,:,count_times);
        tib_TransMat(:,:,count_times)=getTransMatFromNodes(tib_origin,tib_plusx,tib_plusy,tib_plusz);
        
        fem_origin=data(5,:,count_times);
        fem_plusx=data(6,:,count_times);
        fem_plusy=data(7,:,count_times);
        fem_plusz=data(8,:,count_times);
        fem_TransMat(:,:,count_times)=getTransMatFromNodes(fem_origin,fem_plusx,fem_plusy,fem_plusz);
        tib_to_fem_TransMat(:,:,count_times)=fem_TransMat(:,:,count_times)*inv(tib_TransMat(:,:,count_times));
        gskin_sim(count_times,:)=calculateGSKinFromTransMat(tib_to_fem_TransMat(:,:,count_times),'L');
    end
end