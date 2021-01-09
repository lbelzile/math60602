# Inspiré de https://towardsdatascience.com/factor-analysis-a-complete-tutorial-1b7621890e42
# Documentation: https://factor-analyzer.readthedocs.io/en/latest/index.html
# Importer les librairies requises
import pandas as pd
import pingouin as pg
import matplotlib.pyplot as plt

from factor_analyzer import FactorAnalyzer
df = pd.read_csv('https://github.com/lbelzile/math60602/raw/master/data/factor2.csv')

# Créer un object Factor et faire l'analyse en commençant par le choix du nb de facteurs
fa = FactorAnalyzer(n_factors=12, method='principal', use_corr_matrix = True)
fa.fit(df)
# Critère de Kaiser: nb de facteurs = nb de valeurs propres > 1
ev, v = fa.get_eigenvalues()
# Ici, quatre valeurs propres
# Diagramme d'éboulis avec matplotlib
plt.scatter(range(1,df.shape[1]+1),ev)
plt.plot(range(1,df.shape[1]+1),ev)
plt.title("Diagramme d'éboulis")
plt.xlabel("Nombre de facteurs")
plt.ylabel("Valeurs propres")
plt.grid()
plt.show()

# Analyse factorielle avec object "facteur"
fa = FactorAnalyzer(n_factors=4, method='ml', rotation='varimax', use_corr_matrix = True)
fa.fit(df)
# Chargements
loads = fa.loadings_
print(loads)

# Variance de chaque facteur
fa.get_factor_variance()
# Communalités
fa.get_communalities()

#Création d'échelles
echelle1 = df[['x4', 'x8', 'x11']] #service
echelle2 = df[['x3', 'x6', 'x9', 'x12']] #produit
echelle3 = df[['x2', 'x7', 'x10']] #paiement
echelle4 = df[['x1', 'x5']] #prix
#Vérifier la cohérence interne avec le alpha de Cronbach
echelle1_alpha = pg.cronbach_alpha(echelle1)
echelle2_alpha = pg.cronbach_alpha(echelle2)
echelle3_alpha = pg.cronbach_alpha(echelle3)
echelle4_alpha = pg.cronbach_alpha(echelle4)
print(echelle1_alpha, echelle2_alpha, echelle3_alpha, echelle4_alpha)

