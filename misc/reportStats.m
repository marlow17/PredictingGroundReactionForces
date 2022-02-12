function reportStats(stat,condition,fs)
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

fprintf('<strong>%-8s\t%-8s','Type','Name');
for c=1:numel(stat)
    fprintf('\t%-11s',condition{c});
end
    
fprintf('</strong>\n%s\n',repmat('-',1,78));

fn=fieldnames(stat);
for n=1:numel(fn)
    if isempty(stat(1).(fn{n})), continue; end
    gn=fieldnames(stat(1).(fn{n}));
    gn=unique(regexprep(gn,'mean_|std_',''),'stable');
    for j=1:numel(gn)
        
        [mu,sd]=deal(nan(size(stat)));
        for c=1:size(stat,1)
            mu(c)=stat(c).(fn{n}).(['mean_' gn{j}]);
            sd(c)=stat(c).(fn{n}).(['std_' gn{j}]);
        end
        
        switch gn{j}(end-1:end)
            case 'on', mu=100*mu; sd=100*sd;
            case 'AE', mu=mu/fs*1000; sd=sd/fs*1000;
        end
        unit=' ms';
        if strcmp(gn{j},'epsilon')
            unit=' %';
        elseif strcmp(gn{j},'R2')
            unit='';
        end
        
        if j==1, m=fn{n}; else, m=''; end

        fprintf('%-8s\t%-8s',m,gn{j})
        if strcmp(gn{j},'R2')
            strg='%.3f%c%.3f';
        else
            strg='%.1f%c%.1f';
        end
        for c=1:numel(mu)
            s=sprintf(strg,mu(c),char(177),sd(c));
            fprintf('\t%-11s',s)
        end
        fprintf('%s\n',unit);
    end
    
end

fprintf('%s\n',repmat('-',1,78));


end

%% _ EOF__________________________________________________________________