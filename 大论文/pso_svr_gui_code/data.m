%% 清空环境
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
test_len = length(test_label)

change_weight=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,3,[2 3 85 3]);

A = cell(85); %预先分配内存

for i = 9:1:22
     X{i-8} = num2str(i);
end

% A{145} = A{1}; %把0:00复制到最后一位
% A{1} = [];%把第一位的0:00清除
a = 1:1:84;
figure
% plot(a,test_label,'r-*',a,shikong,'b:o')
% plot(a,test_label,'r-*',a,predict_2,'b:o',a,predict_3,'k:+',a,shikongpsosvr,'y:s',a,bp,'g:x')
% set(gca,'xtick',8:6:14*6)
% set(gca,'xticklabel',X)
% % legend('真实值','时空相关性预测值')
% legend('真实值','SVR预测值','改进PSO-SVR预测值','基于时空关联性的改进PSO-SVR预测值','BP网络预测值')
% xlabel('时  间(time/h)')
% ylabel('车流量(辆/10min)')

plot(a,test_label,'r-*',a,change_weight,'b:o',a,high_pso_svr,'g:s',a,shikongpsosvr,'y:x')
set(gca,'xtick',8:6:14*6)
set(gca,'xticklabel',X)
% legend('真实值','PSO-SVR')
legend('真实值','变权重融合','改进PSO-SVR','BP融合')
xlabel('时  间(time/h)')
ylabel('车流量(辆/10min)')

% plot(a,test_label,'r-*',a,change_weight,'b:o')
% set(gca,'xtick',8:6:14*6)
% set(gca,'xticklabel',X)
% % legend('真实值','PSO-SVR')
% legend('真实值','变权重法')
% xlabel('时  间(time/h)')
% ylabel('车流量(辆/10min)')




