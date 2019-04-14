%% mlAI02 - main functuin to run

%% Get data for training
dataset = mlGetdata('AXP');

% pre-processing and create factors
dataset = mlDataPreproc(dataset);
save('dataAIX2.mat');

%% Partitioning
x = dataset{:,1:end-1};
y = dataset{:,end};
[nX,nFeatures] = size(x);
nIn = round(nX*0.8,0);
idxIn = [1:nIn]';
idxOut = [nIn + 1:nX]';
xInSample = x(idxIn,:);
yInSample = y(idxIn,:);
xOutSample = x(idxOut,:);
yOutSample = y(idxOut,:);

%Balance training dataset
nBuy = sum(yInSample == 'Buy');
nSell = nIn - nBuy;
nRemove = abs(nBuy-nSell);
if nRemove > 0
    if nBuy > nSell
        idxRemove = find(yInSample == 'Buy');
    elseif nSell > nBuy
        idxRemove = find(yInSample == 'Sell');
    end
    idxRemove2 = datasample(idxRemove,nRemove);
    xInSample(idxRemove2,:) = [];
    yInSample(idxRemove2,:) = [];
end

% Standardize training data (predictors) by column
nTrain = size(xInSample,1);
nTest= size(xOutSample,1);
muTrain = mean(xInSample);
sigmaTrain = std(xInSample);
xTrain = (xInSample - repmat(muTrain,nTrain,1)) ./ repmat(sigmaTrain,nTrain,1);
xTest = (xOutSample- repmat(muTrain,nTest,1)) ./ repmat(muTrain,nTest,1);

% Convert to Cell format
xTrain = mat2cell(xTrain', nFeatures, ones(nTrain,1))';
xTest = mat2cell(xTest', nFeatures, ones(nTest,1))';

%% Create layer and train
hiddenUnit = 2000;
layers = [ sequenceInputLayer(nFeatures)
           lstmLayer(hiddenUnit,'OutputMode','last')
           fullyConnectedLayer(2)
           softmaxLayer()
           classificationLayer];
 opts = trainingOptions('sgdm',...
    'Verbose',1,...
    'VerboseFrequency',50,...
    'Plots','training-progress', ...
    'shuffle', 'never',...
    'LearnRateSchedule','piecewise',...
    'InitialLearnRate', 0.01,...
    'MiniBatchSize',100,...
    'MaxEpochs',20);
netAIX2 = trainNetwork(xTrain,yInSample,layers, opts);

%% Back-testing on InSqample and Outofsample
mlBacktest;
