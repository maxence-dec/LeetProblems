#include <stdio.h>
#include <stdlib.h>

int lengthOfLongestSubstring(char* s) {
    short alphabet[256];
    for(short i = 0; i < 256; i++) alphabet[i] = -1;

    int n = strlen(s);
    int lower = 0, maxLen = 0;

    for(int i = 0; i < n; i++){
        unsigned char ch = s[i];
        if(alphabet[ch] >= lower) lower = alphabet[ch]+1;
        alphabet[ch] = i;
        if(i-lower+1 > maxLen) maxLen = i-lower+1;
    }
    return maxLen;
}