%%%% Negar Farzaneh August 2016 %%%%%%
tic
%subj={'num','startS','endS'};
subj{1}={'116','00020001','00020030'};subj{2}={'120','00020001','00020032'};
subj{3}={'121','00070001','00070031'};subj{4}={'147','00430001','00430033'};
subj{5}={'226','03460001','03460029'};subj{6}={'269','04260001','04260029'};
subj{7}={'270','04290001','04290028'};subj{8}={'271','04320001','04320028'};
subj{9}={'273','04380001','04380026'};subj{10}={'278','04440001','04440028'};
subj{11}={'279','04470001','04470029'};subj{12}={'281','04500001','04500032'};
subj{13}={'283','04560001','04560029'};subj{14}={'286','04620001','04620026'};
subj{15}={'287','04650001','04650031'};subj{16}={'289','04680001','04680030'};
subj{17}={'290','04710001','04710030'};subj{18}={'291','04740001','04740031'};
subj{19}={'294','04800001','04800027'};subj{20}={'295','04830001','04830027'};
subj{21}={'307','04960001','04960029'};subj{22}={'308','04990001','04990030'};
subj{23}={'314','05050001','05050027'};subj{24}={'317','05110001','05110028'};
subj{25}={'320','05200001','05200027'};subj{26}={'324','05260001','05260030'};
subj{27}={'327','05290001','05290029'};subj{28}={'332','05380001','05380027'};
subj{29}={'338','05520001','05520029'};subj{30}={'339','05550001','05550029'};
subj{31}={'340','05580001','05580031'};subj{32}={'342','05610001','05610030'};
subj{33}={'345','05670001','05670030'};subj{34}={'346','05700001','05700031'};
subj{35}={'350','05730001','05730032'};subj{36}={'352','05760001','05760028'};
subj{37}={'354','05790001','05790031'};subj{38}={'356','05850001','05850029'};
subj{39}={'360','05880001','05880032'};subj{40}={'364','05940001','05940027'};
subj{41}={'366','05990001','05990029'};subj{42}={'368','06020001','06020029'};
subj{43}={'369','06050001','06050027'};subj{44}={'372','06080001','06080027'};
subj{45}={'375','06110001','06110029'};subj{46}={'378','06170001','06170028'};
subj{47}={'380','06200001','06200027'};subj{48}={'381','06230001','06230031'};
subj{49}={'382','06260001','06260027'};subj{50}={'383','06290001','06290029'};
subj{51}={'385','06320001','06320030'};subj{52}={'389','06360001','06360030'};
subj{53}={'390','06390001','06390026'};subj{54}={'392','06420001','06420029'};
subj{55}={'393','06450001','06450032'};subj{56}={'398','06510001','06510028'};
subj{56}={'399','06540001','06540029'};
%subj{49}={'','',''};subj{50}={'','',''};
% subjects(1).num ={'116','120','121','147'};
% subjects.startS={'00020001','00020001','00070001','00430001'};
% subjects.endS = {'00020030','00020032','00070031','00430033'};
windowSize=7; %to get Xbefore + Xafter + 1 itself = (2X+1)*(2X+1) window
data= struct('subject',{},'age',{},'boneDist',{},'topDist',{},'minInt',{},'maxInt',{},'meanInt',{},'entropy',{}, ... 
    'stdInt',{},'HEM',{},'smoothness',{}); % slice num is important as well. ventricles' volume better indicator than age

