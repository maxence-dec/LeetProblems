from copy import deepcopy

class sudokuCSP(object):
    def __init__(self, grille):
        #Objet sudoku ayant 2 variables:
        #   la grille du sudoku à remplire
        #   la grille des valeurs possibles pour chaques cases du sudoku
        #Associé sont les méthodes permettant de remplire
        #la grille et de la valider
        self.grille = deepcopy(grille)
        self.possibilites = [[[1,2,3,4,5,6,7,8,9] for _ in range(9)] for _ in range (9)]
        self.refreshPossibilites()
        

    def MRV(self):
        #Dans le grille des possibilités du sudoku,
        #   cherche la/les case(s) (variables) sans valeur assignée
        #   pouvant prendre le minimum de valeur differentes (valeurs légales)
        #Entrée:
        #Sortie:    liste de coordonnées [[ligne,colonne],...]
        max = 9
        coordonneesMRV = []
        for ligne in range (0,9):
            for colonne in range (0,9):
                if self.grille[ligne][colonne] == 0:
                    possibilite = len(self.possibilites[ligne][colonne])
                    if possibilite == max:
                        coordonneesMRV.append([ligne, colonne])
                    elif possibilite < max:
                        coordonneesMRV.clear()
                        coordonneesMRV.append([ligne, colonne])
                        max = possibilite
        return coordonneesMRV

    def degree_heur(self, coordonneesMRV):
        #Dans une list de coordonnées,
        #   cherche celle dont la détermination de la valeur aura
        #   la plus grande influence sur le reste de la grille de sudoku
        #   (plus grand nombre de contraintes sur les variables restantes)
        #Entrée:    liste de coordonnées [[ligne,colonne],...]
        #Sortie:    coordonnée [ligne,colonne]
        if len(coordonneesMRV) == 1: return coordonneesMRV[0]
        coordonneeHeuristique = []
        maxContrainte = 0
        for coordonnees in coordonneesMRV:
            ligne = coordonnees[0]
            colonne = coordonnees[1]
            possibilite = 0
            if ligne < 3:       I = [0,1,2]
            elif ligne < 6:     I = [3,4,5]
            elif ligne < 9:     I = [6,7,8]
            if colonne < 3:     J = [0,1,2]
            elif colonne < 6:   J = [3,4,5]
            elif colonne < 9:   J = [6,7,8]
            for i in I:
                for j in J:
                    if self.grille[i][j] == 0:
                        possibilite+=1
            for parcoursLignes in [x for x in range (9) if x not in I]:
                if self.grille[parcoursLignes][colonne] == 0:
                    possibilite+=1
            for parcoursColonne in [x for x in range (9) if x not in J]:
                if self.grille[ligne][parcoursColonne] == 0:
                    possibilite+=1
            possibilite+=-1
            if possibilite > maxContrainte:
                maxContrainte = possibilite
                coordonneeHeuristique = coordonnees
        return coordonneeHeuristique


    def LCV(self, coordonneeHeuristique):
        #Pour une coordonnée, 
        #   cherche elle qui réduit le moins les valeurs
        #   possibles des prochaines variables
        #Entrée:    coordonnée [ligne,colonne]
        #Sortie:    valeur (int)

        ligne = coordonneeHeuristique[0]
        colonne = coordonneeHeuristique[1]
        nbVariableAff = []
        for var in self.possibilites[ligne][colonne]:
            degreePossibilite = 0
            if ligne < 3:       I = [0,1,2]
            elif ligne < 6:     I = [3,4,5]
            elif ligne < 9:     I = [6,7,8]
            if colonne < 3:     J = [0,1,2]
            elif colonne < 6:   J = [3,4,5]
            elif colonne < 9:   J = [6,7,8]
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
        #Algorithme récursif:
        #   Propage les contraintes entre les cases et
        #   applique les resulata à la grille du sudoku et des possibilitées
        #   jusqu'à ce qu'aucune valeur ne puisse être déterminé
        flagChangement = False
        for ligne in range (0,9):
            for colonne in range (0,9):
                if self.grille[ligne][colonne] == 0:
                    if ligne < 3:       I = [0,1,2]
                    elif ligne < 6:     I = [3,4,5]
                    elif ligne < 9:     I = [6,7,8]
                    if colonne < 3:     J = [0,1,2]
                    elif colonne < 6:   J = [3,4,5]
                    elif colonne < 9:   J = [6,7,8]
                    for i in I:
                        for j in J:
                            if self.grille[i][j] in self.possibilites[ligne][colonne]:
                                self.possibilites[ligne][colonne].remove(self.grille[i][j])
                                flagChangement = True
                    for parcoursLignes in range (0,9):
                        if self.grille[parcoursLignes][colonne] in self.possibilites[ligne][colonne]:
                            self.possibilites[ligne][colonne].remove(self.grille[parcoursLignes][colonne])
                            flagChangement = True
                    for parcoursColonne in range (0,9):
                        if self.grille[ligne][parcoursColonne] in self.possibilites[ligne][colonne]:
                            self.possibilites[ligne][colonne].remove(self.grille[ligne][parcoursColonne])
                            flagChangement = True
        if flagChangement:
            self.refreshGrille()
            return self.AC3()
        return

    def refreshGrille(self):
        #Met à jour les valeur dans le sudoku en fonction
        #des valeurs possibles
        for ligne in range (0,9):
            for colonne in range (0,9):
                if len(self.possibilites[ligne][colonne]) == 1:
                    self.grille[ligne][colonne] = self.possibilites[ligne][colonne][0]
        return

    def refreshPossibilites(self):
        #Met à jour les valeur possibles en fonction
        #des valeurs dans le sudoku
        for ligne in range (0,9):
            for colonne in range (0,9):
                if self.grille[ligne][colonne] !=0:
                    self.possibilites[ligne][colonne]=[self.grille[ligne][colonne]]
        return
    
    def isComplete(self):
        #Verifie si toutes les valeurs de la grille
        #ont été déterminé
        #Sortie: vrais si la grille est complete (bool)
        for ligne in range (0,9):
            for colonne in range (0,9):
                if self.grille[ligne][colonne] == 0: return False
        return True

    def setValueGrille(self, coordonnee, val):
        #Force une valeur dans le grille
        #met à jour les possibilitées en conséquence
        #Enrtée:    coordonnées [ligne,colonne]
        #           valeur (int)
        self.grille[coordonnee[0]][coordonnee[1]] = val
        self.refreshPossibilites()
        return

    def delPossibilite(self, coordonnee, val):
        #Supprime une valeur dans les possibilitées
        #met à jour la grille en conséquence
        #Enrtée:    coordonnées [ligne,colonne]
        #           valeur (int)
        self.possibilites[coordonnee[0]][coordonnee[1]].remove(val)
        self.refreshGrille()
        return

    def isFalse(self):
        #Verifie si les valeur dans la grille
        #respectent les règles du sudoku
        #Sortie:    vrais si les règles sont PAS respectées (bool)
        possibilitesParCase = [[[1,2,3,4,5,6,7,8,9]*3 for _ in range(9)] for _ in range (9)]
        for ligne in range (0,9):
            for colonne in range (0,9):
                if ligne < 3:       I = [0,1,2]
                elif ligne < 6:     I = [3,4,5]
                elif ligne < 9:     I = [6,7,8]
                if colonne < 3:     J = [0,1,2]
                elif colonne < 6:   J = [3,4,5]
                elif colonne < 9:   J = [6,7,8]
                for i in I:
                    for j in J:
                        temp = self.grille[i][j]
                        if temp != 0:
                            if temp in possibilitesParCase[ligne][colonne]:
                                possibilitesParCase[ligne][colonne].remove(temp)
                            else:
                                return True
                for parcoursLignes in [x for x in range (9) if x not in I]:
                    temp = self.grille[parcoursLignes][colonne]
                    if temp != 0:
                        if temp in possibilitesParCase[ligne][colonne]:
                            possibilitesParCase[ligne][colonne].remove(temp)
                        else:
                            return True
                for parcoursColonne in [x for x in range (9) if x not in J]:
                    temp = self.grille[ligne][parcoursColonne]
                    if temp != 0:
                        if temp in possibilitesParCase[ligne][colonne]:
                            possibilitesParCase[ligne][colonne].remove(temp)
                        else:
                            return True
        return False