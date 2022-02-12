function [N,strg]=eventSanityCheck(result)

% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________


narginchk(1,2);

if nargin<2, showplot=false; end

fn={ 'train','test' };
en={ 'footOn','footOff' };

N=[];
strg={};

for c=1:size(result,1)
    for r=1:size(result,2)
        for m=1:numel(fn)
            event=result(c,r).(fn{m}).events;
            for i=1:numel(event)
                for n=1:numel(en)
                    N(end+1,:)=[numel(event(i).target.(en{n})),numel(event(i).predicted.(en{n}))];
                    if isempty(event(i).target.(en{n})) || isempty(event(i).predicted.(en{n})) || ...
                            numel(event(i).target.(en{n})) ~= numel(event(i).predicted.(en{n}))
                        strg{size(N,1)}=sprintf('Condition %d | %-5s | set %2d | run %3d | %s events',c,fn{m},i,r,en{n});
                        if isempty(event(i).target.(en{n})) || isempty(event(i).predicted.(en{n}))
                            strg{size(N,1)}=sprintf('%s missing.\n',strg{size(N,1)});
                        else
%                             if numel(event(i).target.(en{n}))<numel(event(i).predicted.(en{n}))
%                                 [event(i).target.(en{n})(1),event(i).predicted.(en{n})(1)]
%                             end
                            strg{size(N,1)}=sprintf('%s differ in number (diff = %d).\n',strg{size(N,1)},abs(numel(event(i).target.(en{n}))-numel(event(i).predicted.(en{n}))));
                        end
                    end
                end
            end
        end
    end
    
end

fprintf([ ...
    '\nFound %d sets with a total of %d events:\n' ...
    ' - %d sets (%.0f%%) do not contain proper events;\n' ...
    ' - in %d sets (%.0f%%) the event numbers differ between target & prediction' ...
    ' (max +/-%d events).\n'], ...
    size(N,1),sum(N(:,1)), ...
    sum(all(N==0,2)),sum(all(N==0,2))/size(N,1)*100, ...
    sum(diff(N,[],2)~=0),sum(diff(N,[],2)~=0)/size(N,1)*100, ...
    max(abs(diff(N,[],2))));



if nargout==0
    clear('N');
end