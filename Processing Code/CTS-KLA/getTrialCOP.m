function [COP_pts]=getTrialCOP(COP_XN,Force_Vector,faces,nodes)

    %% determine unit vectors
    vert0=nodes(faces(:,1),:);
    vert1=nodes(faces(:,2),:);
    vert2=nodes(faces(:,3),:);

    COP_pts=zeros(size(COP_XN));
    for count_pt=1:size(COP_XN,1)
        try
            unit_vec1=Force_Vector(count_pt,:)/norm(Force_Vector(count_pt,:));
            [intersect, ~, ~, ~, xcoor] = TriangleRayIntersection (...
          COP_XN(count_pt,:), unit_vec1, vert0, vert1, vert2,'lineType','line');

            nearest_pt=xcoor(intersect,:);
            if size(nearest_pt,2)>1
                [~,I]=max(nearest_pt(:,3));
                nearest_pt=nearest_pt(I,:);
            end
        catch
            nearest_pt=[NaN, NaN, NaN];
        end
        if length(nearest_pt)<3
            nearest_pt=[NaN, NaN, NaN];
        end
        COP_pts(count_pt,:)=nearest_pt;
    end


end