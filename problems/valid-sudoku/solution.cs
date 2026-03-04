public class Solution {

    private static bool CheckValide(char[][] board, int rowValue, int columnValue){
        for(byte cursor = 0; cursor < 9; cursor++)
        {
            if(cursor != rowValue && board[cursor][columnValue] == board[rowValue][columnValue]
                || cursor != columnValue && board[rowValue][cursor] == board[rowValue][columnValue])
                return false;
        }

        int[] smallRows = rowValue < 3? [0,1,2] : rowValue < 6 ? [3,4,5] : [6,7,8];
        int[] smallColumns = columnValue < 3? [0,1,2] : columnValue < 6 ? [3,4,5] : [6,7,8];

        foreach(int smallRow in smallRows)
            foreach(int smallColumn in smallColumns)
                if(smallRow != rowValue && smallColumn != columnValue && board[smallRow][smallColumn] == board[rowValue][columnValue])
                    return false;

        return true;
    }

    public bool IsValidSudoku(char[][] board) {
        for(byte row = 0; row < 9; row++)
        {
            for(byte column = 0; column < 9; column++)
            {
                if(board[row][column] != '.')
                {
                    if(!CheckValide(board, row, column))
                        return false;
                }
            }
        }
        return true;
    }
}