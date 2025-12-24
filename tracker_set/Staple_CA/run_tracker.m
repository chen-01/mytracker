% RUN_TRACKER  is the external function of the tracker - does initialization and calls trackerMain
video_path_UAV123 = 'C:\Users\Van\Documents\MATLAB\Dataset_UAV123_10fps\UAV123_10fps\data_seq\UAV123_10fps';
ground_truth_path_UAV123 = 'C:\Users\Van\Documents\MATLAB\Dataset_UAV123_10fps\UAV123_10fps\anno\UAV123_10fps';
video_name ={'try'};
% video_name ={'bike1','bike2','bike3','bird1_1','bird1_2','bird1_3','boat1','boat2','boat3','boat4','boat5','boat6','boat7','boat8','boat9','building1','building2','building3','building4',...
%     'building5','car1_1','car1_2''car1_3','car1_s','car2','car2_s','car3','car3_s','car4','car4_s','car5','car6_1','car6_2','car6_3','car6_4','car6_5','car7','car8_1','car8_2','car9','car10','car11','car12','car13','car14','car15',...
%     'car16_1','car16_2','car17','car18','group1_1','group1_2','group1_3','group1_4','group2_1','group2_2','group2_3','group3_1','group3_2','group3_3','group3_4','person1','person1_s','person2_1','person2_2','person2_s','person3','person3_s','person4_1','person4_2','person5_1','person5_2','person6','person7_1','person7_2',...
%     'person8_1','person8_2','person9','person10','person11','person12_1','person12_2','person13','person14_1','person14_2','person14_3','person15','person16','person17_1','person17_2','person18','person19_1','person19_2','person19_3','person20','person21','person22',...
%     'person23','truck1','truck2','truck3','truck4_1','truck4_2','uav1_1','uav1_2','uav1_3','uav2','uav3','uav4','uav5','uav6','uav7','uav8','wakeboard1','wakeboard2','wakeboard3','wakeboard4','wakeboard5',...
%     'wakeboard6','wakeboard7','wakeboard8','wakeboard9','wakeboard10'};
% video_name ={'car1_2','car1_3','car1_s','car2','car2_s','car3','car3_s','car4','car4_s','car5','car6_1','car6_2','car6_3','car6_4','car6_5','car7','car8_1','car8_2','car9','car10','car11','car12','car13','car14','car15',...
%     'car16_1','car16_2','car17','car18','group1_1','group1_2','group1_3','group1_4','group2_1','group2_2','group2_3','group3_1','group3_2','group3_3','group3_4','person1','person1_s','person2_1','person2_2','person2_s','person3','person3_s','person4_1','person4_2','person5_1','person5_2','person6','person7_1','person7_2',...
%     'person8_1','person8_2','person9','person10','person11','person12_1','person12_2','person13','person14_1','person14_2','person14_3','person15','person16','person17_1','person17_2','person18','person19_1','person19_2','person19_3','person20','person21','person22',...
%     'person23','truck1','truck2','truck3','truck4_1','truck4_2','uav1_1','uav1_2','uav1_3','uav2','uav3','uav4','uav5','uav6','uav7','uav8','wakeboard1','wakeboard2','wakeboard3','wakeboard4','wakeboard5',...
%     'wakeboard6','wakeboard7','wakeboard8','wakeboard9','wakeboard10'};
    %% Read params.txt
    params = readParams('params.txt');
    M = size(video_name);
