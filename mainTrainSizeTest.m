% Main Training-Size-Test script accompanying the paper
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

nowstrg= ... % set a string with current date and time (used for logging)
    regexprep(char(datetime(now,'ConvertFrom','datenum')),{':',' '},'-');
diary(fullfile('log',['main2_' nowstrg '.log']));

rng(11); % set the random generator's seed for reproducibility

if ~exist('useParallel','var'), useParallel=true; end
if useParallel && isempty(gcp('nocreate')), parpool; end

%% define the input file
iName=fullfile('data','walk+run.mat');

[X,Y,C,fs]=prepareData(iName);
[footOn,footOff]= ...
    cellfun(@(s) estimateEvents(s,fs),Y,'UniformOutput',false);
transient=round(250/1000*fs);% 250ms transient in the ESN (will be omitted)
testDataType='continuous';
maxNumStepsWhenTraining=15;

numRun=100;
condition='all';

split=[0,25,25]/100;
%
fn={ 'train', 'validate', 'test' };
gn={ 'target', 'predicted' };

split=repmat(split,50,1);
split(:,1)=(10.^linspace(log10(4),log10(50),50))/100;

numSuccessfulRuns=zeros(1,size(split,1));
numTrainData=cell(1,size(split,1));
stat=repmat(cell2struct(cell(size(fn))',fn),1,size(split,1));

for n=1:size(split,1)
        
    selectDataFcn=@(x,y)splitData(x,y,split(n,:),testDataType, ...
        footOff,transient,maxNumStepsWhenTraining);
    fprintf('step %d [%g%%] - ',n,split(n,1)*100);
    res=TrainValidateTest(X,Y,selectDataFcn,transient,numRun, ...
        @(x,y)GRFerror(x,y)>0);

    res=res(arrayfun(@(i) ~isempty(res(i).train.input),1:numel(res)));
    
    for r=1:numel(res)
        for i=1:numel(fn)
            for j=1:numel(gn)
                [ ...
                    res(r).(fn{i}).events.(gn{j}).footOn, ...
                    res(r).(fn{i}).events.(gn{j}).footOff ...
                    ]=estimateEvents(res(r).(fn{i}).(gn{j}),fs);
            end
        end
        
        for i=1:numel(fn)
            [res(r).(fn{i}).error.R2,res(r).(fn{i}).error.epsilon]= ...
                GRFerror(res(r).(fn{i}).target,res(r).(fn{i}).predicted);
            res(r).(fn{i}).error.footOnMAE= ...
                eventError(res(r).(fn{i}).events,'footOn');
            res(r).(fn{i}).error.footOffMAE= ...
                eventError(res(r).(fn{i}).events,'footOff');
        end
    end
   
    numSuccessfulRuns(n)=numel(res);
    numTrainData{n}=arrayfun(@(s)numel(res(s).train.target),1:numel(res));
    if ~isempty(res)
        stat(n)=descriptiveStats(res, ...
            {'R2','epsilon','footOnMAE','footOffMAE'});
    end
    
    save(fullfile('results',sprintf('L-loop_%s.mat',testDataType)), ...
        'fs','condition','numRun','numSuccessfulRuns', ...
        'numTrainData','split','stat');

end

diary off

%% _ EOF__________________________________________________________________
