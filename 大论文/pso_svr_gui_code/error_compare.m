clc
clear


% %读取测试数据
test_label=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,2,[2 2 85 2]);

% svr=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,3,[2 3 85 3]);
% svr_new=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,8,[2 8 85 8]);
svr=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,6,[2 6 85 6]);
high_pso_svr=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,4,[2 4 85 4]);
shikongpsosvr=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,6,[2 6 85 6]);
% bp=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,6,[2 6 85 6]);
bp=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,8,[2 8 85 8]);
pso=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,9,[2 9 85 9]);
test_len = length(test_label);

change_weight=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,3,[2 3 85 3]);

high_pso_svr_error=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,10,[2 10 85 10]);
change_w=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,11,[2 11 85 11]);
bp_pso_svr_error=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,12,[2 12 85 12]);


A = cell(85); %预先分配内存

for i = 9:1:22
     X{i-8} = num2str(i);
end
a = 1:1:84;
figure(1)
plot(a,change_w,'b-',a,bp_pso_svr_error,'r--')
set(gca,'xtick',8:6:14*6)
set(gca,'xticklabel',X)
% legend('真实值','PSO-SVR')
legend('变权重','BP融合')
xlabel('时  间(time/h)')
ylabel('相对误差')

figure(2)
plot(a,high_pso_svr_error,'b-',a,bp_pso_svr_error,'r--')
set(gca,'xtick',8:6:14*6)
set(gca,'xticklabel',X)
% legend('真实值','PSO-SVR')
legend('改进PSO-SVR','BP融合')
xlabel('时  间(time/h)')
ylabel('相对误差')











