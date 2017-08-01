%% Data Preparation

%% Extract brain imags from each patient
Patients_Protected = [38, 43, 76, 80, 88, 94, 100, 109, 113, 122, 125, 183, 284, 332, 380];
Patients_TrauImg = [147, 149, 155, 176, 177, 180, 190, 209, 212, 222,256, 270, 271, 273, 283, 289, 307, 324, 366, 369, 378, 380, 389, 390, 392];

PatientsData = [];
Patients = Patients_Protected;
for p = 1:length(Patients)
    p
    [PatientsData(p).brain_pos,  PatientsData(p).annots, PatientsData(p).brain_neg, ...
        PatientsData(p).pos_idx, PatientsData(p).neg_idx] = BrainImage_pid(Patients(p), 'Protected');
    PatientsData(p).Pid = Patients(p);
    PatientsData(p).Datatype = 'Protected';
end

PatientsData_Protected = PatientsData;
PatientsData = [];
Patients = Patients_TrauImg;
for p = 1:length(Patients)
    p
    [PatientsData(p).brain_pos,  PatientsData(p).annots, PatientsData(p).brain_neg, ...
        PatientsData(p).pos_idx, PatientsData(p).neg_idx] = BrainImage_pid(Patients(p), 'TrauImg');
    PatientsData(p).Pid = Patients(p);
     PatientsData(p).Datatype = 'TrauImg';
end

PatientsData_TrauImg = PatientsData;

PatientsData = [PatiensData_Protected, PatientsData_TrauImg];

%% Extracted Features for Each Slice
%% Build Positive Dataset and Negative Dataset for each patient
for p = 1:length(PatientsData)
    p
    brains = PatientsData(p).brain_pos;
    %mask = PatientsData(p).mask;
    annotations = PatientsData(p).annots;
    
    if size(brains, 3)>4
        sel =randsample(size(brains, 3),4);
        brains = brains(:,:,sel);
        %mask = mask(:,:,sel);
        annotations = annotations(:,:,:,sel);
    end
    
    roi = brains;
    [positive_dataset, negative_dataset, annotated_slices] = build_dataset(brains, roi, annotations);
    PatientsData(p).PosData = positive_dataset;
    PatientsData(p).NegData = negative_dataset;
    PatientsData(p).annotated_slices = annotated_slices;
   
end