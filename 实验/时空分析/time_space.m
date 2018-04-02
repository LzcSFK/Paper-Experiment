neighbor_1 = readData('E:\traffic_data\detector_data\157\neighbor_1.csv',2,1566);
neighbor_2 = readData('E:\traffic_data\detector_data\157\neighbor_2.csv',2,1566);
predict_cross = readData('E:\traffic_data\detector_data\157\predict-cross.csv',2,80);

neighbor_r1 = size(neighbor_1,1);
% [neighbor_r2,neighbor_c2] = size(neighbor_2);
r = size(predict_cross,1);

neigh_1 = table();
neigh_2 = table();
result_1 = table();
result_2 = table();
nei_res_1 = table();
nei_res_2 = table();

tic

for i = 1:r
            z = 0;
            for j = 1:neighbor_r1
                if(predict_cross.Time(i) == neighbor_1.Time(j))
                    neigh_1(z+1,:) = neighbor_1(j-1,:);
                    neigh_1(z+2,:) = neighbor_1(j-2,:);
                    neigh_1(z+3,:) = neighbor_1(j-3,:);
                end

                if(predict_cross.Time(i) == neighbor_2.Time(j))
                    neigh_2(z+1,:) = neighbor_2(j-1,:);
                    neigh_2(z+2,:) = neighbor_2(j-2,:);
                    neigh_2(z+3,:) = neighbor_2(j-3,:);
                end
            end
            
            max = 0;
        
            for ii=1:3
                for jj=1:3
                    sum = neigh_1.vol(ii)+neigh_2.vol(jj);
                    if(max<sum && (sum<=predict_cross.vol(i)))
                        max = sum;  
                        result_1 = neigh_1(ii,:);
                        result_2 = neigh_2(jj,:);
                    end   
                end
            end
        nei_res_1(i,:) = result_1(1,:);
        nei_res_2(i,:) = result_2(1,:);              
end

toc













