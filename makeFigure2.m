% Function to generate Figure 2 accompanying the paper
%
% "Predicting vertical ground reaction forces from 3D accelerometery using
% reservoir computers leads to accurate gait event detection", Margit M
% Bach, Nadia Dominici, and Andreas Daffertshofer. Vrije Universiteit
% Amsterdam
%
%
% This code uses Bastion Bechtold's Violin Plots for Matlab, Github Project  
% https://github.com/bastibe/Violinplot-Matlab, DOI: 10.5281/zenodo.4559847
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

%% set the Matlab path
addpath(genpath(fullfile('external','Violinplot-Matlab')));
addpath('misc','graphics');

testDataType='continuous'; % 'strides';

load(fullfile('results',sprintf('statistics_%s.mat',testDataType)));

fname=fullfile('results',sprintf('statistics_%s.txt',testDataType));
if exist(fname,'file'), delete(fname); end

diary(fname);

fprintf(['\n<strong>Training strides and val./testing %s ' ...
    'gait data with (%g,%g,%g)%% split ...</strong>\n\n'], ...
    testDataType,split*100);
reportStats(stat,condition,fs);
fprintf('\n');

diary off;

fig=Figure2(result(1,:),[100,5;70,7],condition(1),fs, ...
    {'walking','running'});
fig=[fig,Figure2(result(2,:),[80,1],condition(2),fs)];
fig=[fig,Figure2(result(3,:),[80,3],condition(3),fs)];

for i=1:numel(fig)
    set(fig(i),'Name',[get(fig(i),'Name') '_' testDataType]);
end

storeFigures(fig,'figures');

%% _ EOF__________________________________________________________________