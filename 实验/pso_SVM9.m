%% ��ջ���
clc
clear

% %��ȡѵ������
train_label=csvread('E:\traffic_data\20170102traffic\10.csv',2,2,[2 2 144 2]);
train_data=csvread('E:\traffic_data\20170102traffic\10.csv',1,1,[1 1 143 2]);


% %��ȡ��������
test_label=csvread('E:\traffic_data\20170104traffic\10.csv',2,2,[2 2 144 2]);
test_data=csvread('E:\traffic_data\20170104traffic\10.csv',1,1,[1 1 143 2]);


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
c2 = 2; % 0.001*i^2 belongs to [0,2]
c3 = 1.5;
phi = c1 + 0.001*i^2;
elta = 2/abs(2-phi-sqrt(phi*phi-4*phi));


maxgen=200;   % �������� 
sizepop=20;   % ��Ⱥ��ģ

popcmax=400;
popcmin=150;
popgmax=0.0015;
popgmin=0.00019;
k = 0.6; % k belongs to [0.1,1.0];
Vcmax = k*popcmax;
Vcmin = -Vcmax ;
Vgmax = k*popgmax;
Vgmin = -Vgmax ;
Wmax = 0.9;
Wmin = 0.4;

Pavr = zeros(1,20);

% SVM������ʼ�� 
v = 3;

%% ������ʼ���Ӻ��ٶ�

z(1,1) = rand;
z(1,2) = rand;

for i=1:19
    
    z(i+1,1)=4*z(i,1)*(1-z(i,1));
    z(i+1,2)=4*z(i,2)*(1-z(i,2));
    
end

for i=1:sizepop
    pop(i,1) = (popcmax-popcmin)*z(i,1)+popcmin;
    pop(i,2) = (popgmax-popgmin)*z(i,2)+popgmin;
%     V(i,1)=Vcmax*rands(1); % ��ʼ���ٶ�
%     V(i,2)=Vgmax*rands(1);
    % �����ʼ��Ӧ��
    cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(i,1) ),' -g ',num2str( pop(i,2) ),' -s 3 -p 0.03'];
    fitness(i) = svmtrain(normalization_train_label,normalization_train_data,cmd);
    fitness(i) = -fitness(i);
end

% �Ҽ�ֵ�ͼ�ֵ��

[Gbest bestindex]=min(fitness); % ȫ�ּ�ֵ
Pbest=fitness;   % ���弫ֵ��ʼ��

Gbest_X=pop(bestindex,:);   % ȫ�ּ�ֵ��
Pbest_X=pop;    % ���弫ֵ���ʼ��

tic

%% ����Ѱ��
for i=1:maxgen
   
    for j=1:sizepop

        if(fitness(j) > Pbest(j) && fitness(j) < mean(pop(:)))
            Pavr(j) = fitness(j);
        end

        
        if (c1*rand*(Pbest_X(j,:) - pop(j,:)) + 0.001*i^2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:)))>0
            b = rand;
            disp(b);
        end
        
        if (c1*rand*(Pbest_X(j,:) - pop(j,:)) + 0.001*i^2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:)))<0
            b = -rand;
            disp(b)
        end
        
        %��Ⱥ����
      
%         wP = Wmax - (Wmax - Wmin)*i*i/maxgen;
%         wP = Wmax - (Wmax - Wmin)/(i*maxgen)^2;
%         wP = 0.9 - 0.002*i;
%         wP = Wmin + (Wmax - Wmin)*((maxgen - i)/maxgen)^0.9;
        wP = Wmax*(Wmin/Wmax)^(1/(1+i/maxgen));
%         pop(j,:)=pop(j,:)+wP*V(j,:);
        pop(j,:) = wP*pop(j,:) + 65*(1/i)*rand*(Pbest_X(j,:) - pop(j,:)) + 0.001*i^2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:))+...
                    b*(65*(1/i)*rand*(Pbest_X(j,:) - pop(j,:)) + 0.001*i^2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:)));
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
        if rand>0.5
            k=ceil(2*rand);
            if k == 1
                pop(j,k) = (20-1)*rand+1;
            end
            if k == 2
                pop(j,k) = (popgmax-popgmin)*rand+popgmin;
            end           
        end
       
        %��Ӧ��ֵ
        cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(j,1) ),' -g ',num2str( pop(j,2) ),' -s 3 -p 0.03'];
        fitness(j) = svmtrain(normalization_train_label,normalization_train_data,cmd);
        fitness(j) = -fitness(j);
     
        if fitness(j) >= -65
           continue;
        end
        

        %�������Ÿ���
        if fitness(j) < Pbest(j)
            Pbest_X(j,:) = pop(j,:);
            Pbest(j) = fitness(j);
        end
        
        %Ⱥ�����Ÿ���
        if fitness(j) < Gbest
            Gbest_X = pop(j,:);
            Gbest = fitness(j);
        end
        
   end     

    aa(i) = Gbest;
end

toc

bestc = Gbest_X(1)
bestg = Gbest_X(2)
%bestCVaccuarcy = -fit_gen(maxgen);
% ����/ѵ��SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.03'];
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
set(gca,'xtick',0:6:24*6)
set(gca,'xticklabel',X)
% grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('ʱ  ��')
ylabel('������')
string_1 = {'ѵ����Ԥ�����Ա�';
           ['mse = ' num2str(error_1(2)) ' R^2 = ' num2str(error_1(3))]};
title(string_1)

A = cell(24); %Ԥ�ȷ����ڴ�
for i = 0:1:24 %ʱ��0��23
    for j = 1:24 %�ִ�0��50�����10
       b = j; %�����ǵڼ�����ǩ
%        if j ~= 0
%         A{b} = [num2str(i),':',num2str(j)];
%        else   %�������0�ڷֺ���ټ�һ��0���ճ�00
        A{b} = [num2str(i),':',num2str(0),num2str(0)]; 
       
    end
end
A{145} = A{1}; %��0:00���Ƶ����һλ
A{1} = [];%�ѵ�һλ��0:00���
a = 1:1:24;
figure(2)
plot(a,test_label,'r-*',a,predict_2,'b:o')
set(gca,'xtick',0:6:24*6)
set(gca,'xticklabel',A)
% grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('ʱ  ��')
ylabel('������')
string_2 = {'���Լ�Ԥ�����Ա�';
           ['mse = ' num2str(error_2(2)) ' R^2 = ' num2str(error_2(3))]};
title(string_2)

figure(3)
x=0:24;
plot(test_label,'r-*',predict_2,'b:o')
X={'00:00' '01:00' '02:00' '03:00' '04:00' '05:00' '06:00' '07:00' '08:00' '09:00' '10:00' '11:00' '12:00' '13:00' '14:00' '15:00' '16:00' '17:00' '18:00' '19:00' '20:00' '21:00' '22:00' '23:00' '24:00'};
set(gca,'XTickLabel',X)
legend('��ʵֵ','Ԥ��ֵ')
xlabel('ʱ  ��')
ylabel('������')
string_2 = {'���Լ�Ԥ�����Ա�';
           ['mse = ' num2str(error_2(2)) ' R^2 = ' num2str(error_2(3))]};
title(string_3)







