function fig=Figure3(stat,split,numTrainData,fs)
% function to generate Figure 2 in "Predicting vertical ground reaction
% forces from 3D accelerometery using reservoir computers leads to accurate
% gait event detection", Margit M Bach, Nadia Dominici, and Andreas
% Daffertshofer. Vrije Universiteit Amsterdam
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

x=split(:,1)*100;
N=numel(x);
fn=fieldnames(stat(1).test);
y=cell2struct(repmat({nan(N,1)},numel(fn),1),fn);

for i=1:N
    if ~isempty(stat(i).test)
        for n=1:numel(fn)
            y.(fn{n})(i)=stat(i).test.(fn{n});
        end
    end
end

[mean_N,std_N]=deal(nan(N,1));

for i=1:N
   mean_N(i)=mean(numTrainData{i});
   std_N(i)=std(numTrainData{i});       
end


%
X1=mean_N(~isnan(mean_N)); X2=x(~isnan(mean_N)); [X1,i]=unique(X1); X2=X2(i);
F=griddedInterpolant(X1,X2,'linear','linear');
X1=mean_N(~isnan(mean_N)); X2=x(~isnan(mean_N)); [X2,i]=unique(X2); X1=X1(i);
G=griddedInterpolant(X2,X1,'linear','linear');


%%
fig=figure('Name','Figure 3 - Training size dependent errors');

tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

vColor=struct( ...
    'epsilon',    [135 151 173], ...
    'R2',         [173 135 151], ...
    'footOnMAE',  [105 122 115], ...
    'footOffMAE', [115 105 122] ...
    );
fn=fieldnames(vColor);

for i=1:numel(fn)
    
    nexttile;
    switch fn{i}
        case 'R2'
            ym=y.(['mean_' fn{i}]);
            ys=y.(['std_' fn{i}]);
            yla='R^2';
            yli=[0.25,1.1];
        case 'epsilon'
            ym=y.(['mean_' fn{i}])*100;
            ys=y.(['std_' fn{i}])*100;
            yla='\epsilon [%]';
            yli=[4,30];
        case 'footOnMAE'
            ym=y.(['mean_' fn{i}])/fs*1000;
            ys=y.(['std_' fn{i}])/fs*1000;
            yla='FC [ms]';
            yli=[9.5,12];
        case 'footOffMAE'
            ym=y.(['mean_' fn{i}])/fs*1000;
            ys=y.(['std_' fn{i}])/fs*1000;
            yla='FO [ms]';            
            yli=[9.5,12];
    end    
    h=errorbar(mean_N,ym,ys,ys,std_N,std_N,'o', ...
        'CapSize',0,'Linewidth',1,'markersize',8);
    h.MarkerFaceColor=vColor.(fn{i})/255;
    h.MarkerEdgeColor=[1 1 1];
    h.Color=ones(1,3)*.6;

    patch([mean_N;mean_N(end:-1:1)],max(.1,[ym-ys;ym(end:-1:1)+ys(end:-1:1)]),vColor.(fn{i})/255,'EdgeColor','none','FaceAlpha',0.25);

    ylabel(yla);
    set(gca,'YLim',yli,'LineWidth',2,'FontSize',10,'box','off', 'FontWeight', 'bold')
    
    ax(1)=gca;
    ax(1).XLim=[5,100];
    ax(1).XScale='log';
    ax(1).YScale='log';
    ax(1).XTick=[5,10:10:50,100];
%     ax(2)=copyaxis(ax(1));%,'XLim',F(ax(1).XLim));%,'XTick',0:5:50);
    ax(2)=copyaxis(ax(1),'XTick',G([10,15,20:10:50]));
    set(ax(2),'xticklabel',num2str(round(F(get(ax(2),'xtick'))')))
    set(ax(2),'XMinorTick','off');
    set(ax(1),'XGrid','on','YGrid','on');
    
    if i>2
        xlabel('mean # strides when training','Parent',ax(1));
        ax(2).XTickLabel={};
    else
        ax(1).XTickLabel={};
        xlabel('size training set [%]','Parent',ax(2));
    end
end

%% _ EOF__________________________________________________________________
