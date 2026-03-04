bool inBound(char c){ return c > 47 && c < 58 || c > 64 && c < 91; }
bool isPalindrome(char* s) {
    int lower = 0, upper = strlen(s)-1;
    while(lower <= upper){
        if(s[lower]>96) s[lower]-=32;
        if(s[upper]>96) s[upper]-=32;
        if(!inBound(s[lower]))
            lower++;
        else if(!inBound(s[upper]))
            upper--;
        else if (s[lower] != s[upper])
            return false;
        else{ lower++; upper--; }
    }
    return true;
}