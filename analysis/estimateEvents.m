function [footOn,footOff,GRF]=estimateEvents(GRF,fs,weightFac,ord,win)
% [footOn,footOff,GRF]=estimateEvents(GRF,fs,weightFac) - function to 
% estimate foot-on and foot-off events based on vertical ground reaction
% forces.
%
% Input
%   GRF         - vertical ground reaction forces (ensure stance phase is
%                 positive). Can be scaled to [0 1]
%   fs          - sampling frequency of GRF
% optional inputs:
%   weightFac   - weightfactor for determining threshold. Default is 1/8 of
%                 max vertical GRF
%   ord         - order of Savitzky Golay filter, default: 1
%   win         - window length of Savitzky Golay filter. Default: 30/1000
%                 (-30 ms)
%
% Output
%   footOn      - foot-on events
%   footOff     - foot-off events
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
%                                           (c) Margit M Bach 2021
% ________________________________________________________________________

narginchk(2,5);

if nargin<3, weightFac=1/8; end
if nargin<4, ord=1; end
if nargin<5, win=30/1000; end

% this is just a wrapped to allow for both doubles and cells as input
if iscell(GRF)
    [footOn,footOff,GRF]= ...
        cellfun(@(s)estimateEventsSingle(s,fs,weightFac,ord,win),GRF, ...
        'UniformOutput',false);
else
    [footOn,footOff,GRF]=estimateEventsSingle(GRF,fs,weightFac,ord,win);
end
    
end

% this is the real function ----------------------------------------------
function [footOn,footOff,GRF]= ...
    estimateEventsSingle(GRF,fs,weightFac,ord,win)

% if the input is empty, so will be the output
if isempty(GRF), [footOn,footOff]=deal([]); return; end

% check for NaN values and remove any
if any(isnan(GRF))
    warning(['Data contain NaNs. We interpolate them but that ' ...
        'might yield bogus results.']);
    index=~isnan(GRF);
    F=griddedInterpolant(index,GRF(index),'pchip','nearest');
    GRF=F(1:numel(GRF));
end

% the following line is to avoid possible transients; it is clearly not a
% particularly elegant solution and should be reconsidered - for the time
% being, though, we keep this as is first and foremost because our code
% is primarily (if not solely) meant to support the proof-of-concept when
% it comes to the used of echo-state networks in predicting GRF-waveforms
m=max(GRF(fix(end/10):end)); GRF(GRF>m)=m;

% normalize the GRF to the interval [0,1] to ease threshold definition
GRF=rescale(-GRF);

% filter data
GRF=sgolayfilt(GRF,ord,2*round((win*fs)/2)+1);

% Set threshold to 12.5% of max body weight for detection of HS and TO
thold=max(GRF)*weightFac;

% find mid-point of data (depends on range of data)
tholdRF=mean([mean(GRF) [mean(GRF) mean(minmax(GRF'))]]);

footOff=find(GRF(2:end)<thold & GRF(1:end-1)>thold)+1;
fall=find(GRF(1:end-1)>tholdRF & GRF(2:end)<tholdRF);
[~,t]=min(pdist2(footOff,fall));
if t<=numel(footOff), footOff=footOff(t); end

footOn=find(GRF(1:end-1)<thold & GRF(2:end)>thold);
rise=find(GRF(1:end-1)<tholdRF & GRF(2:end)>tholdRF);
[~,t]=min(pdist2(footOn,rise));
if t<=numel(footOn), footOn=footOn(t); end

% remove any events detected that are too close to being actual events
footOn=uniquetol(footOn,0.01);
footOff=uniquetol(footOff,0.01);

end

%% _ EOF__________________________________________________________________
