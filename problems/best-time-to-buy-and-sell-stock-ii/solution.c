int maxProfit(int* prices, int pricesSize) {
    int profit = 0, lowerBound = 0, upperBound;

    while(lowerBound < pricesSize){
        while(lowerBound + 1 < pricesSize && prices[lowerBound] > prices[lowerBound+1])
            lowerBound++;
        upperBound = lowerBound;
        while(upperBound + 1 < pricesSize && prices[upperBound] < prices[upperBound+1])
            upperBound++;
        if(prices[upperBound] - prices[lowerBound] > 0 )
            profit += prices[upperBound] - prices[lowerBound];
        lowerBound = ++upperBound;
    }
    return profit;
}