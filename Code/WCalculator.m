function [Su] = WCalculator( tr_data_c1, tr_data_c2)

size_c1=size(tr_data_c1,2);
size_c2=size(tr_data_c2,2);
cov1=0;
cov2=0;

for i= 1:size_c1
    cov1=tr_data_c1{i}'*tr_data_c1{i}+cov1;
end

for i= 1:size_c2
    cov2=tr_data_c2{i}'*tr_data_c2{i}+cov2;
end

cov1=cov1/size_c1;
cov2=cov2/size_c2;
A=cov2\cov1;
[u,landa]=eig(A);
[~,ind] = sort(diag(landa),'descend');
Su = u(:,ind);