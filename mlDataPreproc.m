
function dataOut = mlDataPreproc(dataset)

% pre-processing of days
[dataset.Y, dataset.M, dataset.D] =  ymd(dataset.DateTime);
dataset.DoW =  day(dataset.DateTime,'dayofweek');
dayDiff =  diff(datenum(dataset.DateTime));
dataset.nNextTD= [dayDiff; NaN];
dataset.nprevTD= [NaN; dayDiff];

% pre-processing of raw price returns
dataset.retBar = dataset.Close - dataset.Open;
nDays = [1, 5, 10, 20];
for i=1:numel(nDays)
    factorName = ['retD' num2str(nDays(i))];
    dataset.(factorName) = RetNDays(dataset.AdjClose,nDays(i));    
end

% RSI factors
nDays = [7, 14, 21];
for i = 1:numel(nDays)
    factorName = ['rsiD' num2str(nDays(i))];
    dataset.(factorName) = rsindex(dataset.AdjClose,nDays(i));
end

% Trend Presence factor
dataset.MACD = macd(dataset.AdjClose);

% Volume Increase/Decrease Factor
volumes= dataset.Volume;
P95= (prctile(dataset.Volume,95)/10)*10;
P90= (prctile(dataset.Volume,90)/10)*10;
P10= (prctile(dataset.Volume,10)/10)*10;
P05= (prctile(dataset.Volume,5)/10)*10;
dataset.volPcn = zeros(numel(dataset.Volume),1);
dataset.volPcn(find(dataset.Volume<=P10))=-1;
dataset.volPcn(find(dataset.Volume<=P05))=-2;
dataset.volPcn(find(dataset.Volume>=P90))=1;
dataset.volPcn(find(dataset.Volume>=P95))=2;
groupsummary(dataset,'volPcn');

% Generate response variable (Y)
nextDayReturn = double(dataset.retD1(2:end) > 0);
response = categorical(nextDayReturn,[1,0],{'Buy', 'Sell'});
dataset.Response = [response; 'Buy'];
histogram(dataset.Response,{'Buy','Sell'});
title('Distribution of Response Variable');

% Split data into x (predictors) and y (response)
dataset = rmmissing(dataset);
dataset.Date= []; % Remove Date
dataset.DateTime = []; % Remove DateTime
dataset.AdjClose = []; % Remove prices
dataset.Close = []; % Remove Close
dataset.Open = []; % Remove Open
dataset.High = []; % Remove High
dataset.Low = []; % Remove Low

dataOut=dataset;

function returns=RetNDays(prices, nDay)
    % This function is to generate nDay return give the price vector
    returns = NaN(size(prices,1),1);
    returns(nDay+1:end) = prices(nDay+1:end) ./ prices(1:end-nDay) - 1;
end

function rsi = nDayRSI(prices, nDay)
% This function is to generate nDay RSI give the price vector
    returns = rsindex(prices,nDay);
    returns(nDay+1:end) = prices(nDay+1:end) ./ prices(1:end-nDay) - 1;
end

end
