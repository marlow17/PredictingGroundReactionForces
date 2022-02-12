function [meanAbsErr,absErr]=MAE(a,b,thres)
% [meanAbsErr,absErr]=MAE(a,b,thres) - function to calculate mean absolute
% error between two inputs
%
% Input
%   a       - First input, should be an array
%   b       - Second input, should be an array
% optional inputs:
%  thres    - Threshold to check for similarity. Default: 5*minimum+3 of
%               pdist2(a,b)
%
% Output
%   MAE     - mean absolute error
%   AE      - absolute error (useful if input is continuous data)        
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Margit M Bach 2021
% ________________________________________________________________________

narginchk(2,3)

if ~isempty(a) && ~isempty(b)
    
    d=pdist2(a,b);
    
    if nargin<3 || isempty(thres), thres=5*min(d(:))+3; end
    
    [i,j]=find(d<=thres);
    
    if isempty(i) || isempty(j); thres=5*min(d(:));
        [i,j]=find(d<=thres);
    end
    
    meanAbsErr=mean(abs(diff([a(i,1) b(j,1)], [],2)));
    absErr=abs(diff([a(i,1) b(j,1)], [],2))';
    
else
    
    meanAbsErr=NaN;
    absErr=NaN;
    
end

%% _ EOF__________________________________________________________________