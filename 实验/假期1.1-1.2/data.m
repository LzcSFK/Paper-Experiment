%% ��ջ���
clc
clear


% %��ȡ��������
test_label=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,2,[2 2 85 2]);

predict_2=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,3,[2 3 85 3]);
predict_3=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,4,[2 4 85 4]);
shikongpsosvr=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,5,[2 5 85 5]);
bp=csvread('E:\traffic_data\detector_data\16\01-10\875-3717.csv',2,6,[2 6 85 6]);
test_len = length(test_label)



A = cell(85); %Ԥ�ȷ����ڴ�

for i = 9:1:22
     X{i-8} = num2str(i);
end

% A{145} = A{1}; %��0:00���Ƶ����һλ
% A{1} = [];%�ѵ�һλ��0:00���
a = 1:1:84;
figure
% plot(a,test_label,'r-*',a,shikong,'b:o')
% plot(a,test_label,'r-*',a,predict_2,'b:o',a,predict_3,'k:+',a,shikongpsosvr,'y:s',a,bp,'g:x')
% set(gca,'xtick',8:6:14*6)
% set(gca,'xticklabel',X)
% % legend('��ʵֵ','ʱ�������Ԥ��ֵ')
% legend('��ʵֵ','SVRԤ��ֵ','�Ľ�PSO-SVRԤ��ֵ','����ʱ�չ����ԵĸĽ�PSO-SVRԤ��ֵ','BP����Ԥ��ֵ')
% xlabel('ʱ  ��(time/h)')
% ylabel('������(��/10min)')

plot(a,test_label,'r-*',a,predict_2,'b:o',a,predict_3,'k:+')
set(gca,'xtick',8:6:14*6)
set(gca,'xticklabel',X)
% legend('��ʵֵ','ʱ�������Ԥ��ֵ')
legend('��ʵֵ','SVRԤ��ֵ','�Ľ�PSO-SVRԤ��ֵ')
xlabel('ʱ  ��(time/h)')
ylabel('������(��/10min)')






