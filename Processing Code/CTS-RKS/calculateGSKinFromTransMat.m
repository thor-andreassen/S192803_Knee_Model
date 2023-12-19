function kin_raw=calculateGSKinFromTransMat(TransMat,RL)
% Created by Thor Andreassen
% 4/23/20
% The following code takes ina transformation matrix of one bone to another
% bone and calculates the resulting kinematics according to the Grood and
% Suntay 1983 paper, by using a floating axis and 2 body fixed coordinate
% systems.

% Inputs
% TransMat
%    This variable is a single Transformation matrix of the format
%    1 0
%    T R
%
% RL
%    This variable is used to swap the coordinate if R vs. L use RL='R' or
%    RL='L'. If no value is given, the default is "R"
%
%
% Outputs
% kin_raw
%    This output variable is a row vector containing the GS kinematics in
%    the following order:
%        'Flexion(+)/Extension(-)','Varus(-)/Valgus(+)','Internal(-)/External(+)'
%        'Medial(-)/Lateral(+)','Anterior(+)/Posterior(-)','Superior(+)/Inferior(-)'
%    NOTE: the angular values: FE, VV, and IE are outputted in degrees.
    if nargin<2
        RL='R'
    elseif nargin==2

    else
        error('wrong number of inputs to calculate GS kinematics')
    end
    
    kin_raw=zeros(1,6);
    kin_raw(1)=atan(TransMat(3,4)/TransMat(4,4));
    if kin_raw(1)<-0.5 %To flip sign when flexion goes past 90 degrees
        kin_raw(1)=kin_raw(1)+pi;
    end
    kin_raw(2)=acos(TransMat(2,4))-pi/2; %VV angle
    kin_raw(3)=atan(TransMat(2,3)/TransMat(2,2)); %IE angle
    kin_raw(4)=TransMat(2,1); %ML translation
    kin_raw(5)=TransMat(3,1)*cos(kin_raw(1))-TransMat(4,1)*sin(kin_raw(1)); %AP translation (text has TF_raw(1,4))
    kin_raw(6)=(TransMat(2,4)*TransMat(2,1)+TransMat(3,4)*TransMat(3,1)+TransMat(4,4)*TransMat(4,1)); %SI translation

    if RL=='L'
        kin_raw(2:4)=kin_raw(2:4)*-1;
    end

    kin_raw(1:3)=kin_raw(1:3)*180/pi;
end