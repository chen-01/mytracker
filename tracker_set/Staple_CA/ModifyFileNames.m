%------重命名文件并保存到目的文件夹---------------
%读取当前文件夹下所有.mat文件，并更改为 _BACFIF.mat 文件，保存到当前文件夹下的results\
function ModifyFileNames()
clear;
clc;
ojFiles=dir('.\*.mat');%目标文件

len=length(ojFiles);
disp('Begin to rename..')
savedir = '.\results\';
for i = 1:len
 oringalPath = ['.\',num2str(ojFiles(i).name)];      %目标文件路径
 newName=[ojFiles(i).name(1:end-4) '_BACFIF.mat'];   %目标文件重命名
 newPath = [savedir,newName];                        %目标文件路径
 copyfile(oringalPath,newPath);                      %将目标文件复制到results文件夹
 
 results_DSST = load(['C:\Users\56953\Desktop\BACFIF_benchmark\results\results_OPE\',ojFiles(i).name(1:end-4),'_DSST.mat']);
 
 cd(savedir)                                         %进入results文件夹
 results2 = load(newName);                            %加载更改后名称的文件，并保存为results.mat文件
 results = cell(1,1);
 results{1} = results2.BACFIF;
 results{1}.len = results_DSST.results{1}.len;
 results{1}.annoBegin = results_DSST.results{1}.annoBegin;
 results{1}.startFrame = results_DSST.results{1}.startFrame;
 save(newName,'results');                            %将results.mat保存到newName（目标文件名）里
 cd ..
end
disp('end!!')
end

%------------重命名文件------------------
% imgs=dir('./*.mat');
% len=length(imgs);
% for i=1:len
%     oldname=['./' imgs(i).name];
%     newname=[imgs(i).name(1:end-4) '_BACFIF.mat'];
%     eval(['!rename',' ',oldname,' ',newname]);
% end

% % %------重命名文件并保存到目的文件夹---------------
% % %读取当前文件夹下所有.mat文件，并更改为 _BACFIF.mat 文件，保存到当前文件夹下的results\
% % ojFiles=dir('.\*.mat');%目标文件
% % len=length(ojFiles);
% % disp('Begin to rename..')
% % for i = 1:len
% %  oringalPath = ['.\',num2str(ojFiles(i).name)];%目标文件路径
% %  newName=[ojFiles(i).name(1:end-4) '_BACFIF.mat'];%目标文件重命名
% %  savedir = ['.\results\',newName];%目标文件路径
% %  copyfile(oringalPath,savedir);
% % end
% % disp('end!!')

% %------重命名文件并保存到目的文件夹---------------
% %读取当前文件夹下所有.mat文件，并更改为 _BACFIF.mat 文件，保存到当前文件夹下的results\
% function ModifyFileNames()
% clear;
% clc;
% ojFiles=dir('.\*.mat');%目标文件
% len=length(ojFiles);
% disp('Begin to rename..')
% savedir = '.\results\';
% for i = 1:len
%  oringalPath = ['.\',num2str(ojFiles(i).name)];      %目标文件路径
%  newName=[ojFiles(i).name(1:end-4) '_BACFIF.mat'];   %目标文件重命名
%  newPath = [savedir,newName];                        %目标文件路径
%  copyfile(oringalPath,newPath);                      %将目标文件复制到results文件夹
%  cd(savedir)                                         %进入results文件夹
%  results = load(newName);                            %加载更改后名称的文件，并保存为results.mat文件
%  results.results = results.BACFIF;                   %修改里面的BACFIF结构体为results
%  results = rmfield(results, 'BACFIF');               %去掉结构体BACFIF
%  results = struct2cell(results);                     %将结构体变为cell类型
%  save(newName,'results');                            %将results.mat保存到newName（目标文件名）里
%  cd ..
% end
% disp('end!!')
% end