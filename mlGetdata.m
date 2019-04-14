% Get data from Yahoo

function X =mlGetdata(sCode)

Y10=3000; % 10 yeras = 3652
stocks = hist_stock_data(now-Y10, now, {sCode});
stocks=rmfield(stocks,'Ticker');
dataset = struct2table(stocks);
dataset.DateTime = datetime(dataset.Date);

X= dataset;
end