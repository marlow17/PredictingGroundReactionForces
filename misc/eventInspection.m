function eventInspection(result,fn,num)

% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

narginchk(2,3);

if ~iscell(fn), fn={ fn }; end

for c=1:size(result,1)
    for m=1:numel(fn)
        for r=1:size(result,2)
            event=result(c,r).(fn{m}).events;
            if nargin<3, num=1:numel(event); end
            for i=num
                plot(-[result(c,r).(fn{m}).target{i},result(c,r).(fn{m}).predicted{i}]);
                co=get(gca,'ColorOrder');
                axis tight;
                yl=get(gca,'YLim');
                hold on;
                for n=1:numel(event(i).target.HS)
                    line([1,1]*event(i).target.HS(n),yl,'Color',co(1,:),'LineStyle','-','LineWidth',1);
                    text(event(i).target.HS(n),yl(1),'HS','horizontalalignment','right','verticalalignment','top','Color',co(1,:));
                end
                for n=1:numel(event(i).target.TO)
                    line([1,1]*event(i).target.TO(n),yl,'Color',co(1,:),'LineStyle','-.','LineWidth',1);
                    text(event(i).target.TO(n),yl(1),'TO','horizontalalignment','right','verticalalignment','top','Color',co(1,:));
                end
                for n=1:numel(event(i).predicted.HS)
                    line([1,1]*event(i).predicted.HS(n),yl,'Color',co(2,:),'LineStyle','-','LineWidth',1);
                    text(event(i).predicted.HS(n),yl(1),'HS','horizontalalignment','left','verticalalignment','top','Color',co(2,:));
                end
                for n=1:numel(event(i).predicted.TO)
                    line([1,1]*event(i).predicted.TO(n),yl,'Color',co(2,:),'LineStyle','-.','LineWidth',1);
                    text(event(i).predicted.TO(n),yl(1),'TO','horizontalalignment','left','verticalalignment','top','Color',co(2,:));
                end
                hold off;
                title(sprintf('(%d,%d) %s - %d',c,r,fn{m},i));
                box off;
                drawnow;
                if i~=num(end) || r~=size(result,2) || m~=numel(fn) || c~=size(result,1)
                    pause
                end

            end
        end
    end
end

end