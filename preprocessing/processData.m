function [A,V,P,x]=processData(A,fs)
% [A,V,P]=processData(A,fs) - process the accelerometer signals
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

% transform A to its principal axes
[x,A]=pca(A,'algorithm','eig');

% use the leading PC
A=A(:,1);

% if first PC is negative, swap orientation
if x(2,1)<0; A=-A; end

% normalize A by its standard deviation
A=A/std(A);

% estimate velocity and position after 1 Hz high-pass filtering
[b,a]=butter(2,1/(fs/2),'high'); 
V=filtfilt(b,a,cumtrapz(1/fs,A));
P=filtfilt(b,a,cumtrapz(1/fs,V));

end

%% _ EOF__________________________________________________________________