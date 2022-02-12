function esn=initializeESN(K,L,M,varargin)
% esn=initializeESN(K,L,M,varargin) - wrapper function to call generate_esn
% of the ESNToolbox provided by Manta Lukoševičius that can be found at
% https://www.ai.rug.nl/minds/uploads/ESNToolbox.zip
%
% Input
%   K,L,M    - Integers defining the dimension of the input (# of signals),
%              the number of nodes in the reservoir, and the dimension of
%              the output (# of signals), respectively.
%              NOTE that in contrast to the function generate_esn, here K
%              should be the real number of input signals (not +1!).
%   varargin - will be passed on to generate_esn; if numel(varargin)==1 &
%              varargin is struct, the struct is converted to a cell with
%              fieldnames as leading values.
%
% Output
%   esn      - a structure to be used with the ESNToolbox
%
%
% Example usage:
%
% esn=initializeESN(K,L,M,'spectralRadius',0.5,'type','leaky_esn');
%
% this is identical to
%
% opt=struct('spectralRadius',0.5,'type','leaky_esn');
% esn=initializeESN(K,L,M,opt);
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Andreas Daffertshofer 2021
% ________________________________________________________________________
%
% See also trainESN, evaluateESN, generate_esn

narginchk(3,inf);

if ~exist('generate_esn','file')
    addpath(genpath(fullfile(fileparts( ...
        fileparts(which(mfilename))),'external','ESNToolbox')));
end

if nargin==4 && isstruct(varargin{1})
    varargin=reshape([fieldnames(varargin{1}), ...
        struct2cell(varargin{1})]',[],1);
else
    assert(mod(nargin-3,2)==0, ...
        'Arguments must come in pairs - see generate_esn for details.');
end

for i=1:2:numel(varargin)
    
    switch varargin{i}
        case 'inputScaling'
            if size(varargin{i+1},1)==K
                varargin{i+1}=[1;varargin{i+1}];
            elseif size(varargin{i+1},1)==1
                varargin{i+1}=repmat(varargin{i+1},K+1,1);
            end
        case 'inputShift'
            if size(varargin{i+1},1)==K
                varargin{i+1}=[0;varargin{i+1}];
            elseif size(varargin{i+1},1)==1
                varargin{i+1}=repmat(varargin{i+1},K+1,1);
            end
        case 'teacherScaling'
            if size(varargin{i+1},1)==1
                varargin{i+1}=repmat(varargin{i+1},M,1);
            end
        case 'teacherShift'
            if size(varargin{i+1},1)==1
                varargin{i+1}=repmat(varargin{i+1},M,1);
            end
        case 'timeConstants'
            if size(varargin{i+1},1)==1
                varargin{i+1}=repmat(varargin{i+1},L,1);
            end
    end
            
end

maxAttempts=100;

for i=1:maxAttempts % we loop here since the ESN initialization may yield
                    % an improper connectivity matrix containing NaNs ...

    esn=generate_esn(K+1,L,M,varargin{:});
    if ~any(isnan(esn.internalWeights_UnitSR),'all')
        break;
    end
    
end

if any(isnan(esn.internalWeights_UnitSR),'all')
    warning('ESN might be corrupted.');
end

% normalize the internal weights a fix the connectivity matrix to have
% a given spectral radius (set above in the function definition)
esn.internalWeights=esn.spectralRadius*esn.internalWeights_UnitSR;

end

%% _ EOF__________________________________________________________________