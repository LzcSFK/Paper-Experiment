clear all
clc

%读取数据
label=csvread('E:\traffic_data\20170101traffic\10.csv',2,2,[2 2 144 2]);
data=csvread('E:\traffic_data\20170101traffic\10.csv',1,1,[1 1 143 2]);
time=csvread('E:\traffic_data\20170101traffic\10.csv',1,1,[1 1 143 2]);
%随机产生测试集和训练集
n = randperm(size(data,1));

%训练集100个样本
train_data = data(n(1:100),:);
train_label = label(n(1:100),:);

%测试集43个样本
test_data = data(n(101:end),:);
test_label = label(n(101:end),:);

%归一化
%%训练集
[normalization_train_data,inputps] = mapminmax(train_data');
normalization_train_data = normalization_train_data';
normalization_test_data = mapminmax('apply',test_data',inputps);
normalization_test_data = normalization_test_data';
%测试集
[normalization_train_label,outputps] = mapminmax(train_label');
normalization_train_label = normalization_train_label';
normalization_test_label = mapminmax('apply',test_label',outputps);
normalization_test_label = normalization_test_label';

%% SVM模型创建/训练
%%
% 1. 寻找最佳c参数/g参数
[c,g] = meshgrid(-10:0.5:10,-10:0.5:10);
[m,n] = size(c);
cg = zeros(m,n);
eps = 10^(-4);
v = 5;
bestc = 0;
bestg = 0;
error = Inf;
for i = 1:m
    for j = 1:n
        cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str(2^c(i,j)),' -g ',num2str(2^g(i,j) ),' -s 3 -p 0.1'];
        cg(i,j) = svmtrain(normalization_train_label,normalization_train_data,cmd);
        if cg(i,j) < error
            error = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end
        if abs(cg(i,j) - error) <= eps && bestc > 2^c(i,j)
            error = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end
    end
end
%%
% 2. 创建/训练SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
model = svmtrain(normalization_train_label,normalization_train_data,cmd);

%% V. SVM仿真预测
[Predict_1,error_1] = svmpredict(normalization_train_label,normalization_train_data,model);
[Predict_2,error_2] = svmpredict(normalization_test_label,normalization_test_data,model);

%%
% 1. 反归一化
predict_1 = mapminmax('reverse',Predict_1,outputps);
predict_2 = mapminmax('reverse',Predict_2,outputps);

%%
% 2. 结果对比
result_1 = [train_label predict_1];
result_2 = [test_label predict_2];

%% VI. 绘图
figure(1)
plot(1:length(train_label),train_label,'r-*',1:length(train_label),predict_1,'b:o')
grid on
legend('真实值','预测值')
xlabel('时  间')
ylabel('车流量')
string_1 = {'训练集预测结果对比';
           ['mse = ' num2str(error_1(2)) ' R^2 = ' num2str(error_1(3))]};
title(string_1)
figure(2)
plot(1:length(test_label),test_label,'r-*',1:length(test_label),predict_2,'b:o')
grid on
legend('真实值','预测值')
xlabel('时  间')
ylabel('车流量')
string_2 = {'测试集预测结果对比';
           ['mse = ' num2str(error_2(2)) ' R^2 = ' num2str(error_2(3))]};
title(string_2)





