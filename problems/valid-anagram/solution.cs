public class Solution
{
    public bool IsAnagram(string s, string t)
    {
        Dictionary<char, int> myDic = new();
        if (s.Length != t.Length)
            return false;
        for (int idx = 0; idx < s.Length; idx++)
        {
            if (myDic.ContainsKey(s[idx]))
                myDic[s[idx]] += 1;
            else
                myDic[s[idx]] = 1;
            if (myDic.ContainsKey(t[idx]))
                myDic[t[idx]] += -1;
            else
                myDic[t[idx]] = -1;
        }
        foreach (int val in myDic.Values)
            if (val != 0)
                return false;
        return true;
    }
}

//fix array max size <=> implicite hashing
//solution https://leetcode.com/u/IU-Studies/
public class Solution
{
    public bool IsAnagram(string s, string t)
    {
        if (s.Length != t.Length)
            return false;
        int[] letterCpt = new int[26];

        for (int i = 0; i < s.Length; i++)
        {
            letterCpt[s[i] - 'a']++;
            letterCpt[t[i] - 'a']--;
        }

        foreach (int val in letterCpt)
            if (val != 0)
                return false;
        return true;
    }
}