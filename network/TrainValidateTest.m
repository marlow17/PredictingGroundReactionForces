function [res,esn]=TrainValidateTest(X,Y,selectFcn,omit,numRun,valFun)
% [train,validate,test]=runTrainAndTest(X,Y,E,eventValue,omit,numRun)
%
% Documentation needed!
%
%
% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

nNodes=1000;
nInput=size(X{1},2);
nOutput=size(Y{1},2);

storeESN=nargout==2;

%% allocate memory for the output variables
res=repmat(struct('train',[],'validate',[],'test',[]),1,numRun);
if storeESN
    wa=warning('off'); % the ESN - see initializeESN for details ...
    esn=repmat(initESN(nInput,nNodes,nOutput),numRun,1);
    warning(wa);
end

%% select the data to use
maxIter=100;
for r=1:numRun
    for i=1:maxIter % we loop to anticipate that data are too short to 
                    % always guarantee a succesful data selection
        [res(r).train,res(r).validate,res(r).test]=selectFcn(X,Y);
        if ~isempty(res(r).train.input)
            break;  % if we found data for train we end the loop
        end
    end
    if isempty(res(r).train.input)
        fprintf('[%d no data] ',r);
    end
end

if numel(res(1).validate.input) && ( nargin<6 || isempty(valFun) )
    error('Adding a validation step requires a stopping criterion.');
end

%% check for parallel workers
p0=gcp('nocreate');
if isempty(p0)
    useParallel=0;
else
    useParallel=p0.NumWorkers;
end

t0=tic;
fprintf('%s: ',mfilename);

if nargin<6, valFun=[]; end
maxIter=200;

seed=rng().Seed;

%% loop over individual training and evaluation runs
parfor ( r=1:numRun, min(useParallel,numRun) )

    if isempty(res(r).train.input), continue; end
    
    rng(seed+r); % set the random generator's seed for reproducibility

    if mod(r-1,numRun/10)==0, fprintf('.'); end

    wa=warning;     % we switch off the possible warning when initializing
    warning('off'); % the ESN - see initializeESN for details ...

    ESN=[];
    for i=1:maxIter % loop over validation attempts
        
        % generate a new ESN
        ESN=initESN(nInput,nNodes,nOutput);
        % train the ESN
        ESN=trainESN(ESN,res(r).train.input,res(r).train.target,omit);

        ESN.noiseLevel=0; % we switch off the noise
        
        if ~numel(res(r).validate.input), break; end % skip validation
        
        % evaluate the ESN during the validation session
        res(r).validate.predicted=evalESN(ESN,res(r).validate.input,omit);
        if isempty(valFun), break; end % skip judging the validation
        vr=removeTransient(res(r),omit,{'input','target'},'validate');
        % if validation was successful, we end the loop
        if valFun(vr.target,vr.predicted), break; end
        
        if mod(i-1,maxIter/10)==0, fprintf('o'); end

        if i==maxIter
            fprintf('<strong>Validation failed!</strong>');
            ESN=[];
        end

    end

    if ~isempty(ESN)

        % store the ESN if requested
        if storeESN, esn(r)=ESN; end

        % evaluate the ESN during the test session
        if numel(res(r).test.input)
            res(r).test.predicted=evalESN(ESN,res(r).test.input,omit);
        end
        % evaluate the ESN during the training session
        res(r).train.predicted=evalESN(ESN,res(r).train.input,omit);
    end
    warning(wa);

end

fprintf(' '); toc(t0);

if ~storeESN  % if we do not store the ESN for later used, we cut the
    % input and target signals for the part that has been
    % encountered as transient of the reservoir (=omit)
    res=removeTransient(res,omit,{'input','target'});
end

end

%% _ EOF__________________________________________________________________
