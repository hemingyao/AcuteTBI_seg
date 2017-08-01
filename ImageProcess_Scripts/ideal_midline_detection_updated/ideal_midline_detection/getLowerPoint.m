function [linePoint, I_lower_uppest, boneInlower_boximg,boxRect_lower, isFoundLowerUppest, rev] = ...\
    getLowerPoint(rota_bwSkullBone,rota_original_img);
% get bump of lower
%   Detailed explanation goes here

% find the upper bump

rev = 0;
boneInlower_boximg=[];
boxRect_lower = [0,0,0,0];
isFoundLowerUppest = true;
linePoint = [0,0];

%% draw a box near the point lower part of the skull
center_x = floor(size(rota_bwSkullBone,2)/2); % half size of the number of colum
center_y = floor(size(rota_bwSkullBone,1)/2); % half size of the number of row
vec_midline = rota_bwSkullBone(:,center_x);  % get a vector whose colum number = cneter_x
I = find(vec_midline>0);
if(isempty(I)) % there is no intersection between the center line and bone.
    rev = 1;
    return;
end

% set the box around the highest point of lower part
% Half_width_upper = 80;
% Half_height_upper = 60;

I_lower=I(find(I>center_y));
I_lower_uppest=min(I_lower);

Half_width_lower=floor(60*size(rota_original_img,2)/512);
Half_height_lower=floor(80*size(rota_original_img,2)/512);

x_left_lower=center_x-Half_width_lower;
x_right_lower=center_x+Half_width_lower;
y_lower_sm=I_lower_uppest-Half_height_lower;
y_lower_lg=I_lower_uppest+Half_height_lower;

boxRect_lower=[x_left_lower, x_right_lower, y_lower_sm,y_lower_lg];

%% crop the lower part of the image
cropRect_lower=[x_left_lower,y_lower_sm,x_right_lower-x_left_lower,y_lower_lg-y_lower_sm-1];
% boxRect_lower = cropRect_lower;
img_lower=imcrop(rota_original_img,cropRect_lower);
boneInlower_boximg=img_lower;

%% find the lower part of midline point by detecting the gray line in the
%% lowpart
%% all the processing are in the lower part box:
%% boxRect_lower=[x_left, x_right, y_lower_sm,y_lower_lg];

line_uppest=zeros(1,x_right_lower-x_left_lower+1); %% for lower part of the skull

j=1;
for i=[x_left_lower: x_right_lower]
    vec_line=rota_bwSkullBone(:,i);
    I_bone=find(vec_line>0);
    
    %% for lower part
    I_bone_box3=I_bone(find(I_bone<=y_lower_lg));
    I_bone_box4=I_bone_box3(find(I_bone_box3>=y_lower_sm));
    I_box_uppest=min(I_bone_box4);
    
    if(isempty(I_box_uppest))
        line_uppest(j)=y_lower_lg;
    else
        line_uppest(j)=I_box_uppest;
    end
    
    
    j=j+1;
end

%% get the midline lower point
mask_line=line_uppest-y_lower_sm+1;
[rev,ml_pt]=get_lower_mlpoint(img_lower,mask_line);
if( rev ~=0 )
    return;
end

if ((ml_pt(1)==0)&&(ml_pt(2)==0))
    fprintf('Failed to detect lines in the lower part of the skull, use mass center instead \n');
    isFoundLowerUppest = false;
end
ml_pt_img=[x_left_lower+ml_pt(1)-1,y_lower_sm+ml_pt(2)-1];
linePoint=ml_pt_img;

end

