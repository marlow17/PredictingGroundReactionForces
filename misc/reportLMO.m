function [strg,v]=reportLMO(err,mRange,fs)
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

fn=fieldnames(err);

strg=cell(size(fn));
fprintf('%s','M');
for i=1:numel(fn)
    switch fn{i}
        case 'epsilon', strg{i}=sprintf('\\epsilon [%%]');
        case 'footOnMAE', strg{i}=sprintf('FC [ms]');
        case 'footOffMAE', strg{i}=sprintf('FO [ms]');
        otherwise, strg{i}=sprintf('R^2');            
    end
    fprintf('\t%-10s',regexprep(regexprep(strg{i},'\',''),'^',''));

end
fprintf('\n')

for c=1:size(err,2)
    
    fprintf('%d',mRange(c));
    
    for i=1:numel(fn)
        
        val=arrayfun(@(s)mean(err(s,c).(fn{i})),1:size(err,1));
        switch fn{i}(end-1:end)
            case 'on', val=100*val;     fstrg='%.1f%c%.1f';
            case 'AE', val=val/fs*1000; fstrg='%.1f%c%.1f';
            otherwise, fstrg='%.3f%c%.3f';
        end
        v(:,i,c)=val;
        
        res(c).(['mean_' fn{i}])=mean(val,'omitnan');
        res(c).(['std_' fn{i}])=std(val,'omitnan');
    
        fprintf('\t%-10s', ...
            sprintf(fstrg,res(c).(['mean_' fn{i}]), ...
            char(177),res(c).(['std_' fn{i}])));
        
    end
    fprintf('\n');
        
end

%% _ EOF__________________________________________________________________



