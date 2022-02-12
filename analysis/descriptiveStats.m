function stat=descriptiveStats(result,fn)
% compute the mean value and standard deviation of selected fields,
% typically all (the previously estimated) errors
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

gn=fieldnames(result);
stat=repmat(cell2struct(cell(size(gn)),gn),size(result,1),1);

for c=1:size(result,1)    
    for n=1:numel(gn)
        for j=1:numel(fn)
            if ~isfield(result(c,1).(gn{n}).error,fn{j}), continue; end
            x=arrayfun(@(r) ...
                result(c,r).(gn{n}).error.(fn{j}),1:size(result,2));
            stat(c).(gn{n}).(['mean_' fn{j}])=mean(x,'omitnan');
            stat(c).(gn{n}).(['std_' fn{j}])=std(x,'omitnan');
            
        end
    end
end

end

%% _ EOF__________________________________________________________________