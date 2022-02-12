function Y=evaluateESN(esn,X,omit)
% Y=evaluateESN(esn,X,omit) - wrapper function to call test_esn of the 
% ESNToolbox provided by Manta Lukoševičius. The toolbox can be found at
% https://www.ai.rug.nl/minds/uploads/ESNToolbox.zip
%
% Input
%   esn      - A trained esn; see trainESN or train_esn.
%   X        - Input signal - number of signals must agree with the esn.
%   omit     - Number of samples considered transient - they will be
%              omitted in the output; optional,
%              default = 0;
%
% Output
%   Y        - Output signal - number of signals will agree with the esn.
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Andreas Daffertshofer 2021
% ________________________________________________________________________
%
% See also initializeESN, trainESN, train_esn

narginchk(2,3);

if nargin<3, omit=0; end

if iscell(X)
    X=cellfun(@(s)[ones(size(s,1),1),s],X,'UniformOutput',false);
else
    X=[ones(size(X,1),1),X];
end
    
% running the ESN
Y=test_esn(X,esn,omit);

end

%% _ EOF__________________________________________________________________