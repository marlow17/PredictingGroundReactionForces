function storeFigures(fig,folder,format)

% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________


if nargin<3, format={'png','pdf','eps','fig'}; end

if ~iscell(format), format={ format }; end

if ~exist(folder,'dir'); mkdir(folder); end

if isempty(fig)
    fig=findobj(0,'type','figure');
end

for i=1:numel(format)
    
    if ~exist(fullfile(folder,format{i}),'dir')
        mkdir(fullfile(folder,format{i}));
    end
    
    switch format{i}
        case 'png'
            arrayfun(@(s) exportgraphics(s,fullfile('figures','png', ...
                [get(s,'Name') '.png']),'resolution',600),fig);
        case 'eps'
            arrayfun(@(s) exportgraphics(s,fullfile('figures','eps', ...
                [get(s,'Name') '.eps'])),fig);
        case 'pdf'
            arrayfun(@(s) exportgraphics(s,fullfile('figures','pdf', ...
                [get(s,'Name') '.pdf'])),fig);
        case 'fig'
            arrayfun(@(s) hgsave(s,fullfile('figures','fig', ...
                [get(s,'Name') '.fig'])),fig);
            
    end
    
end

end
