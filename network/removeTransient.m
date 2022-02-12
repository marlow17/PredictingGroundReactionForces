function s=removeTransient(s,omit,gn,fn)
%% function to remove transient samples ----------------------------------

% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________


if nargin>3
    s=rmfield(s,setdiff(fieldnames(s),fn));
end

fn=fieldnames(s);
for r=1:numel(s)
    for m=1:numel(fn)
        for n=1:numel(gn)
            s(r).(fn{m}).(gn{n})=cellfun(@(x) x(omit+1:end,:), ...
                s(r).(fn{m}).(gn{n}),'UniformOutput',false);
        end
    end
end

if nargin>3 && numel(fn)==1
    s=s.(fn{1});
end

end