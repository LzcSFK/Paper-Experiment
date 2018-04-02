function [time_1,time_2] = timeAndVol(neib_1,neib_2)
predict = readData('E:\traffic_data\detector_data\157\predict-cross.csv',2,80);
% [neib_1,neib_2] = correlation('E:\traffic_data\detector_data\157\neighbor_1.csv','E:\traffic_data\detector_data\157\neighbor_2.csv','E:\traffic_data\detector_data\157\predict-cross.csv');

m = size(predict,1);
time_1 = zeros(m,2);
time_2 = zeros(m,2);

for i = 1:m
   time_1(i,2) = count_time(neib_1(i,1),predict(i,1))
   time_1(i,1) = table2array(neib_1(i,2));
   time_2(i,2) = count_time(neib_2(i,1),predict(i,1))
   time_2(i,1) = table2array(neib_2(i,2));
end

% time1 = count_time(neib_1(1,1),predict(1,1))
