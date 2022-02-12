% Main Train-Validate-Test script accompanying the paper
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

if ~exist('testDataType','var'), testDataType='continuous'; end

nowstrg= ... % set a string with current date and time (used for logging)
    regexprep(char(datetime(now,'ConvertFrom','datenum')),{':',' '},'-');
diary(fullfile('log',['main1_' testDataType '_' nowstrg '.log']));

rng(11); % set the random generator's seed for reproducibility

%% define the input file
iName=fullfile('data','walk+run.mat');

%% import and prepare the data 
[X,Y,C,fs]=prepareData(iName);

%% specify the remaining parameters
condition={ 'all' 'walking', 'running' };

transient=round(250/1000*fs); % 250 ms ESN transients (will be omitted)
numRun=100;                   % number of repetitions
split=[50,25,25]/100;         % train/validate/test split
maxNumStepsWhenTraining=15;   % maximum # of steps per trial when training

%% set up the parallel pool if requested (default=true)
if ~exist('useParallel','var'), useParallel=true; end
if useParallel && isempty(gcp('nocreate')), parpool; end

%% run analysis around Figure 2 ------------------------------------------

% with the current settings the average run time on an Intel-MacBook-Pro
% is about an hour when using serial processing (useParallel=false); 
% in parallel mode (default) this roughly scales with the number of cores
% available, i.e. 4 cores ~ 15 min or 36 cores (iMac Pro) < 2 min ...

% get the events; used for selecting the training set(s)
[footOn,footOff]= ...
    cellfun(@(s) estimateEvents(s,fs),Y,'UniformOutput',false);

% set the to-be-filled fieldnames
fn={ 'train', 'validate', 'test' };
gn={ 'target', 'predicted' };

% allocate memory
result=repmat(cell2struct(cell(size(fn))',fn),size(condition,1),numRun);

% training, validating and testing
for c=1:numel(condition) % loop over conditions
    
    ind=ismember(C,condition{c});
    if ~any(ind), ind=true(size(ind)); end % use all conditions
    
    % specify the data selection function
    selectDataFcn=@(x,y)splitData(x,y,split,testDataType, ...
        footOff(ind),transient,maxNumStepsWhenTraining);
    fprintf('%s [%s] - ',condition{c},testDataType);
    % run the ESN machine learner
    result(c,:)=TrainValidateTest(X(ind),Y(ind),selectDataFcn, ...
        transient,numRun,@(x,y)GRFerror(x,y)>0);
    
end

% estimate the gait events for the target and the predicted signals
for n=1:numel(result)
    for i=1:numel(fn)
        for j=1:numel(gn)
            [ ...
                result(n).(fn{i}).events.(gn{j}).footOn, ...
                result(n).(fn{i}).events.(gn{j}).footOff ...
                ]=estimateEvents(result(n).(fn{i}).(gn{j}),fs);
        end
    end
end

% a sanity check (might be removed prior to publishing the code)
[N,S]=eventSanityCheck(result);

% determine R2 and epsilon of the GRF as well as MAE of the gait events
for n=1:numel(result)
    for i=1:numel(fn)
        [result(n).(fn{i}).error.R2,result(n).(fn{i}).error.epsilon]= ...
            GRFerror(result(n).(fn{i}).target,result(n).(fn{i}).predicted);
        result(n).(fn{i}).error.footOnMAE= ...
            eventError(result(n).(fn{i}).events,'footOn');
        result(n).(fn{i}).error.footOffMAE= ...
            eventError(result(n).(fn{i}).events,'footOff');
    end
end

% descriptive statistics over runs (mean & std) of all errors
stat=descriptiveStats(result,{'R2','epsilon','footOnMAE','footOffMAE'});

% we save all results so that we may run the parts below (stats report
% and plotting) without recomputing the bugger
save(fullfile('results',sprintf('statistics_%s.mat',testDataType)), ...
    'result','fs','condition','stat','split');

diary off

%% _ EOF__________________________________________________________________
