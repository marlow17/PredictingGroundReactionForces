% Function to generate Figure S4 accompanying the paper
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

load(fullfile('results','LMO-loop_continuous.mat'));

[strg,v]=reportLMO(err,mRange,fs);

wa=warning;
warning('off');
tiledlayout(2,2,'TileSpacing','compact');
for i=[2,1,3,4]
    nexttile;
    boxplot(squeeze(v(:,i,:)),'Notch','off');
    ylabel(strg{i});
    if i>2, xlabel('M'); set(gca,'ytick',[10,20,50,100,150,300]);
    else, set(gca,'xticklabel',{}); end
    set(findobj(gca,'Type','Line'),'LineWidth',1.5);
    set(gca,'LineWidth',1,'FontSize',12,'Box','off');
    grid on;
    set(gca,'yscale','log','FontWeight','bold');
end
warning(wa);

set(gcf,'Position',[200 235 535 300], ...
    'Numbertitle','Off','Name','Figure S4 - LMO CC');

storeFigures(gcf,'figures');

%% _ EOF__________________________________________________________________

