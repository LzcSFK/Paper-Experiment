data = generateData1('E:\traffic_data\weibo_data\correlation\7-1\ID=1&&4-res(7-1).csv', 2, 80);

row = size(data,1);
column = size(data,2);

% time_table = zeros(79,20);

% time_table = datestr(datenum(table2array(data(1,1)))+datenum(table2array(data(1,5))))

for i = 1:row
    time_table(i,:) = datestr(datenum(table2array(data(i,1)))+datenum(table2array(data(i,5))));
%     fprintf('i=%d',i);
end



















