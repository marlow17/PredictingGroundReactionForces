function esn=trainESN(esn,X,Y,omit,verbose)
% esn=trainESN(esn,X,Y,omit,verbose) - wrapper function for train_esn
% of the ESNToolbox provided by Manta Lukoševičius that can be found at
% https://www.ai.rug.nl/minds/uploads/ESNToolbox.zip
%
% Input
%   esn      - An initialzed esn; see initializeESN or generate_esn.
%   X        - Input signal - number of signals must agree with the esn.
%   Y        - Target signal - number of signals must agree with the esn.
%   omit     - Number of samples considered transient - they will be
%              omitted in when doing the regression (learning); optional,
%              default = 0;
%   verbose  - Flag used to monitor output; optional, default - false.
%
% Output
%   esn      - a trained esn
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Andreas Daffertshofer 2021
% ________________________________________________________________________
%
% See also initializeESN, evaluateESN, train_esn

narginchk(3,5);

if nargin<4, omit=0; end
if nargin<5, verbose=false; end

if iscell(X) && numel(X)>1

    X=cellfun(@(s)[ones(size(s,1),1),s],X(:),'UniformOutput',false);
    Y=Y(:);

    if strcmp(esn.learningMode,'offline_singleTimeSeries')
        if verbose
            warning('Switching learning to multiple time series.');
        end
        esn.learningMode='offline_multipleTimeSeries';
    end
        
else
 
    if iscell(X), X=X{1}; Y=Y{1}; end

    X=[ones(size(X,1),1),X];
    
    if strcmp(esn.learningMode,'offline_multipleTimeSeries')
        if verbose
            warning('Switching learning to single time series.');
        end
        esn.learningMode='offline_singleTimeSeries';
    end

end
    
% ESN training
esn=train_esn(X,Y,esn,omit);

end

%% _ EOF__________________________________________________________________
