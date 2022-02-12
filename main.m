% Main script accompanying the paper
%
% "Predicting vertical ground reaction forces from 3D accelerometery using
% reservoir computers leads to accurate gait event detection", Margit M
% Bach, Nadia Dominici, and Andreas Daffertshofer. Vrije Universiteit
% Amsterdam
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

%% set the Matlab path
addpath(genpath('external'));
addpath('network','analysis','preprocessing','misc');

%-------------------------------------------------------------------------
testDataType='continuous';
run('mainTrainValidateTest.m');
run('makeFigure2.m');

%-------------------------------------------------------------------------
run('mainTrainSizeTest.m');
run('makeFigure3.m');

%-------------------------------------------------------------------------
testDataType='strides';
run('mainTrainValidateTest.m');
run('makeFigureS123.m');

%-------------------------------------------------------------------------
run('makeLMO.m');
run('makeFigureS4.m');

%% _ EOF__________________________________________________________________


