function checkESNtoolbox
% checkESNtoolbox - check whether Manta Luko?evi?ius' Matlab toolbox can
% be found. As of Nov 2021 it is freely available under
%
%   https://www.ai.rug.nl/minds/uploads/ESNToolbox.zip
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Andreas Daffertshofer 2021
% ________________________________________________________________________

adr='https://www.ai.rug.nl/minds/research/esnresearch/';

if ~exist('generate_esn','file')
    try
        web(adr);
    catch
    end
    error(['<a href="%s">Mantas Lukosevicius ESN Matlab ' ...
        'toolbox</a> cannot be found.\n'], adr);
end

%% _ EOF__________________________________________________________________