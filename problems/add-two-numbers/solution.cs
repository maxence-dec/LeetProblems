public class Solution {
    public ListNode AddTwoNumbers(ListNode? l1, ListNode? l2, int i = 0){
        if(l1 == null && l2 == null && i == 0)
            return null;
        int val = (l1?.val??0) + (l2?.val??0) + i;
        return new ListNode(val%10, AddTwoNumbers(l1?.next, l2?.next, val/10));
    }
}