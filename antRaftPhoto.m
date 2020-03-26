function antRaftPhoto(vn, NoFrame, tstep)
%ANTRAFTPHOTO    Provides the data of the ant raft's area.
%   
%   Takes in a video name VN (only works for vido) and read it frame by frame
%   in a time rage that you can set up. NOFRAME is the number of frames
%   to be processed. TSTEP is the time step. Calculate the ant area in each
%   frame.


%% Initiation 

% read in the file (needs to be a video)
v = VideoReader(vn);

% initialize the cell array that will store the data
cell = [];

%% Option 1 time-based looping
% note that the time finding feature in the matlab is a little bit weird,
% if you set v.time = 0.99, it will look for the frame closest to 0.99s
% timestamp. However, it never really use the frame at t=0.99s even if you
% have a frame there. It will find the next frame

tic
% Number of frame to be processed
% NoFrame = 48;

% first column of weight is time, second column is weight from processing
weight = zeros(NoFrame,2);

% Set the Start time, with second as unit
StartTime = 0;

% Find the ants mannually
area = FindArea(v);

% Set time step, with second as unit
% tstep = 10;

for i = 1:NoFrame
    
    % put timestamp
    weight(i,1) = StartTime + tstep*i;
    
    % Process and crop the frame
    BW = ProcessFrame(v,weight(i,1),area);
    
    % Process the image and calculate the area of the ant raft
    BW = ~BW;
%     imshow(BW);
     newBW = imfill(BW,'holes');
%       imshow(newBW)
    out = sum(sum(~BW));
    
    % Store the data in the cell array
    cell = [cell; {out}];
    
    % Display for ever 10 iterations to show progress
    if ~mod(i,10)
        disp(['processing i=', num2str(i)])
    end
end
toc

% write the data in an excel sheet with the specific video name in it
[video, rest] = strtok(vn,'.')
writecell(cell,['ants',video,'.xlsx']);

%% Helper Functions
%% FindArea
%FINDAREA A helper function that hel get the rough area that the ant raft
%           will be in.
    function rect = FindArea(v)
        % Read in the frame
        v.CurrentTime = 0;
        videoFrame = readFrame(v);
        
        % Manually select the area that you want
        [J, rect] = imcrop(videoFrame);
    end

%% ProcessFrame
% This function crop the frame and binarize the frame, if the time is
% negative, it means that we are not controlling time and just get the next
% frame in the video
function BW = ProcessFrame(v,time,area)
    if time>=0 
        v.CurrentTime = time;
    end
    videoFrame = readFrame(v);
     I = imcrop(videoFrame,area);
    I = rgb2gray(I);
    BW = imbinarize(I,0.3);
%     imshow(BW);
    
%      imshowpair(I,BW,'montage')
%      pause
end

end