m = M(1,2);
for i=1:m
seq = load_video_info_UAV123(video_name(1,i), video_path_UAV123, ground_truth_path_UAV123);
video_path = seq.video_path;
ground_truth = seq.ground_truth;
videos = dir(video_path);
% 	%% load video info
%     sequence_path = fullfile(base_path,video);
%     img_path = fullfile(sequence_path, 'img');
sequence_path = [video_path_UAV123 '\'];
img_path = video_path;
    %% Read files
    frames = {seq.st_frame, seq.en_frame};
%     text_files = dir([sequence_path '*_frames.txt']);
%     if(~isempty(text_files))
%         f = fopen([sequence_path text_files(1).name]);
%         frames = textscan(f, '%f,%f');
%         fclose(f);
%     else
%         frames = {};
%     end
%     if exist('start_frame')
%         frames{1} = start_frame;
%     else
%         frames{1} = 1;
%     end
    
   params.bb_VOT = zeros(size(ground_truth,1),8);
params.bb_VOT(:,1) = ground_truth(:,1);
params.bb_VOT(:,2) = ground_truth(:,2) + ground_truth(:,4);
params.bb_VOT(:,3) = ground_truth(:,1) + ground_truth(:,3);
params.bb_VOT(:,4) = ground_truth(:,2) + ground_truth(:,4);
params.bb_VOT(:,5) = ground_truth(:,1) + ground_truth(:,3);
params.bb_VOT(:,6) = ground_truth(:,2);
params.bb_VOT(:,7) = ground_truth(:,1);
params.bb_VOT(:,8) = ground_truth(:,2);
    region = params.bb_VOT(1,:);
%     params.bb_VOT = csvread(fullfile(sequence_path, 'groundtruth_rect.txt'));
%     region = params.bb_VOT(frames{1},:);
%     %%%%%%%%%%%%%%%%%%%%%%%%%
    % read all the frames in the 'imgs' subfolder
%     dir_content = dir(fullfile(sequence_path, 'img'));
%     % skip '.' and '..' from the count
%     n_imgs = length(dir_content) - 2;
%     img_files = cell(n_imgs, 1);
%     for ii = 1:n_imgs
%         img_files{ii} = dir_content(ii+2).name;
%     end
%        
%     img_files(1:start_frame-1)=[];

%     im = imread(fullfile(img_path, img_files{1}));
    % is a grayscale sequence ?
    img_files = seq.s_frames;
im = imread([img_path img_files{1}]);
    if(size(im,3)==1)
        params.grayscale_sequence = true;
    end

    params.img_files = img_files;
    params.img_path = img_path;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(numel(region)==8)
        % polygon format
        [cx, cy, w, h] = getAxisAlignedBB(region);
    else
        x = region(1);
        y = region(2);
        w = region(3);
        h = region(4);
        cx = x+w/2;
        cy = y+h/2;
    end

    % init_pos is the centre of the initial bounding box
    params.init_pos = [cy cx];
    params.target_sz = round([h w]);
    [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);
	if params.visualization
		params.videoPlayer = vision.VideoPlayer('Position', [100 100 [size(im,2), size(im,1)]+30]);
	end
    % in runTracker we do not output anything
	params.fout = -1;
	% start the actual tracking
	results = trackerMain(params, im, bg_area, fg_area, area_resize_factor);
    
    %calculate and show precision plot, as well as frames-per-second
%     precisions = precision_plot(results.res, params.bb_VOT, video, show_plots);
%     fprintf('%12s - Precision (20px):% 1.3f, FPS:% 4.2f\n', video, precisions(20), results.fps)
%     fclose('all');
results = trackerMain(params, im, bg_area, fg_area, area_resize_factor);
  positions = results.res(:,1:2);
title = cell2mat(video_name(1,i));
precisions = precision_plot(positions, ground_truth, title,'C:\Users\Van\Documents\MATLAB\Context-Aware-CF-Tracking\STAPLE_CA\UAV_staple_CA', 1);
save(title,'results');
end




% %
% %  Context-Aware Correlation Filters
% %
% %  Written by Luca Bertinetto, 2016
% %  Adapted by Matthias Mueller, 2016
% %
% %  This function takes care of setting up parameters, loading video
% %  information and computing precisions. For the actual tracking code,
% %  check out the TRACKERMAIN.m function.
% %
% 
% function run_tracker(video, start_frame)
% % RUN_TRACKER  is the external function of the tracker - does initialization and calls trackerMain
% video = 'C:\Users\Van\Documents\MATLAB\Context-Aware-CF-Tracking\STAPLE_CA\sequences\Skiing';
% start_frame = 1;
% 	%path to the videos (you'll be able to choose one with the GUI).
% 	base_path = 'sequences/';
%     
% 	%default settings
% 	if nargin < 1, video = 'Skiing'; end
% 	if nargin < 2, start_frame = 1; end
%     if nargin < 3, show_plots = 1; end
%     
%     %% Read params.txt
%     params = readParams('params.txt');
% 	%% load video info
%     sequence_path = fullfile(base_path,video);
%     img_path = fullfile(sequence_path, 'img');
%     %% Read files
%     text_files = dir([sequence_path '*_frames.txt']);
%     if(~isempty(text_files))
%         f = fopen([sequence_path text_files(1).name]);
%         frames = textscan(f, '%f,%f');
%         fclose(f);
%     else
%         frames = {};
%     end
%     if exist('start_frame')
%         frames{1} = start_frame;
%     else
%         frames{1} = 1;
%     end
%     
%    
%     params.bb_VOT = csvread(fullfile(sequence_path, 'groundtruth_rect.txt'));
%     region = params.bb_VOT(frames{1},:);
%     %%%%%%%%%%%%%%%%%%%%%%%%%
%     % read all the frames in the 'imgs' subfolder
%     dir_content = dir(fullfile(sequence_path, 'img'));
%     % skip '.' and '..' from the count
%     n_imgs = length(dir_content) - 2;
%     img_files = cell(n_imgs, 1);
%     for ii = 1:n_imgs
%         img_files{ii} = dir_content(ii+2).name;
%     end
%        
%     img_files(1:start_frame-1)=[];
% 
%     im = imread(fullfile(img_path, img_files{1}));
%     % is a grayscale sequence ?
%     if(size(im,3)==1)
%         params.grayscale_sequence = true;
%     end
% 
%     params.img_files = img_files;
%     params.img_path = img_path;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if(numel(region)==8)
%         % polygon format
%         [cx, cy, w, h] = getAxisAlignedBB(region);
%     else
%         x = region(1);
%         y = region(2);
%         w = region(3);
%         h = region(4);
%         cx = x+w/2;
%         cy = y+h/2;
%     end
% 
%     % init_pos is the centre of the initial bounding box
%     params.init_pos = [cy cx];
%     params.target_sz = round([h w]);
%     [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);
% 	if params.visualization
% 		params.videoPlayer = vision.VideoPlayer('Position', [100 100 [size(im,2), size(im,1)]+30]);
% 	end
%     % in runTracker we do not output anything
% 	params.fout = -1;
% 	% start the actual tracking
% 	results = trackerMain(params, im, bg_area, fg_area, area_resize_factor);
%     
%     %calculate and show precision plot, as well as frames-per-second
%     precisions = precision_plot(results.res, params.bb_VOT, video, show_plots);
%     fprintf('%12s - Precision (20px):% 1.3f, FPS:% 4.2f\n', video, precisions(20), results.fps)
%     fclose('all');
%     
% end
