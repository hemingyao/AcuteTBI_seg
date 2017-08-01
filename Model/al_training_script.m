%%%%% Under development
%% Build the initial dataset for the first SVM model and pool dataset for active learning
train_index =pid_index(1:30);
test_index = pid_index(31:40);
[train_1_features, train_0_features] = build_train_and_test(PatientsData(train_index));

%%
train_1_features = train_1_features(:,feature_index);
train_0_features = train_0_features(:,feature_index);

train_features = [train_1_features; train_0_features];
train_mean = mean(train_features);
train_std = std(train_features,0,1);

train_1_pool = train_1_features;
train_0_pool = train_0_features;

index = randsample(length(train_1_features),1000);
train_1_initial = train_1_features(index,:);
train_1_pool(index,:) = [];

index = randsample(length(train_0_features),2000);
train_0_initial = train_0_features(index,:);
train_0_pool(index,:) = [];

train_initial = [train_1_initial; train_0_initial];
train_initial_class = [repelem(1,length(train_1_initial)), repelem(0,length(train_0_initial))]';
train_initial_norm = feature_normalization(train_initial , train_mean, train_std);

train_1_pool_norm = feature_normalization(train_1_pool , train_mean, train_std);
train_0_pool_norm = feature_normalization(train_0_pool , train_mean, train_std);

%%
model_SVM = fitcsvm(train_initial_norm, train_initial_class, 'KernelFunction', 'linear','Cost', [0 10;1 0]);
%%
score_model = fitSVMPosterior(model_SVM);
[label, score] = predict(score_model,test_features_norm(:,feature_index));
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
figure; plot(X, Y)


%% Based on distance and change ratio
pool_1_adaptive = train_1_pool_norm;
pool_0_adaptive = train_0_pool_norm;
train_features_adaptive = train_initial_norm;
train_class_adaptive = train_initial_class;
%score_update = score_model;

AUCs = [];
values_1 = [];
values_0 = [];

ratio = sum(train_class_adaptive==0)/sum(train_class_adaptive==1);
%model = model_SVM; 

model = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 2;ratio 0]);

%%
result_1 = evaluate_test(PatientsData,  test_index, feature_index, train_mean, train_std, model_SVM);
% score_update = fitSVMPosterior(model);
% [~, score] = predict(score_update, test_features_norm(:,feature_index));
% [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
% AUCs(end+1) = AUC;
%%
for loop = 1:1
    threshold = 0.1;
    distance_1 = pool_1_adaptive*model.Beta + model.Bias;
    distance_0 = pool_0_adaptive*model.Beta + model.Bias;
    distance_1 = abs(distance_1);
    distance_0 = abs(distance_0);

    index_0 = find(distance_0<threshold);
    index_1 = find(distance_1<threshold);
    if ~(length(index_0)+length(index_1))
        break
    end
    train_features_adaptive = [train_features_adaptive; pool_1_adaptive(index_1,:)];
    train_class_adaptive = [train_class_adaptive; repelem(1,length(index_1))'];

    train_features_adaptive = [train_features_adaptive; pool_0_adaptive(index_0,:)];
    train_class_adaptive = [train_class_adaptive; repelem(0,length(index_0))'];

    pool_1_adaptive(index_1,:) = [];
    pool_0_adaptive(index_0,:) = [];
    
    ratio = sum(train_class_adaptive==0)/sum(train_class_adaptive==1);
    %%
    model = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
    %%
    result_3 = evaluate_test(PatientsData,  test_index, feature_index, train_mean, train_std, model);
    
%     score_update = fitSVMPosterior(model_update);
%     [~, score] = predict(score_update,test_features_norm(:,feature_index));
%     [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
%     AUCs(end+1) = AUC;
%     AUCs
end



