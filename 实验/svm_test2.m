clear all
clc

%��ȡѵ������
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
% xlabel('ʱ  ��')
% ylabel('������')
% grid on



%��ȡ��������
test_label=csvread('E:\traffic_data\20170102traffic\10.csv',2,2,[2 2 144 2]);
test_data=csvread('E:\traffic_data\20170102traffic\10.csv',1,1,[1 1 143 2]);

%��һ��
%ѵ����
[normalization_train_data,inputps] = mapminmax(train_data');
normalization_train_data = normalization_train_data';
normalization_test_data = mapminmax('apply',test_data',inputps);
normalization_test_data = normalization_test_data';

%���Լ�
[normalization_train_label,outputps] = mapminmax(train_label');
normalization_train_label = normalization_train_label';
normalization_test_label = mapminmax('apply',test_label',outputps);
normalization_test_label = normalization_test_label';

% SVMģ�ʹ���/ѵ��
%
%1. Ѱ�����c����/g����
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
%2. ����/ѵ��SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
model = svmtrain(normalization_train_label,normalization_train_data,cmd);

% V. SVM����Ԥ��
[Predict_1,error_1] = svmpredict(normalization_train_label,normalization_train_data,model);
[Predict_2,error_2] = svmpredict(normalization_test_label,normalization_test_data,model);

%
%1. ����һ��
predict_1 = mapminmax('reverse',Predict_1,outputps);
predict_2 = mapminmax('reverse',Predict_2,outputps);

%
%2. ����Ա�
result_1 = [train_label predict_1];
result_2 = [test_label predict_2];

% VI. ��ͼ

X = cell(144); %Ԥ�ȷ����ڴ�
for i = 0:1:23 %ʱ��0��23
    for j = 0:10:50 %�ִ�0��50�����10
       b = i*6+(j+10)/10; %�����ǵڼ�����ǩ
       if j ~= 0
        X{b} = [num2str(i),':',num2str(j)];
       else   %�������0�ڷֺ���ټ�һ��0���ճ�00
        X{b} = [num2str(i),':',num2str(j),num2str(0)]; 
       end
    end
end
X{145} = X{1}; %��0:00���Ƶ����һλ
X{1} = [];%�ѵ�һλ��0:00���
a = 1:1:143;
figure(1)
plot(a,train_label,'r-*',a,predict_1,'b:o')
set(gca,'xtick',0:1:24*6)
set(gca,'xticklabel',X)
grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('ʱ  ��')
ylabel('������')
string_1 = {'ѵ����Ԥ�����Ա�';
           ['mse = ' num2str(error_1(2)) ' R^2 = ' num2str(error_1(3))]};
title(string_1)

A  = cell(144); %Ԥ�ȷ����ڴ�
for i = 0:1:23 %ʱ��0��23
    for j = 0:10:50 %�ִ�0��50�����10
       b = i*6+(j+10)/10; %�����ǵڼ�����ǩ
       if j ~= 0
        A{b} = [num2str(i),':',num2str(j)];
       else   %�������0�ڷֺ���ټ�һ��0���ճ�00
        A{b} = [num2str(i),':',num2str(j),num2str(0)]; 
       end
    end
end
A{145} = A{1}; %��0:00���Ƶ����һλ
A{1} = [];%�ѵ�һλ��0:00���
a = 1:1:143;
figure(2)
plot(a,test_label,'r-*',a,predict_2,'b:o')
set(gca,'xtick',0:1:24*6)
set(gca,'xticklabel',A)
grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('ʱ  ��')
ylabel('������')
string_2 = {'���Լ�Ԥ�����Ա�';
           ['mse = ' num2str(error_2(2)) ' R^2 = ' num2str(error_2(3))]};
title(string_2)


% X = cell(144); %Ԥ�ȷ����ڴ�
% for i = 0:1:23 %ʱ��0��23
%     for j = 0:10:50 %�ִ�0��50�����10
%        b = i*6+(j+10)/10; %�����ǵڼ�����ǩ
%        if j ~= 0
%         X{b} = [num2str(i),':',num2str(j)];
%        else   %�������0�ڷֺ���ټ�һ��0���ճ�00
%         X{b} = [num2str(i),':',num2str(j),num2str(0)]; 
%        end
%     end
% end
% %X{145} = X{1}; %��0:00���Ƶ����һλ
% X{1} = [];%�ѵ�һλ��0:00���
% x = 1:1:143;
% 
% y = 2*x;
% plot(x,y);%����㻭�ĺ���
% set(gca,'xtick',0:1:24*6)%����144��������
% set(gca,'xticklabel',X)  %ÿ��������������X��ֵ





