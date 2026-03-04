public class Solution
{
    public bool IsIsomorphic(string s, string t)
    {
        Dictionary<char, char> StoT = new();
        Dictionary<char, char> TtoS = new();
        for (int idx = 0; idx < s.Length; idx++)
        {
            if (StoT.ContainsKey(s[idx]) && TtoS.ContainsKey(t[idx]))
            {
                if (StoT[s[idx]] == t[idx] && TtoS[t[idx]] == s[idx])
                    continue;
            }
            else if (!StoT.ContainsKey(s[idx]) && !TtoS.ContainsKey(t[idx]))
            {
                StoT[s[idx]] = t[idx];
                TtoS[t[idx]] = s[idx];
                continue;
            }
            return false;
        }
        return true;
    }
}

// refacto
public class Solution {
    public bool IsIsomorphic(string s, string t) {
        int[] StoT = new int[128];
        int[] TtoS = new int[128];
        for(int idx = 0; idx < s.Length; idx++)
        {
            if (StoT[s[idx]] == 0 && TtoS[t[idx]] == 0)
            {
                StoT[s[idx]] = t[idx];
                TtoS[t[idx]] = s[idx];
            }
            else if(StoT[s[idx]] != t[idx] || TtoS[t[idx]] != s[idx])
                return false;
        }
        return true;
    }
}