%% ��ջ���
clc
clear

%��ȡѵ������
train_label=csvread('E:\traffic_data\20170101traffic\10.csv',2,2,[2 2 144 2]);
train_data=csvread('E:\traffic_data\20170101traffic\10.csv',1,1,[1 1 143 2]);

%��ȡ��������
test_label=csvread('E:\traffic_data\20170103traffic\10.csv',2,2,[2 2 144 2]);
test_data=csvread('E:\traffic_data\20170103traffic\10.csv',1,1,[1 1 143 2]);


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

%% ������ʼ��

%����Ⱥ�㷨�е���������
c1 = 2.05; % c1 belongs to [0,2]
c2 = 2.05; % c2 belongs to [0,2]
phi = c1 + c2;
elta = 2/abs(2-phi-sqrt(phi*phi-4*phi));


maxgen=300;   % �������� 
sizepop=50;   % ��Ⱥ��ģ

popcmax=10^(2);
popcmin=10^(-2);
popgmax=10^(3);
popgmin=10^(-2);
k = 0.6; % k belongs to [0.1,1.0];
Vcmax = k*popcmax;
Vcmin = -Vcmax ;
Vgmax = k*popgmax;
Vgmin = -Vgmax ;
Wmax = 0.9;
Wmin = 0.4;
% SVM������ʼ�� 
v = 3;

%% ������ʼ���Ӻ��ٶ�
for i=1:sizepop
    % ���������Ⱥ
    pop(i,1) = (popcmax-popcmin)*rand+popcmin;    % ��ʼ��Ⱥ
    pop(i,2) = (popgmax-popgmin)*rand+popgmin;
    V(i,1)=Vcmax*rands(1); % ��ʼ���ٶ�
    V(i,2)=Vgmax*rands(1);
    % �����ʼ��Ӧ��
    cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(i,1) ),' -g ',num2str( pop(i,2) ),' -s 3 -p 0.1'];
    fitness(i) = svmtrain(normalization_train_label,normalization_train_data,cmd);
    fitness(i) = -fitness(i);
end

% �Ҽ�ֵ�ͼ�ֵ��

[global_fitness bestindex]=min(fitness); % ȫ�ּ�ֵ
local_fitness=fitness;   % ���弫ֵ��ʼ��

global_x=pop(bestindex,:);   % ȫ�ּ�ֵ��
local_x=pop;    % ���弫ֵ���ʼ��

tic

%% ����Ѱ��
for i=1:maxgen
   
    for j=1:sizepop
       
        %�ٶȸ���
        %wV = 0.9; % wV best belongs to [0.8,1.2]
        
        wV = Wmax - (Wmax - Wmin)*i*i/(maxgen*maxgen);
        V(j,:) = elta * (wV*V(j,:) + c1*rand*(local_x(j,:) - pop(j,:)) + c2*rand*(global_x - pop(j,:)));
        if V(j,1) > Vcmax
            V(j,1) = Vcmax;
        end
        if V(j,1) < Vcmin
            V(j,1) = Vcmin;
        end
        if V(j,2) > Vgmax
            V(j,2) = Vgmax;
        end
        if V(j,2) < Vgmin
            V(j,2) = Vgmin;
        end
       
        %��Ⱥ����
        wP = 0.6;
        pop(j,:)=pop(j,:)+V(j,:);
        if pop(j,1) > popcmax
            pop(j,1) = popcmax;
        end
        if pop(j,1) < popcmin
            pop(j,1) = popcmin;
        end
        if pop(j,2) > popgmax
            pop(j,2) = popgmax;
        end
        if pop(j,2) < popgmin
            pop(j,2) = popgmin;
        end
       
        % ����Ӧ���ӱ���
%         if rand>0.5
%             k=ceil(2*rand);
%             if k == 1
%                 pop(j,k) = (20-1)*rand+1;
%             end
%             if k == 2
%                 pop(j,k) = (popgmax-popgmin)*rand+popgmin;
%             end           
%         end
       
        %��Ӧ��ֵ
        cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(j,1) ),' -g ',num2str( pop(j,2) ),' -s 3 -p 0.1'];
        fitness(j) = svmtrain(normalization_train_label,normalization_train_data,cmd);
        fitness(j) = -fitness(j);
    end
    
    for j=1:sizepop
        %�������Ÿ���
        if fitness(j) < local_fitness(j)
            local_x(j,:) = pop(j,:);
            local_fitness(j) = fitness(j);
        end

        %Ⱥ�����Ÿ���
        if fitness(j) < global_fitness
            global_x = pop(j,:);
            global_fitness = fitness(j);
        end
    end
    fit_gen(i)=global_fitness;   
       
end

toc

bestc = global_x(1)
bestg = global_x(2)

% ����/ѵ��SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
model = svmtrain(normalization_train_label,normalization_train_data,cmd);

% SVM����Ԥ��
[Predict_1,error_1] = svmpredict(normalization_train_label,normalization_train_data,model);
[Predict_2,error_2] = svmpredict(normalization_test_label,normalization_test_data,model);

%����һ��
predict_1 = mapminmax('reverse',Predict_1,outputps);
predict_2 = mapminmax('reverse',Predict_2,outputps);

% ����Ա�
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