T=[];
for subjNum=1:length(subj)
subjNum
inputN=subj{subjNum}{1};
fullImageDirRoot=['Z:\Massey2016\',inputN];
imgList = dir(strcat(fullImageDirRoot, '/', '*'));
load(['Z:\Massey2016\',inputN,'.mat']);
inf= dicominfo([fullImageDirRoot,'\',imgList(3).name]);
%% image intensity must be normalize based on bone intensity(I guess)
[normalizedImg,bone,ind]=normalization(fullImageDirRoot,subj{subjNum}{2},subj{subjNum}{3});

[SizeNormScale,brainMask]= SizeNormalization(bone);

%% To remove points that have wrong coordinate or missing values
% Future : There should be a criteria to remove the points whith 
% coordinates located in image but not on the brain
delIndex=[];
for i=1:length(s)
    if s(i).cX<0 || s(i).cX >512 || s(i).cY<0 || s(i).cY>512
        delIndex=[delIndex,i];
        %disp('He..he..he');
    elseif isempty(s(i).type)
        delIndex=[delIndex,i];
    elseif  brainMask(round(s(i).cX),round(s(i).cY))==0 %to remove wrong points,refine in future 
        delIndex=[delIndex,i];
        disp('He..he..he');
    end
end
s(delIndex)=[];

%% detect to look for which layer in the 3rd Dim  
layer=[];
for i=1:length(s)
    for j=1:length(ind)
        if strcmp(ind{j,1},cellstr(s(i).name))
            layer=[layer;j];
        end
    end
end

for i=1:length(s) %
    s(i).cX=round(s(i).cX);
    s(i).cY=round(s(i).cY);
    targetBone=bone(:,:,layer(i));
    
    
%     filledSkull=imfill(targetBone,'holes');
%     hole=filledSkull-targetBone; %for sure there's easier way to mask holes
%     CC = bwconncomp(hole);
%     numPixels = cellfun(@numel,CC.PixelIdxList);
%     [biggest,idx] = max(numPixels);
%     brain=zeros(size(hole));
%     brain(CC.PixelIdxList{idx})=1; %label the largest component as brain
%     azmoonBrain=cat(3,azmoonBrain,brain);
%     if brain(s(i).cX,s(i).cY)==0 %to remove wrong points,refine in future 
%         continue
%     end
   
    
    
    %%
    data(i).subject=str2num(inputN);
    
    window = normalizedImg(s(i).cX-windowSize:s(i).cX+windowSize, ...
        s(i).cY-windowSize:s(i).cY+windowSize,layer(i)); 
    windowPixel=window(window<2498); % to remove bone pixels
    meanInt=mean(windowPixel);
    stdInt=std(windowPixel);
    
    hist=[];
    for ppp=min(windowPixel):max(windowPixel)
        hist=[hist,length(find(windowPixel==ppp))];
    end
    pro=hist/(2*windowSize+1)^2;
    pro(pro==0)=[];
    entr=0;
    for ppp=1:length(pro)
        entr=entr-pro(ppp)*log2(pro(ppp));
    end
    
    %entr = entropy(windowPixel); %it doesn't work?????? maskhare 
    smoothness=1-1/(1+stdInt^2/2500);%2500 is chosen based on the max range
    
    data(i).minInt=min(windowPixel);
    data(i).maxInt=max(windowPixel);
    data(i).meanInt = meanInt;
    data(i).stdInt = stdInt;
    data(i).entropy= entr;
    data(i).smoothness=smoothness;
    if strcmp(s(i).type,'Hem')
        data(i).HEM=1;
    elseif strcmp(s(i).type,'NotHem')
        data(i).HEM=0;
    end
    
    %targetBone=bone(:,:,layer(i));
    [A1,A2]=find(targetBone==1);
    d=min((A1-s(i).cX).^2 + (A2-s(i).cY).^2);
    d = round(sqrt(d));
    data(i).boneDist=d;
    
    data(i).topDist=str2num(subj{subjNum}{3})-str2num(s(i).name);
    
    age=inf.PatientAge;
    age=age(1:end-1); % to remove "Y"
    age=str2num(age);
    data(i).age=age;  
    
end
T = [T;struct2table(data)];
clear data
end
toc
%% Median Filtering
img2med = double(medfilt2(img));
% img2n = medfilt2(img2new);
% imshow(uint8(img2n));
% img2n = double(img2n);

%% Histogram of intracranial matter and Subracting graymatter intensit
[a,~]=hist(img2med(:),256);
[~,grval]=max(a(10:end));
img2hist = double(img2med) - (img2med>0)*(grval);