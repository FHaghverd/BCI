clc;clear all;
load data_set_IVa_aa
%% DataAqusion
Total_accuracy=0;
ch=size(cnt,2);
N=size(mrk.pos,2);

for i=1:N
    if isnan(mrk.y(i))==1
        N=i-1;
        break;
    end
end 

X=cell(1,N);
cnt= double(0.1*cnt);
% [a,b]=butter(5,[8 30]/50);
% cnt=filtfilt(b,a,cnt);
d = designfilt('bandpassiir','FilterOrder',8,'HalfPowerFrequency1',8,'HalfPowerFrequency2',30,'SampleRate',100);
cnt=filtfilt(d,cnt);

for i=1:N
 X{i}=cnt(mrk.pos(i)+51:(mrk.pos(i)+150),:);
 avrage=mean(X{i});
  for j=1:ch
    X{i}(:,j)=X{i}(:,j)-avrage(j);
  end
end

%% Create cross-validation partition for data 
K_kfold=3; % N/K_kfold must be Zero
accuracy=zeros(K_kfold,1);
kfold=crossvalind('Kfold',N,K_kfold);
for i=1:K_kfold
 n(i)=1;
end

for i=1:N  
    for j=1:K_kfold
        if kfold(i)==j
            Classified(j,n(j))=i;
            n(j)=n(j)+1;
        end
    end
end

for i=1:K_kfold
     tr_data=X;
     tr_label=mrk.y(1:N);
     tr_data_c1={0};
     tr_data_c2={0};
     ts_data={0};
     ts_label=0;
     
     for j=1:N/K_kfold
         ts_data{j}=X{Classified(i,j)};
         ts_label(j)=mrk.y(Classified(i,j));
         tr_label(Classified(i,j))=0;
     end
     
     nc1=0;
     nc2=0;
     nt=0;
     
     for l=1:N
         if tr_label(l)==1
             nc1=nc1+1;
             nt=nt+1;
             tr_data_t{nt}=tr_data{l};
             tr_label_t(nt)=tr_label(l);
             tr_data_c1{nc1}=tr_data{l};          
         elseif tr_label(l)==2
             nc2=nc2+1;
             nt=nt+1;
             tr_data_t{nt}=tr_data{l};
             tr_label_t(nt)=tr_label(l);
             tr_data_c2{nc2}=tr_data{l};
         end
     end
     
     tr_data=tr_data_t;
     tr_label=tr_label_t;
%% W Calculating 
CSP=1;
[W]=WCalculator(tr_data_c1,tr_data_c2); 
ZSP=real([W(:,1:CSP)';W(:,(ch-CSP+1):ch)']);
%% Spatial Filtering
% Y=cell(CSP*2,N);
% P=cell(CSP*2,N);
for m=1:(N-N/K_kfold)  
    for f=1:CSP*2
        Y_tr_data{f,m}=ZSP(f,:)*tr_data{m}';
        P_tr_data(f,m)=var(Y_tr_data{f,m});
        if m<=N/K_kfold
            Y_ts_data{f,m}=ZSP(f,:)*ts_data{m}';
            P_ts_data(f,m)=var(Y_ts_data{f,m});
        end
    end
end
for t=1:N/K_kfold
     for g=1:(N-N/K_kfold)
         for f=1:2*CSP
         dis(f,g)=P_ts_data(f,t)-P_tr_data(f,g);
         end
         dis_size(g)=norm(dis(:,g));
     end
     [~,ind] = sort(dis_size,'descend');
     labelsum=0;
     k_knn=5;
     for g=N-N/K_kfold-k_knn+1:N-N/K_kfold
         if tr_label(ind(g))==1
             labelsum=labelsum+1;
         end
     end
     if labelsum > k_knn/2
         decision_ts=1;
     else
         decision_ts=2;
     end
     if(decision_ts==ts_label(t))
         accuracy(i)=accuracy(i)+1;
     end
end
accuracy(i)=(accuracy(i)/(N/K_kfold))*100;
Total_accuracy=accuracy(i)+Total_accuracy;
end
Total_accuracy=Total_accuracy/(K_kfold);

