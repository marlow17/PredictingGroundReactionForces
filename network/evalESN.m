function Y=evalESN(net,x,t) 
% function to evaluate the ESN with cell input
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Andreas Daffertshofer 2021
% ________________________________________________________________________
%
% See also evaluateESN

Y=cellfun(@(s)evaluateESN(net,s,t),x(:),'UniformOutput',false);

Y=reshape(Y,size(x));

end

%% _ EOF__________________________________________________________________