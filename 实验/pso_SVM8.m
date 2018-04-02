%% 清空环境
clc
clear

% %读取训练数据
train_label=csvread('E:\traffic_data\20170102traffic\10.csv',2,2,[2 2 144 2]);
train_data=csvread('E:\traffic_data\20170102traffic\10.csv',1,1,[1 1 143 2]);

% train_label=csvread('E:\traffic_data\20170103traffic\10.csv',2,2,[2 2 144 2]);
% train_data=csvread('E:\traffic_data\20170103traffic\10.csv',1,1,[1 1 143 2]);
% 
% %读取测试数据
test_label=csvread('E:\traffic_data\20170101traffic\10.csv',2,2,[2 2 144 2]);
test_data=csvread('E:\traffic_data\20170101traffic\10.csv',1,1,[1 1 143 2]);

% test_label=csvread('E:\traffic_data\20170101traffic\10.csv',2,2,[2 2 144 2]);
% test_data=csvread('E:\traffic_data\20170101traffic\10.csv',1,1,[1 1 143 2]);

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

%% 参数初始化

%粒子群算法中的两个参数
c1 = 2.05; % c1 belongs to [0,2]
c2 = 2; % c2 belongs to [0,2]
c3 = 1.5;
phi = c1 + c2;
elta = 2/abs(2-phi-sqrt(phi*phi-4*phi));


maxgen=200;   % 进化次数 
sizepop=20;   % 种群规模

popcmax=500;
popcmin=200;
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

% SVM参数初始化 
v = 3;

%% 产生初始粒子和速度
% for i=1:sizepop
%     % 随机产生种群
%     pop(i,1) = (popcmax-popcmin)*rand+popcmin;    % 初始种群
%     pop(i,2) = (popgmax-popgmin)*rand+popgmin;
%     V(i,1)=Vcmax*rands(1); % 初始化速度
%     V(i,2)=Vgmax*rands(1);
%     % 计算初始适应度
%     cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(i,1) ),' -g ',num2str( pop(i,2) ),' -s 3 -p 0.1'];
%     fitness(i) = svmtrain(normalization_train_label,normalization_train_data,cmd);
%     fitness(i) = -fitness(i);
% end


% clc
% clear
% 
% popcmax=800;
% popcmin=200;
% popgmax=0.01;
% popgmin=0.0001;

z(1,1) = rand;
z(1,2) = rand;

for i=1:19
    
    z(i+1,1)=4*z(i,1)*(1-z(i,1));
    z(i+1,2)=4*z(i,2)*(1-z(i,2));
    
end

for i=1:sizepop
    pop(i,1) = (popcmax-popcmin)*z(i,1)+popcmin;
    pop(i,2) = (popgmax-popgmin)*z(i,2)+popgmin;
%     V(i,1)=Vcmax*rands(1); % 初始化速度
%     V(i,2)=Vgmax*rands(1);
    % 计算初始适应度
    cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(i,1) ),' -g ',num2str( pop(i,2) ),' -s 3 -p 0.1'];
    fitness(i) = svmtrain(normalization_train_label,normalization_train_data,cmd);
    fitness(i) = -fitness(i);
end

% 找极值和极值点

[Gbest bestindex]=min(fitness); % 全局极值
Pbest=fitness;   % 个体极值初始化

Gbest_X=pop(bestindex,:);   % 全局极值点
Pbest_X=pop;    % 个体极值点初始化

% 每一代种群的平均适应度
% avgfitness_gen = zeros(1,maxgen);

% for i = 1:sizepop
%     if(fitness(i) > Pbest(i) && fitness(i) < mean(pop(:)))
%         Pavr(i) = fitness(i);
%     end
% end

% disp()
% disp(mean(pop(:)));
% disp(Pavr);

tic

%% 迭代寻优
for i=1:maxgen
   
    for j=1:sizepop

        if(fitness(j) > Pbest(j) && fitness(j) < mean(pop(:)))
            Pavr(j) = fitness(j);
        end

        
        if (c1*rand*(Pbest_X(j,:) - pop(j,:)) + c2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:)))>0
            b = rand;
            disp(b);
        end
        
        if (c1*rand*(Pbest_X(j,:) - pop(j,:)) + c2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:)))<0
            b = -rand;
            disp(b)
        end
        
        %种群更新
      
%         wP = Wmax - (Wmax - Wmin)*i*i/maxgen;
%         wP = Wmax - (Wmax - Wmin)/(i*maxgen)^2;
        wP = 0.9 - 0.002*i;
%         pop(j,:)=pop(j,:)+wP*V(j,:);
        pop(j,:) = wP*pop(j,:) + c1*rand*(Pbest_X(j,:) - pop(j,:)) + c2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:))+...
                    b*(c1*rand*(Pbest_X(j,:) - pop(j,:)) + c2*rand*(Gbest_X - pop(j,:)) + c3*rand*( Pavr(j) - pop(j,:)));
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
       
        % 自适应粒子变异
        if rand>0.5
            k=ceil(2*rand);
            if k == 1
                pop(j,k) = (20-1)*rand+1;
            end
            if k == 2
                pop(j,k) = (popgmax-popgmin)*rand+popgmin;
            end           
        end
       
        %适应度值
        cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str( pop(j,1) ),' -g ',num2str( pop(j,2) ),' -s 3 -p 0.1'];
        fitness(j) = svmtrain(normalization_train_label,normalization_train_data,cmd);
        fitness(j) = -fitness(j);
     
        if fitness(j) >= -65
           continue;
        end
        

        %个体最优更新
        if fitness(j) < Pbest(j)
            Pbest_X(j,:) = pop(j,:);
            Pbest(j) = fitness(j);
        end
        
        %群体最优更新
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
% 创建/训练SVM  
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
model = svmtrain(normalization_train_label,normalization_train_data,cmd);

% SVM仿真预测
[Predict_1,error_1] = svmpredict(normalization_train_label,normalization_train_data,model);
[Predict_2,error_2] = svmpredict(normalization_test_label,normalization_test_data,model);

%反归一化
predict_1 = mapminmax('reverse',Predict_1,outputps);
predict_2 = mapminmax('reverse',Predict_2,outputps);

% 结果对比
result_1 = [train_label predict_1];
result_2 = [test_label predict_2];


% VI. 绘图
figure(3)
plot(aa)
title('最优个体适应度值','fontsize',12);
grid on
xlabel('进化代数','fontsize',12);
ylabel('适应度值','fontsize',12);

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

A = cell(144); %预先分配内存
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











