int maxProfit(int* prices, int pricesSize) {
    int profit = 0, lowerBound = 0, upperBound;

    for(upperBound = 1; upperBound < pricesSize; upperBound++){
        if(prices[upperBound] < prices[lowerBound])
            lowerBound = upperBound;
        else if(prices[upperBound] - prices[lowerBound] > profit)
            profit = prices[upperBound] - prices[lowerBound];
    }
    return profit;
}