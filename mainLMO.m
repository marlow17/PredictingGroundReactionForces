% Main Leave-M-Out script accompanying the paper
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
addpath('network','analysis','preprocessing','graphics','misc');

nowstrg= ... % set a string with current date and time (used for logging)
    regexprep(char(datetime(now,'ConvertFrom','datenum')),{':',' '},'-');
diary(fullfile('log',['main3_' nowstrg '.log']));

rng(11); % set the random generator's seed for reproducibility

if ~exist('useParallel','var'), useParallel=true; end
if useParallel && isempty(gcp('nocreate')), parpool; end

%% define the input file
iName=fullfile('data','walk+run.mat');

[X,Y,C,fs]=prepareData(iName);
[footOn,footOff]= ...
    cellfun(@(s) estimateEvents(s,fs),Y,'UniformOutput',false);
transient=round(250/1000*fs); %250ms transient in the ESN (will be omitted)
maxNumStepsWhenTraining=15;
%
testDataType='continuous';

%
fn={ 'test' };
gn={ 'target', 'predicted' };

%%
oName=fullfile('results',sprintf('LMO-loop_%s.mat',testDataType));

if exist(oName,'file')  
    load(oName,'condition','numRun','mRange','numLMO','err','split');
else
    numLMO=100;
    numRun=100;
    condition='all';
    split=[75,25,0]/100;
    mRange=1:10;
    err=struct('R2',nan(1,numRun),'epsilon',nan(1,numRun),'footOnMAE',nan(1,numRun),'footOffMAE',nan(1,numRun));
    err=repmat(err,numLMO,numel(mRange));
end

%%
for m=1:numel(mRange)
    
    fprintf('\n<strong>%d/%d: M=%d %s </strong>\n\n',m,numel(mRange),mRange(m),repmat('-',1,40));
    
    for c=1:numLMO
        
        if mRange(m)==1
            ind=true(numel(X),1); 
            if c<=numel(C), ind(c)=false; else, continue; end
            fprintf('%d | %d\n\t',c,numel(X));
        else
            fprintf('%d | %d\n\t',c,numLMO);
            ind=crossvalind('LeaveMOut',numel(X),mRange(m));
        end

        if all(~isnan(err(c,m).R2))
            fprintf('using precomputed values.\n');
            continue;
        end
        

        selectDataFcn=@(x,y)splitData(x,y,split,testDataType,footOff(ind),transient,maxNumStepsWhenTraining);
        [res,esn]=TrainValidateTest(X(ind),Y(ind),selectDataFcn,transient,numRun,@(x,y)GRFerror(x,y)>0);
        
        [R2,epsilon,footOnMAE,footOffMAE]=deal(nan(1,numRun));

        target=cellfun(@(x) x(transient+1:end,:),Y(~ind),'UniformOutput',false);
        xi=X(~ind);
        t0=tic;
        fprintf('\tEvaluate ESN: ');
        parfor r=1:numRun
            
            if mod(r-1,numRun/10)==0, fprintf('.'); end

            if esn(r).trained==0, continue; end % training failed
            
            predicted=evalESN(esn(r),xi,transient);
            [R2(r),epsilon(r)]=GRFerror(target,predicted);
            [tFC,tFO]=estimateEvents(target,fs);
            [pFC,pFO]=estimateEvents(predicted,fs);
            events=struct('target',struct('footOn',{tFC},'footOff',{tFO}),'predicted',struct('footOn',{pFC},'footOff',{pFO}));
            footOnMAE(r)=eventError(events,'footOn');
            footOffMAE(r)=eventError(events,'footOff');
            
        end        
        fprintf(' '); toc(t0);
        
        err(c,m).R2=R2;
        err(c,m).epsilon=epsilon;
        err(c,m).footOnMAE=footOnMAE;
        err(c,m).footOffMAE=footOffMAE;
        
    end
    
    save(oName,'fs','condition','numRun','mRange','numLMO','err','split');

end

diary off

%% _ EOF__________________________________________________________________
