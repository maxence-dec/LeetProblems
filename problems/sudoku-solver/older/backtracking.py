import CSP as csp

def backtrackingRecurssif(sudoku, coordonnee, val):
    #Place dans un sudoku une valeur donné
    #   Verifie si cette valeur est licite
    #   Cherche à resoudre le sudoku avec cette valeur
    #   Au besoin, choisi de nouvelles valeurs pour d'autres cases et relance la récursion
    #   Retourne: si la valeur a permis de resoudre le sudoku et, le cas échéant,
    #   le grille terminée.
    #Entrée:    objet sudoku
    #           coordonnee [ligne,colonne]
    #           valeur (int)
    #Sortie:    vrais si le sudoku est terminé (bool)
    #           objet sudoku avec sa grille complété / None
    sudokuWIP = csp.sudokuCSP(sudoku.grille)
    if coordonnee != None and val != None:
        sudokuWIP.setValueGrille(coordonnee, val)
        sudokuWIP.AC3()
        if sudokuWIP.isFalse():     return False, None
        if sudokuWIP.isComplete():  return True, sudokuWIP

    while 1:
        coordonneesMRV = sudokuWIP.MRV()
        coordonneeHeuristique = sudokuWIP.degree_heur(coordonneesMRV)
        if coordonneeHeuristique == []:return False, None
        else:
            if sudokuWIP.possibilites[coordonneeHeuristique[0]][coordonneeHeuristique[1]] == []:return False, None
            lcv = sudokuWIP.LCV(coordonneeHeuristique)

            sudokuWIP.delPossibilite(coordonneeHeuristique, lcv)
            flagFini, sudokuFinal = backtrackingRecurssif(sudokuWIP, coordonneeHeuristique, lcv)
            sudokuWIP.setValueGrille(coordonneeHeuristique, 0)
            if flagFini:
                return True, sudokuFinal

def backtrackingStart(sudoku):
    #Cherche a resoudre le sudoku avec AC3 puis,
    #si nécessaire, lance la backtracking.
    #Enrtée: objet sudoku
    #Sortie: vrais si le sudoku est résolu (bool)
    print("Recherche de solition")
    sudoku.AC3()
    if sudoku.isFalse():
        print("Erreur: le sudoku donné est incorrect")
        return False
    if sudoku.isComplete():
        print("Sudoku résolu")
        return True
    else:
        print("Démarage backtracking")
        flag, sudokuFinal = backtrackingRecurssif(sudoku, None, None)
        if flag:
            sudoku.grille = sudokuFinal.grille
            print("Sudoku résolu")
            return True
        else:
            print("Le sudoku n'a pas de solution")
            return False
