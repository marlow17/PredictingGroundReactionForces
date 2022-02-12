function h=plotPrediction(result,trial,fs)

% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

if ~iscell(result.target), result.target={ result.target }; end
if ~iscell(result.predicted), result.predicted={ result.predicted }; end

if isempty(trial), trial=1:numel(result.target); end
cla;
% h=[];
% z0=min(cellfun(@min,[result.target;result.predicted]));
for i=1:numel(trial)
    x=repmat((1:numel(result.predicted{trial(i)}))',1, ...
        size(result.predicted{trial(i)},2))/fs;
    y=repmat(i,size(result.predicted{trial(i)}));
    
%     z=max(result.target{i},result.predicted{i});
%     patch([x;x(end:-1:1,:)],[y;y(end:-1:1,:)], ...
%         [z;repmat(z0,size(z))],ones(size([z;z])),...
%         'facecolor','w','edgecolor','none','facealpha',0.5);
    
    hold on; %h=[];
    h(i,1)=plot3(x,y,-result.target{trial(i)},'k','linewidth',1);
    h(i,2)=plot3(x,y,-result.predicted{trial(i)},'r','linewidth',1);
    
end
hold off;
axis tight;

if numel(result.target)==1
    view(0,0); 
else
    view(-5,20);
end

xlabel('time');
ylabel(sprintf('step  \nnumber'),'HorizontalAlignment','right','VerticalAlignment','bottom');
zlabel('GRF');
grid on;
set(gca,'XTick',[],'ZTick',[], 'FontWeight', 'bold', 'LineWidth', 2)

if nargout==0
    h=legend(h(1,:),'target','prediction','location','southeast');
    h.LineWidth=0.1;
    clear('h');
end

end