function [X,Y,C,fs]=prepareData(data)
% [X,Y,C,fs]=prepareData(data)
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

% function to scale the input data
scale=@(x) x/range(x(:,1)); 

% read the data file
if ischar(data), load(data,'data'); end

fs=unique([data.SamplingRate]);
assert(numel(fs)==1, ...
    'Multiple sampling rates will be handled in a future release.');

% allocate memory
[X,Y,C]=deal(cell(size(data)));

% loop over data sets to prepare the data
for n=1:numel(data)
        
    data(n).GroundReactionForce=removeNaNs(data(n).GroundReactionForce);
    data(n).Accelerometer=removeNaNs(data(n).Accelerometer);    
    
    [A,V,P]=processData(data(n).Accelerometer,data(n).SamplingRate);    
    
    X{n}=[scale(A),scale(V),scale(P)];        % 'normalize' [A,V,P] data
    Y{n}=zscore(data(n).GroundReactionForce); % z-score the GRF
    C{n}=data(n).Condition;
            
end

end

%% -----------------------------------------------------------------------
function varargout=removeNaNs(varargin)
assert(nargin==nargout,'Input/output must be commensurate.');
varargout=varargin;
for i=1:nargin
    for j=1:size(varargin{i},2)
        if any(isnan(varargin{i}(:,j)))
            warning('Data contain NaNs that will be interpolated.')
            index=~isnan(varargin{i}(:,j));
            F=griddedInterpolant(find(index),varargin{i}(index,j), ...
                'pchip','nearest');
            varargout{i}(:,j)=F(1:numel(index));
        end
    end
end
        
end

%% _ EOF__________________________________________________________________