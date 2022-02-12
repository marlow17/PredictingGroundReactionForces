function [averageMAE,individualMAE]=eventError(event,fn)
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

if nargin<2, fn={ 'footOn','footOff' }; end

if ~iscell(fn), fn={ fn }; end

% individualMAE=repmat(cell2struct(cell(size(fn(:))),fn),size(event));


for n=1:numel(fn)
    individualMAE.(fn{n})=nan(size(event.target.(fn{n})));
    for i=1:numel(event.target.(fn{n}))
        individualMAE.(fn{n})(i)= ...
            MAE(event.target.(fn{n}){i},event.predicted.(fn{n}){i});
    end
    averageMAE.(fn{n})=MAE(cell2mat(event.target.(fn{n})(:)), ...
        cell2mat(event.predicted.(fn{n})(:)));
    % averageMAE.(fn{n})=mean([individualMAE.(fn{n})],'omitnan');
    % We used to compute the average per trial, however, some trials may
    % contain as little as 1 or 2 events which makes this approach not very
    % representative and it can 'just' cause outliers. 
end

if numel(fn)==1 && nargout==1
    averageMAE=averageMAE.([fn{1}]);
end

end

%% _ EOF__________________________________________________________________