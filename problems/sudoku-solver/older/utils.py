"""
Documentation et lien utils
https://sudokusolver.app/
#https://youtu.be/C56Q5qE6G_k
#https://youtu.be/Ta6nLVwBS5w?list=PLl3CtU4THqPajnTLZnJOP-qKJWCK6OzS7
https://nsi.xyz/projets/solveur-de-sudoku-en-python/
https://python.doctor/page-apprendre-dictionnaire-python
"""
def afficher_grille_sodoku(grille) :
    """
    Permettre d'afficher une grille, les elements de la liste
    :param grille: Liste de Liste
    :return: None
    """
    indice_alpha = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i']
    print("    1 2 3   4 5 6   7 8 9   ")

    for indice_ligne, ligne in enumerate(grille) :
        if indice_ligne % 3 == 0 :
            print(" ", ('+'+'-'*7)*3 + '+')
        print(indice_alpha[indice_ligne], end=" ")
        for indice_col in range(len(ligne)):
            if indice_col % 3 ==0 :
                print('|', end=" ")
            print(ligne[indice_col], end=" ")
        print('|')
    print(" ", ('+' + '-' * 7) * 3 + '+')

def convertir_chaine_grille(chaine_sodoku) :
    """
    La fonction converti une chaine 81 element en une liste de liste ou grille
    :param chaine:
    :return:
     -un boolean
     -Une grille
    """
    if len(chaine_sodoku) !=81 :
        return False, None

    grille_sodoku = []
    ligne = []

    for indice, element in enumerate(chaine_sodoku) :
        ligne.append(int(element))

        if (indice + 1) % 9 ==0 :
            grille_sodoku.append(ligne)
            ligne = []
    return True, grille_sodoku

def ajouter_sodoku() :
    """
    description: La fonction recuperer une entree utilisateur qui est la chaine a 81 element
    :return: conerti et la grille
    """
    chaine_saisi = input()
    converti, grilleConvert = convertir_chaine_grille(chaine_saisi)
    if converti:
        afficher_grille_sodoku(grilleConvert)
    else:
        print("Erreur de convertion")
    return converti, grilleConvert