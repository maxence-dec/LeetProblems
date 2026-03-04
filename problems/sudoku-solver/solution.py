from copy import deepcopy

default0 = "."


class sudokuCSP(object):
    def __init__(self, grille):
        self.grille = deepcopy(grille)
        self.possibilites = [
            [["1", "2", "3", "4", "5", "6", "7", "8", "9"] for _ in range(9)]
            for _ in range(9)
        ]
        self.refreshPossibilites()

    def MRV(self):
        _max = 9
        coordonneesMRV = []
        for ligne in range(0, 9):
            for colonne in range(0, 9):
                if self.grille[ligne][colonne] == default0:
                    possibilite = len(self.possibilites[ligne][colonne])
                    if possibilite == _max:
                        coordonneesMRV.append([ligne, colonne])
                    elif possibilite < _max:
                        coordonneesMRV = []
                        coordonneesMRV.append([ligne, colonne])
                        _max = possibilite
        return coordonneesMRV

    def degree_heur(self, coordonneesMRV):
        if len(coordonneesMRV) == 1:
            return coordonneesMRV[0]
        coordonneeHeuristique = []
        maxContrainte = 0
        for coordonnees in coordonneesMRV:
            ligne = coordonnees[0]
            colonne = coordonnees[1]
            possibilite = 0
            if ligne < 3:
                I = [0, 1, 2]
            elif ligne < 6:
                I = [3, 4, 5]
            elif ligne < 9:
                I = [6, 7, 8]
            if colonne < 3:
                J = [0, 1, 2]
            elif colonne < 6:
                J = [3, 4, 5]
            elif colonne < 9:
                J = [6, 7, 8]
            for i in I:
                for j in J:
                    if self.grille[i][j] == default0:
                        possibilite += 1
            for parcoursLignes in [x for x in range(9) if x not in I]:
                if self.grille[parcoursLignes][colonne] == default0:
                    possibilite += 1
            for parcoursColonne in [x for x in range(9) if x not in J]:
                if self.grille[ligne][parcoursColonne] == default0:
                    possibilite += 1
            possibilite += -1
            if possibilite > maxContrainte:
                maxContrainte = possibilite
                coordonneeHeuristique = coordonnees
        return coordonneeHeuristique

    def LCV(self, coordonneeHeuristique):
        ligne = coordonneeHeuristique[0]
        colonne = coordonneeHeuristique[1]
        nbVariableAff = []
        for var in self.possibilites[ligne][colonne]:
            degreePossibilite = 0
            if ligne < 3:
                I = [0, 1, 2]
            elif ligne < 6:
                I = [3, 4, 5]
            elif ligne < 9:
                I = [6, 7, 8]
            if colonne < 3:
                J = [0, 1, 2]
            elif colonne < 6:
                J = [3, 4, 5]
            elif colonne < 9:
                J = [6, 7, 8]
            for i in I:
                for j in J:
                    degreePossibilite += self.possibilites[i][j].count(var)
            for j in range(0, 9):
                if j not in I:
                    degreePossibilite += self.possibilites[ligne][j].count(var)
                if j not in J:
                    degreePossibilite += self.possibilites[j][colonne].count(var)
            nbVariableAff.append([var, degreePossibilite])
        lcv, _ = min(nbVariableAff, key=lambda item: item[1])
        return lcv

    def AC3(self):
        flagChangement = False
        for ligne in range(0, 9):
            for colonne in range(0, 9):
                if self.grille[ligne][colonne] == default0:
                    if ligne < 3:
                        I = [0, 1, 2]
                    elif ligne < 6:
                        I = [3, 4, 5]
                    elif ligne < 9:
                        I = [6, 7, 8]
                    if colonne < 3:
                        J = [0, 1, 2]
                    elif colonne < 6:
                        J = [3, 4, 5]
                    elif colonne < 9:
                        J = [6, 7, 8]
                    for i in I:
                        for j in J:
                            if self.grille[i][j] in self.possibilites[ligne][colonne]:
                                self.possibilites[ligne][colonne].remove(
                                    self.grille[i][j]
                                )
                                flagChangement = True
                    for parcoursLignes in range(0, 9):
                        if (
                            self.grille[parcoursLignes][colonne]
                            in self.possibilites[ligne][colonne]
                        ):
                            self.possibilites[ligne][colonne].remove(
                                self.grille[parcoursLignes][colonne]
                            )
                            flagChangement = True
                    for parcoursColonne in range(0, 9):
                        if (
                            self.grille[ligne][parcoursColonne]
                            in self.possibilites[ligne][colonne]
                        ):
                            self.possibilites[ligne][colonne].remove(
                                self.grille[ligne][parcoursColonne]
                            )
                            flagChangement = True
        if flagChangement:
            self.refreshGrille()
            return self.AC3()

    def refreshGrille(self):
        for ligne in range(0, 9):
            for colonne in range(0, 9):
                if len(self.possibilites[ligne][colonne]) == 1:
                    self.grille[ligne][colonne] = self.possibilites[ligne][colonne][0]

    def refreshPossibilites(self):
        for ligne in range(0, 9):
            for colonne in range(0, 9):
                if self.grille[ligne][colonne] != default0:
                    self.possibilites[ligne][colonne] = [self.grille[ligne][colonne]]

    def isComplete(self):
        for ligne in range(0, 9):
            for colonne in range(0, 9):
                if self.grille[ligne][colonne] == default0:
                    return False
        return True

    def setValueGrille(self, coordonnee, val):
        self.grille[coordonnee[0]][coordonnee[1]] = val
        self.refreshPossibilites()

    def delPossibilite(self, coordonnee, val):
        self.possibilites[coordonnee[0]][coordonnee[1]].remove(val)
        self.refreshGrille()

    def isFalse(self):
        possibilitesParCase = [
            [["1", "2", "3", "4", "5", "6", "7", "8", "9"] * 3 for _ in range(9)]
            for _ in range(9)
        ]
        for ligne in range(0, 9):
            for colonne in range(0, 9):
                if ligne < 3:
                    I = [0, 1, 2]
                elif ligne < 6:
                    I = [3, 4, 5]
                elif ligne < 9:
                    I = [6, 7, 8]
                if colonne < 3:
                    J = [0, 1, 2]
                elif colonne < 6:
                    J = [3, 4, 5]
                elif colonne < 9:
                    J = [6, 7, 8]
                for i in I:
                    for j in J:
                        temp = self.grille[i][j]
                        if temp != default0:
                            if temp in possibilitesParCase[ligne][colonne]:
                                possibilitesParCase[ligne][colonne].remove(temp)
                            else:
                                return True
                for parcoursLignes in [x for x in range(9) if x not in I]:
                    temp = self.grille[parcoursLignes][colonne]
                    if temp != default0:
                        if temp in possibilitesParCase[ligne][colonne]:
                            possibilitesParCase[ligne][colonne].remove(temp)
                        else:
                            return True
                for parcoursColonne in [x for x in range(9) if x not in J]:
                    temp = self.grille[ligne][parcoursColonne]
                    if temp != default0:
                        if temp in possibilitesParCase[ligne][colonne]:
                            possibilitesParCase[ligne][colonne].remove(temp)
                        else:
                            return True
        return False


