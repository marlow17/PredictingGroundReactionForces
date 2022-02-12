function [train,validate,test]=splitData(X,Y,split,testDataType, ...
    event,omit,maxNumTrainSteps)

% ________________________________________________________________________
%
% This file is released under the terms of the GNU General Public License,
% version 3. See http://www.gnu.org/licenses/gpl.html
%
% ________________________________________________________________________

%% function to select the data 

assert(sum(split)<=1,'Sum of splits must not exceed 1.');

if nargin<7, maxNumTrainSteps=[]; end

[train,validate,test]=deal(struct('input',{{}},'target',{{}}));

for n=1:numel(X)
    
    % split data into steps
    [x,y,index]=extractEpochs(event{n},omit,X{n},Y{n});

    switch lower(testDataType(1:min(numel(testDataType),4)))
        
        case 'cont'
            
            % first, extract continuous data
            holdIn=0:rRound(size(X{n},1)*(1-split(1)))+omit;
            holdIn=holdIn(holdIn>0 & holdIn<=size(X{n},1));
            holdIn=randperm(size(X{n},1)-numel(holdIn)+1,1)+holdIn;
            % and select strides that do not overlap with the selected
            % (1-holdOut) continuous interval (=holdIn) for training
            trainIndex=cellfun(@(s) ~any(ismember(holdIn(omit:end),s)), ...
                cellfun(@(t) t(omit:end-omit),index, ...
                'UniformOutput',false));
            if ~isempty(maxNumTrainSteps)
                trainIndex=trainIndex(1:min(maxNumTrainSteps,end));
            end
            holdIn=unique([cell2mat(index(~trainIndex));holdIn(:)]);
            if split(1)>0 && isempty(trainIndex)
                error(['Something went wrong when extracting ' ...
                    'the data for training.']);
            end
            
            % randomize the order of drawing the validation and test data
            for i=randperm(2,2)
                j=holdIn(1:min(rRound(split(i+1)*size(X{n},1)),end));
                if i==1, valIndex=j; else, testIndex=j; end
                if split(i+1)>0 && isempty(j)
                    error('Something went wrong when extracting the data');
                end
                holdIn=setdiff(holdIn,j);
            end
                            
            % note that due to rounding number we may loose a few samples
            if ~isempty(trainIndex)
                [train.input{n},train.target{n}]= ...
                    deal(x(trainIndex),y(trainIndex));
            end
            if ~isempty(valIndex)
                [validate.input{n},validate.target{n}]= ...
                    deal(X{n}(valIndex,:),Y{n}(valIndex,:));
            end
            if ~isempty(testIndex)
                [test.input{n},test.target{n}]= ...
                    deal(X{n}(testIndex,:),Y{n}(testIndex,:));
            end
            
        case { 'stri', 'step' }

            % select the indices for training
            trainIndex=randperm(numel(x),rRound(split(1)*numel(x)));
            if ~isempty(maxNumTrainSteps)
                trainIndex=trainIndex(1:min(maxNumTrainSteps,end));
            end
            
            % select indices for validation (not overlapping with training)
            holdIn=setdiff(1:numel(x),trainIndex);
            h=randperm(numel(holdIn), ...
                min(rRound(split(2)*numel(x)),numel(holdIn)));
            valIndex=holdIn(h);
            holdIn=setdiff(holdIn,h);

            % dito for testing (not overlapping with training & validation)
            h=randperm(numel(holdIn), ...
                min(rRound(split(3)*numel(x)),numel(holdIn)));
            testIndex=holdIn(h);
            
            % select the corresponding steps
            [test.input{n},test.target{n}]= ...
                deal(x(testIndex),y(testIndex));
            [validate.input{n},validate.target{n}]= ...
                deal(x(valIndex),y(valIndex));
            [train.input{n},train.target{n}]= ...
                deal(x(trainIndex),y(trainIndex));
            
        otherwise
            
            error('Unkown test type.');
            
    end
         
end

train.input=horzcat(train.input{:});
train.target=horzcat(train.target{:});

if ~strncmpi(testDataType,'cont',4)
    test.input=horzcat(test.input{:});
    test.target=horzcat(test.target{:});
    validate.input=horzcat(validate.input{:});
    validate.target=horzcat(validate.target{:});
end

train.predicted=cell(size(train.target));
test.predicted=cell(size(test.target));
validate.predicted=cell(size(validate.target));

end


function x=rRound(x)

if rand(1)>0.5, x=ceil(x); else, x=floor(x); end

end
