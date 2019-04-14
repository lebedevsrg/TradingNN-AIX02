% mlBacktest - back-testing on InSqample and Outofsample

% Back-test insample
tDay= 252;
xInSample = x(idxIn,:);
yInSample = y(idxIn,:);
dimDef2 = ones(size(xInSample,1),1);
xBacktest = mat2cell(xInSample', nFeatures, dimDef2);
xBacktest=xBacktest'; % to VerticaL ARRAY

clsRes = classify(netAIX2,xBacktest);
plotconfusion(yInSample,clsRes);
signal1 = 1*(clsRes == 'Buy') -1*(clsRes == 'Sell');
yRetInSample =  dataset.retD1(idxIn,:);
portReturns1 = signal1(1:end-1).*yRetInSample(2:end);
portValue1 = ret2tick(portReturns1);
sharpeRatio1 = sharpe(portReturns1,0)*sqrt(tDay);
figure; plot (portValue1); title('Cumulative returns, in sample');

% Back-ters OutSample
xBacktest = mat2cell(xOutSample', nFeatures, ones(size(xOutSample,1),1))';
yPredOutSample = classify(netAIX2,xBacktest);
plotconfusion(yOutSample,yPredOutSample)

yRetOutSample = dataset.retD1(idxOut,:);
signal2 = (1*(yPredOutSample == 'Buy')-0.5)*2;
portReturns2 = signal2(1:end-1).*yRetOutSample(2:end);
portValue2 = ret2tick(portReturns2);
sharpeRatio2 = sharpe(portReturns2,0)*sqrt(tDay)
figure; plot (portValue2); title('Cumulative returns, out of sample');
