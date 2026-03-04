#include <cstddef>
void pushSort(int* citations, int idxAt, int* hLimAt){
    for(int idx = 0; idx <= *hLimAt; idx++){
        if(citations[idx] < citations[idxAt]){
            int tempo = citations[idx];
            citations[idx] = citations[idxAt];
            citations[idxAt] = tempo;
        }
    }
    if(citations[*hLimAt] > *hLimAt) (*hLimAt)++;

    return;
}

int hIndex(int* citations, int citationsSize) {
    int hLim = 0;

    for(int idx = 0; idx < citationsSize; idx ++)
        if(citations[idx] > hLim) pushSort(citations, idx, &hLim);
    return hLim;
}

// v2 bucket sort
int hIndex(int* citations, int citationsSize) {
    int* bucket = (int*)calloc(citationsSize+1, sizeof(int));
    for(int i = 0; i < citationsSize; i++)
        bucket[citations[i] >= citationsSize? citationsSize : citations[i]]++;

    int cptH = 0;
    for(int j = citationsSize; j >= 0; j--){
        cptH += bucket[j];
        if(cptH>=j) return j;
    }
    free(bucket);
    bucket = NULL;
    return 0;
}