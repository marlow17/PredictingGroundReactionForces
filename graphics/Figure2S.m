function fig=Figure2S(result,sample,trial,condition,fs,ti)
% function to generate Figure 2 in "Predicting vertical ground reaction
% forces from 3D accelerometery using reservoir computers leads to accurate
% gait event detection", Margit M Bach, Nadia Dominici, and Andreas
% Daffertshofer. Vrije Universiteit Amsterdam
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

assert(~verLessThan('matlab','9.7'),'This function requires Matlab release R2019b or higher.');

narginchk(1,6);

if nargin<5, fs=2000/14; end
if nargin<6, ti={}; end

if ~iscell(ti), ti={ ti }; end
if ~iscell(trial), trial={ trial }; end

vColor=struct( ...
    'epsilon',    [135 151 173], ...
    'R2',         [173 135 151], ...
    'footOnMAE',  [105 122 115], ...
    'footOffMAE', [115 105 122] ...
    );

% vline=@(x,y,varargin) arrayfun(@(s)line([1,1]*x(s),y,varargin{:}),1:numel(x));

for c=1:numel(condition)
    
    fig(c)=figure('Name',sprintf('Figure 2S - Timeseries force traces (%s)',condition{c}),'Numbertitle','Off');

    if size(sample,1)==1, s={1,7}; else, s={2,5}; end
%     tiledlayout(s{:},'Padding','compact','TileSpacing','compact');
    tiledlayout(s{:},'TileSpacing','compact');

    for i=1:size(sample,1)
        
        nexttile([1 3]);
        h=plotPrediction(result(c,sample(i,1)).test,trial{i},fs);

        set(gca,'ytick',[1,5,10])
        if i==1
            h=legend(h(1,:),{'measured','predicted'});
            a=gca;
            h.Position(1)=a.Position(1)+a.Position(3)-h.Position(3);
            h.Position(1)=a.Position(1)+a.Position(3)-h.Position(3);
                        h.Position(2)=a.Position(2)+a.Position(4)-h.Position(4)+0.015*(size(sample,1)-1);
% h.Position(2)=a.Position(2);
            h.LineWidth=.1;
        end
        if ~isempty(ti)
            h=title(ti{i});
            h.Units='Normalized';
            h.Position(1)=0;
            h.HorizontalAlignment='left';
            h.FontAngle='italic';
        end


    end

    cn=fieldnames(vColor);
    for j=1:numel(cn)
        
        nexttile;
        val=arrayfun(@(i)result(c,i).test.error.(cn{j}),1:size(result,2));
        yl='';
        
        switch cn{j}
            case 'epsilon',    label='\epsilon [%]';  val=100*val;
            case 'R2',         label='R^2';
            case 'footOnMAE',  label='FC'; yl='[ms]'; val=val/fs*1000;
            case 'footOffMAE', label='FO'; yl='[ms]'; val=val/fs*1000;
        end
        
        v=violinplot(val,'','ShowMean',true,'BoxColor',[0 0 0]);
        v.ViolinColor=vColor.(cn{j})/255;
        v.ScatterPlot.MarkerFaceAlpha=1;
        v.ScatterPlot.MarkerEdgeColor=[1 1 1];
        v.MedianPlot.SizeData=56;
        v.MeanPlot.LineWidth=3;
        v.MeanPlot.Color='k';
        v.WhiskerPlot.Visible='off';
        v.BoxWidth=0.025;
        set(gca,'XTick',[],'Box','off','FontSize',10);
        h=xlabel(label,'Units','normalize','VerticalAlignment','bottom');
        if size(sample,1)==1
            h.Position(2)=-0.105;
        else
            h.Position(2)=-0.144;
        end
        
        set(gca,'LineWidth',2, 'FontWeight', 'bold');
        if ~isempty(yl), ylabel(yl); end
        axis tight;
        
    end
    
    if size(sample,1)==1
        set(fig,'Position',[491 573 679 197]);
    else
        set(fig,'Position',[488 310 595 297]);
    end

end

%% _ EOF__________________________________________________________________
