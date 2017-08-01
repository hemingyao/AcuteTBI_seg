
%% 
function [rotate_angle,dis_vec, best_j]=rota_symm_search(centered_img, angle1, angle2, delta_ang, method)
%  exhaustively search rotating angles that make the skull image as
% symmetric as possible. delta_ang is the  degree of angle rotation each 
%   Detailed explanation goes here

% input: centered_img is the input image. rotation search will rotate the 
% image with the center of the image. angle1 and angle2 is the rotation
% search rangle

rotate_angle=0;
if(nargin<4)
    delta_ang=4;
end
if(nargin<5)
    method='mid2ct';
end
if(nargin==1)
    Max_ang=45; % max angle to rotate left and right
    N_rot=floor(Max_ang/delta_ang);
    min_angle=-Max_ang;
    max_angle=Max_ang;
elseif(nargin==2||nargin>5)
    fprintf('wrong number of parameters, need two angles to specify the range\n');
    return;
elseif(nargin>=3)
    min_angle=min(angle1,angle2);
    max_angle=max(angle1,angle2);
end

rota_img=imroate_with_fg(centered_img,0,'crop');

% for animation images
% folder='animation';
% if(isunix) 
%     del='/';
% else
%     del='\';
% end
% imwrite(rota_img, strcat('..',del,folder,del,'0.png'));


dissymm=dissymm_meas(rota_img, method)+1;
best_i=0;
% tic
range=[min_angle:delta_ang:max_angle];
dis_vec=zeros(1,length(range));
j=1;
best_j=1;
for it=range
%     rota_img=imrotate(centered_img,i,'nearest','crop');
    rota_img=imroate_with_fg(centered_img, it, 'crop');
    rota_img=bwmorph(rota_img, 'bridge');
     
     % for animation images
%      imwrite(rota_img, strcat('..',del,folder,del,int2str(i),'.png'));
     
    % imshow(rota_img);
    % dis = 1;
    dis=dissymm_meas(rota_img, method);
    dis_vec(j)=dis; 
    if(dis<dissymm)
        best_i=it;
        best_j=j;
        dissymm=dis;
    end
    j=j+1;
    % output
    % fprintf('Angle rotated: %f, Dissymm: %f\n',it,dis);
end

% output the best rotated angle
fprintf('Best rotated angle is: %f\n', best_i);
% toc

rotate_angle=best_i;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% This function rotate the image by only specify the foreground pixels
% There will be some small holes inside the rotated image, not solved yet
function rota_img=imroate_with_fg(centered_img, angle, method)

% input: centered_img is the image to be rotated. Only deals with m*n
% images

if(nargin<3)
    method='loose';
end
n_dim=ndims(centered_img);
if(n_dim==3)
    fprintf('Error: only deals with m*n images\n');
    rota_img=[];
    return;
end

[m,n]=size(centered_img);Canvas=zeros(m*2,n*2);
origin_x=floor(n/2); origin_y=floor(m/2); 
origin_x_new=n; origin_y_new=m;
[ind_m,ind_n]=find(centered_img);

N=length(ind_m);
angle_rad=angle*pi/180;
cos_angle=cos(angle_rad);
sin_angle=sin(angle_rad);
rotation_matrix=[cos_angle, sin_angle; -sin_angle, cos_angle];


% for i=1:N
%     x=ind_n-origin_x;
%     y=origin_y-ind_m;
%     p1=[x,y];
%     p_new=floor(p1*rotation_matrix);
%     ind_m_new=origin_y_new-p_new(2);
%     ind_n_new=p_new(1)+origin_x_new;
%     Canvas(ind_m_new,ind_n_new)=1;
% end

% get the above into matrix computing
X=ind_n-repmat(origin_x,N,1);
Y=repmat(origin_y,N,1)-ind_m;
P1=[X,Y];
P_new=floor(P1*rotation_matrix);
Ind_m_new=repmat(origin_y_new,N,1)-P_new(:,2);
Ind_n_new=P_new(:,1)+repmat(origin_x_new,N,1);
Ind=sub2ind(size(Canvas),Ind_m_new, Ind_n_new);
Canvas(Ind)=centered_img(sub2ind(size(centered_img),ind_m, ind_n));

if(strcmp(method,'loose'))
    rota_img=Canvas;
elseif(strcmp(method,'crop'))
    rota_img=Canvas([floor(m/2):floor(m/2)+m-1],[floor(n/2):floor(n/2)+n-1]);
else
    fprintf('wrong input of input\n');
end

end


%%
function dis=dissymm_meas(Img, method)
% symmetric measument: symm=\sum{i=1}{n}(|l_i-r_i|), i is the row index
% and l_i, r_i is the symmetry measure for each line. The center line 
% is the just the image center line: x=floor(size(img,2)/2)

if(nargin<2)
    method='mid2ct';
end
sum_dis=0;
[m,n]=size(Img);
c_line=floor(n/2);
r_center=floor(m/2);
dis_arr=zeros(1,m);
% debug
td=zeros(m,1);
lv=zeros(m,1);
rv=zeros(m,1);

for i=[1:m]%[r_center-100:1:r_center+255]
    left_pixels=Img(i,1:c_line);
    right_pixels=Img(i,c_line+1:n);
    r_i=vec_meas(right_pixels,method); 
    l_i=vec_meas(left_pixels(end:-1:1),method); % reverse the vector to apply method
    if(r_i==0 || l_i==0) % no need to count the crack for dissymmetry
        continue;
    end
    sum_dis=sum_dis+abs(r_i-l_i);
    lv(i)=l_i;
    rv(i)=r_i;
    td(i)=abs(r_i-l_i);
    dis_arr(i)=abs(r_i-l_i);
end


dis=sum_dis;

end

function vm=vec_meas(vec_pixels, method)

I=find(vec_pixels~=0);
if(isempty(I))
            vm=0;
            return;
end

switch method
    case 'force_tq'
        % calculate the force torque with the leftmost pixel as the fulcurm point
        ft=0;
        n=length(I);
        ft=sum(I);
        vm=ft;
    case 'thickness'
        % calculate the thickness
        vm = max(I)-min(I);
    case 'mid2ct'
        % calculate the middle point of the skull cut to the center
        vm =(max(I)+min(I))/2;
    case 'max'
        vm = max(I);
    case 'min'
        vm = min(I);
        
        
end

end