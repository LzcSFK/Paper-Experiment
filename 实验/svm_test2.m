clear all
clc

%读取训练数据
train_label=csvread('E:\traffic_data\20170101traffic\10.csv',2,2,[2 2 144 2]);
train_data=csvread('E:\traffic_data\20170101traffic\10.csv',1,1,[1 1 143 2]);

%time=csvread('E:\traffic_data\20170101traffic\10.csv',0,0);

% a = readtable('E:\traffic_data\20170101traffic\10.csv','format','%{HH:mm:ss}D%d%d');
% b=a(:,1);
% c=b(2:144,1);
% d=zeros(143,1);
% d=c;
% figure(1)
% plot(d,train_label,'r-*')
% xlabel('时  间')
% ylabel('车流量')
% grid on



%读取测试数据
test_label=csvread('E:\traffic_data\20170102traffic\10.csv',2,2,[2 2 144 2]);
test_data=csvread('E:\traffic_data\20170102traffic\10.csv',1,1,[1 1 143 2]);

%归一化
%训练集
[normalization_train_data,inputps] = mapminmax(train_data');
normalization_train_data = normalization_train_data';
normalization_test_data = mapminmax('apply',test_data',inputps);
normalization_test_data = normalization_test_data';

%测试集
[normalization_train_label,outputps] = mapminmax(train_label');
normalization_train_label = normalization_train_label';
normalization_test_label = mapminmax('apply',test_label',outputps);
normalization_test_label = normalization_test_label';

% SVM模型创建/训练
%
%1. 寻找最佳c参数/g参数
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

%
%2. 创建/训练SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
model = svmtrain(normalization_train_label,normalization_train_data,cmd);

% V. SVM仿真预测
[Predict_1,error_1] = svmpredict(normalization_train_label,normalization_train_data,model);
[Predict_2,error_2] = svmpredict(normalization_test_label,normalization_test_data,model);

%
%1. 反归一化
predict_1 = mapminmax('reverse',Predict_1,outputps);
predict_2 = mapminmax('reverse',Predict_2,outputps);

%
%2. 结果对比
result_1 = [train_label predict_1];
result_2 = [test_label predict_2];

% VI. 绘图

X = cell(144); %预先分配内存
for i = 0:1:23 %时从0到23
    for j = 0:10:50 %分从0到50，间隔10
       b = i*6+(j+10)/10; %计算是第几个标签
       if j ~= 0
        X{b} = [num2str(i),':',num2str(j)];
       else   %如果分是0在分后边再加一个0，凑成00
        X{b} = [num2str(i),':',num2str(j),num2str(0)]; 
       end
    end
end
X{145} = X{1}; %把0:00复制到最后一位
X{1} = [];%把第一位的0:00清除
a = 1:1:143;
figure(1)
plot(a,train_label,'r-*',a,predict_1,'b:o')
set(gca,'xtick',0:1:24*6)
set(gca,'xticklabel',X)
grid on
legend('真实值','预测值')
xlabel('时  间')
ylabel('车流量')
string_1 = {'训练集预测结果对比';
           ['mse = ' num2str(error_1(2)) ' R^2 = ' num2str(error_1(3))]};
title(string_1)

A  = cell(144); %预先分配内存
for i = 0:1:23 %时从0到23
    for j = 0:10:50 %分从0到50，间隔10
       b = i*6+(j+10)/10; %计算是第几个标签
       if j ~= 0
        A{b} = [num2str(i),':',num2str(j)];
       else   %如果分是0在分后边再加一个0，凑成00
        A{b} = [num2str(i),':',num2str(j),num2str(0)]; 
       end
    end
end
A{145} = A{1}; %把0:00复制到最后一位
A{1} = [];%把第一位的0:00清除
a = 1:1:143;
figure(2)
plot(a,test_label,'r-*',a,predict_2,'b:o')
set(gca,'xtick',0:1:24*6)
set(gca,'xticklabel',A)
grid on
legend('真实值','预测值')
xlabel('时  间')
ylabel('车流量')
string_2 = {'测试集预测结果对比';
           ['mse = ' num2str(error_2(2)) ' R^2 = ' num2str(error_2(3))]};
title(string_2)


% X = cell(144); %预先分配内存
% for i = 0:1:23 %时从0到23
%     for j = 0:10:50 %分从0到50，间隔10
%        b = i*6+(j+10)/10; %计算是第几个标签
%        if j ~= 0
%         X{b} = [num2str(i),':',num2str(j)];
%        else   %如果分是0在分后边再加一个0，凑成00
%         X{b} = [num2str(i),':',num2str(j),num2str(0)]; 
%        end
%     end
% end
% %X{145} = X{1}; %把0:00复制到最后一位
% X{1} = [];%把第一位的0:00清除
% x = 1:1:143;
% 
% y = 2*x;
% plot(x,y);%我随便画的函数
% set(gca,'xtick',0:1:24*6)%设置144个网格线
% set(gca,'xticklabel',X)  %每个网格线依次填X的值





