% Function to generate Figure 3 accompanying the paper
%
% "Predicting vertical ground reaction forces from 3D accelerometery using
% reservoir computers leads to accurate gait event detection", Margit M
% Bach, Nadia Dominici, and Andreas Daffertshofer. Vrije Universiteit
% Amsterdam
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

%% set the Matlab path
addpath('misc','graphics');

load('results/L-loop_continuous.mat');

figure('Name','Figure 3 - Training size dependent errors');

fig=Figure3(stat,split,numTrainData,fs);

storeFigures(fig,'figures');

%% _ EOF__________________________________________________________________