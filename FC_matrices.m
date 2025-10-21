
%on mickey 
ml matlab 

matlab -nodesktop -nodisplay
subjects=readtable('/data/pzhukovsky/CANBIND/scripts/subjects.txt', 'ReadVariableNames', false);subjects=subjects.Var1;
addpath /data/pzhukovsky/GABA/pipelines/FSLNets/
ic_labels={'vol0001'; 'vol0002'; 'vol0003';} % add all volumes here 
ts_all=[];
for i=1:length(subjects); subjects{i}
try
for ic=1:21
input_dir=strcat('/data/pzhukovsky/CANBIND/data/processed2302/post-fmriprep/', subjects{i}, '/ts_surf/', ic_labels{ic}, '.txt'); ts_ic=dlmread(input_dir); 
ts_all=[ts_all, ts_ic];% ts_all should be 21 columns wide and however many volumes eg 177 long 
end
Fnetmats = nets_netmats(ts_all,1,'corr'); %full correlations
Pnetmats = nets_netmats(ts_all,1,'ridgep',0.1); %partial correlations with ridge regularization
%rmat=corr(ts_all);
D=21;
Fnetmats_vectorized=Fnetmats(triu(ones(D),1)==1)'; % example https://www.fmrib.ox.ac.uk/ukbiobank/group_means/netmat_info.html
Pnetmats_vectorized=Pnetmats(triu(ones(D),1)==1)';

confounds=readtable(strcat('/data/pzhukovsky/CANBIND/data/processed2302/post-fmriprep/confounds/', subjects{i}, '_confounds1.txt'));
mean_fd(i)=mean( confounds.framewise_displacement);

Pnetmats_vectorized=table(Pnetmats_vectorized); Pnetmats_vectorized.ID=subjects; Pnetmats_vectorized.mean_fd=mean_fd;
end; end
cd /data/pzhukovsky/CANBIND/reports
writetable(Pnetmats_vectorized, '_canbind.mat')
