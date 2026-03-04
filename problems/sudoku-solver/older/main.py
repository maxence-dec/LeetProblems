import utils as uti
import CSP as csp
import backtracking as bt

if __name__ == '__main__':
    print('SODOKU')

    #https://sudokusolver.app/ => "new" => "generate" => "export" => copier dans "chaine_sudoku"
    #   "analyse" donne le nombre de solution
    chaine_sudoku = '000000000000000000000000000000000000000000000000000000000000000000000000000000000'

    #Sudoku: facil | 1 solution
    #chaine_sudoku = '000351000001060003000809071807010400300600005100200960679000080000000206005486000'

    #Sudoku: moyen | 1 solution
    #chaine_sudoku = '060000070794010500800740002040000035520000700078603004400060001007030000050400800'

    #Sudoku: difficil | 1 solution
    #chaine_sudoku = '300069400900040000008070009000010508580700000000000060002006000603020804049800010'

    #Sudoku: difficil | 11 solution
    #chaine_sudoku = '000069400900040000008070009000010508580700000000000060002006000603020804049800010'

    #Sudoku: _ | 0 solution
    #chaine_sudoku = '300069400900040000008070009000010508580700000000000060002006000603020804049800016'

    converti, grilleConvert = uti.convertir_chaine_grille(chaine_sudoku)

    if converti:
        sdk = csp.sudokuCSP(grilleConvert)
        print("Sodoku de départ")
        uti.afficher_grille_sodoku(sdk.grille)

        flagResolu = bt.backtrackingStart(sdk)

        if flagResolu:
            print("Sodoku Final")
            uti.afficher_grille_sodoku(sdk.grille)
        else:
            print("Sodoku Non resolu")

    else :
        print("Erreur de convertion")