bool isSubsequence(char* s, char* t) {
    int cptS = 0;
    int tLen = strlen(t);
    for(int i = 0; i < tLen; i++)
        if(s[cptS] == t[i]) cptS++;

    return cptS == strlen(s);
}