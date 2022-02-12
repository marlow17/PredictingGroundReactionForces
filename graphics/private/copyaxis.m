function bx=copyaxis(ax,varargin)

set(ax,'Box','off')
bx=copyobj(ax,ax.Parent);
delete([bx.Children(:)',bx.Title,bx.XLabel,bx.YLabel]);

bx.Color='none';

bx.XAxisLocation='top';
bx.XLim=ax.XLim;
bx.XTick=ax.XTick;
bx.XGrid='off';

bx.YAxisLocation='right';
bx.YLim=ax.YLim;
bx.YTick=ax.YTick;
bx.YTickLabel=[];
bx.YGrid='off';

if nargin>1
    set(bx,varargin{:})
end
% bx.XLim=F(ax(1).XLim);
% bx.XTick=0:5:50; ...%F(ax(1).XTick);
