% script: trackparam.m
%     loads data and initializes variables
%
% Copyright (C) Jongwoo Lim and David Ross.
% All rights reserved.

% DESCRIPTION OF OPTIONS:
%
% Following is a description of the options you can adjust for
% tracking, each proceeded by its default value.
%
% To set the other options,
% first try using the values given for one of the demonstration
% sequences, and change parameters as necessary.
%
%*************************************************************
% p = [px, py, sx, sy, theta]; 
% The location of the target in the first frame.
% px and py are th coordinates of the centre of the box
%
% sx and sy are the size of the box in the x (width) and y (height)
% dimensions, before rotation    
%
% theta is the rotation angle of the box   
%
% numsample is the number of samples used in the condensation
% algorithm/particle filter.

% 'affsig',[4,4,.02,.02,.005,.001]  These are the standard deviations of
% the dynamics distribution, that is how much we expect the target
% object might move from one frame to the next.  The meaning of each
% number is as follows:
%   'affsig'
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = rotation angle (radians, mean is 0)
%    affsig(4) = x scaling (pixels, mean is 1)
%    affsig(5) = y scaling (pixels, mean is 1)
%    affsig(6) = scaling angle (radians, mean is 0)
%
% Change 'title' to choose the sequence you wish to run. 
% title = 'car4';
title = 'tom1';

switch (title)    
    case 'tom1';
        p = [196,102,74,76,0.0];
        opt = struct('numsample',200, 'update',10, 'affsig',[10,10,.002,.001,.005,.0001]);

    case 'car4';
        p = [300,150,85,70,0.0];
        opt = struct('numsample',200, 'update',5, 'affsig',[7,7,.018,.0001,.0001,.0001]);
                
    otherwise;  error(['unknown title ' title]);
end

dataPath = ['data/' title '/'];
param0 = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];   %%p = [px, py, sx, sy, theta];   
param0 = affparam2mat(param0);

if ~isdir(['result/' title])
    mkdir('result/', title);
end

