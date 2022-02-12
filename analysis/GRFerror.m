function [R2,epsilon,COF,RMS]=GRFerror(target,predicted)
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

% the coefficient of determination
cod=@(x,y) 1-sum((x-y).^2,1)./sum((x-mean(x)).^2,1);

ind=1:numel(predicted);
ind=ind(~cellfun(@isempty,predicted));

if isempty(ind)
    [R2,epsilon]=deal(nan);
    [COF,RMS]=deal(nan(1,numel(predicted)));
    return;
end

COF=arrayfun(@(i)cod(target{i},predicted{i}),ind);
R2=mean(COF);
% R2=cod(cell2mat(vertcat(target(:))),cell2mat(vertcat(predicted(:))));
% we may compute the mean R2 over all trials as we do for the event errors,
% but this can be problematic if there are jumps in means between trials.

if nargout>1

    % function to estimate the error, this form agrees with
    % https://en.wikipedia.org/wiki/Root-mean-square_deviation
    nrmsd=@(x,y) rms(x-y)./range(x,1);
    
    RMS=arrayfun(@(i)nrmsd(target{i},predicted{i}),ind);
    epsilon=mean(RMS);
    % epsilon=nrmsd(cell2mat(vertcat(target(:))), ...
    %     cell2mat(vertcat(predicted(:))));
    % see above for pros and cons; now there might be jumps in ranges,
    % in particular when we combined different subjects and conditions.
    
end

end

%% _ EOF__________________________________________________________________