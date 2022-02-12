function varargout=extractEpochs(x,overhead,varargin)
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

narginchk(3,inf);

assert(nargin-2==nargout | nargin-2==nargout-1, ...
    'Number of in- and output values must commensurate.');
varargout=cell(1,nargout);

N=size(varargin{1},1);
index=cell(numel(x)-1,1);
for i=1:numel(x)-1
    % we add also a trailing overhead but given that this 'overhead' should
    % resemble the transient regime of the ESN it does not make much sense
    % to add it; yet, our event-detection greatly benefits from the
    % trailing samples, so we keep this form for the time being...
    index{i}=(max(x(i)-overhead,1):min(x(i+1)+overhead,N))';
    % the next line should be removed prior to publishing the code
    if isempty(index{i}), keyboard; end
end

for n=1:numel(varargin)
    varargout{n}=cell(1,numel(x)-1);
    for i=1:numel(x)-1
        varargout{n}{i}=varargin{n}(index{i},:);
    end
end

if nargin-2==nargout-1
    varargout{nargout}=index;
end

end

%% _ EOF__________________________________________________________________