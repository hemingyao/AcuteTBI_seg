function [seg_kmean, pixScale, numOfEffectPix , pixnum, rev] = get_kmeam_init_more_for_li8(Img_M)

% filter the image and decrease the effect of edge gita curve caused by rotate
% Img_M = stru(i_pos).imStru.img_Mattress;

rev = 0;
pixScale = 0;
Img_M = medfilt2(Img_M, [5,5]);
numOfEffectPix = 0;
pixnum = [0, 0 ,0 , 0];

%% use k-means for initialization
ind_mask = find(Img_M~=0);
gray_roi_vec = Img_M(ind_mask);

k_c=4;
kseeds = [40, 80, 100, 255]';
[idx, mc]=kmeans(double(gray_roi_vec), k_c, 'start', kseeds, 'EmptyAction', 'singleton'); 

if(isempty(find(unique(idx)==1)))
    rev = 1;
    return;
end

pixnum = [length(find(idx==1)), length(find(idx==2)),length(find(idx==3)),length(find(idx==4))];
numOfEffectPix = pixnum(1);

if pixnum(1) < 100 || pixnum(2)>45000
    pixScale = 0;
else
    pixScale = double(double(pixnum(2))/double(pixnum(1)));
end

label_2D = zeros(size(Img_M));
label_2D(ind_mask) = idx;

vent_map_kmean = zeros(size(Img_M));

clu_count = 0;
% for i_k=1:k_c
i_k = 1;
lab_mask=zeros(size(label_2D));
lab_ind=find(label_2D==i_k);
clu_count=clu_count+1;
lab_mask(lab_ind)=clu_count;
% clear small spots
    [L, num]=bwlabel(lab_mask);
    for i=1:num
        ind_lab=find(L==i);
        if(length(ind_lab)<60)
            lab_mask(ind_lab)=0;
        end
    end
vent_map_kmean = vent_map_kmean + lab_mask;
seg_kmean = vent_map_kmean;
% end

end