def backtrackingRecurssif(sudoku, coordonnee, val):
    sudokuWIP = sudokuCSP(sudoku.grille)
    if coordonnee != None and val != None:
        sudokuWIP.setValueGrille(coordonnee, val)
        sudokuWIP.AC3()
        if sudokuWIP.isFalse():
            return False, None
        if sudokuWIP.isComplete():
            return True, sudokuWIP

    while 1:
        coordonneesMRV = sudokuWIP.MRV()
        coordonneeHeuristique = sudokuWIP.degree_heur(coordonneesMRV)
        if coordonneeHeuristique == []:
            return False, None
        else:
            if (
                sudokuWIP.possibilites[coordonneeHeuristique[0]][
                    coordonneeHeuristique[1]
                ]
                == []
            ):
                return False, None
            lcv = sudokuWIP.LCV(coordonneeHeuristique)

            sudokuWIP.delPossibilite(coordonneeHeuristique, lcv)
            flagFini, sudokuFinal = backtrackingRecurssif(
                sudokuWIP, coordonneeHeuristique, lcv
            )
            sudokuWIP.setValueGrille(coordonneeHeuristique, default0)
            if flagFini:
                return True, sudokuFinal


def backtrackingStart(sudoku):
    sudoku.AC3()
    if sudoku.isComplete():
        return

    flag, sudokuFinal = backtrackingRecurssif(sudoku, None, None)
    if flag:
        sudoku.grille = sudokuFinal.grille


def copyToBoard(board, grille):
    for ligne in range(0, 9):
        for colonne in range(0, 9):
            board[ligne][colonne] = grille[ligne][colonne]


class Solution(object):
    def solveSudoku(self, board):
        sdk = sudokuCSP(board)
        backtrackingStart(sdk)
        copyToBoard(board, sdk.grille)
