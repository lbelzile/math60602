# https://lifelines.readthedocs.io/en/latest/Survival%20Analysis%20intro.html

# Importer les librairies requises
import pandas as pd
import lifelines as life
import matplotlib.pyplot as plt
# Imprimer les graphiques en mode non-interactif
plt.show(block=True)

# Charger la base de données
bd = pd.read_csv('https://lbelzile.bitbucket.io/MATH60602/survival1.csv')


# Estimateur de Kaplan-Meier
from lifelines import KaplanMeierFitter
kmf = KaplanMeierFitter()
kmf.fit(bd["T"], event_observed=bd["censure"])
# Tracer la fonction de survie estimée
plt.title('Fonction de survie des abonnements cellulaires');
kmf.plot_survival_function()

# Calcul des quartiles
kmf.percentile([0.25, 0.5, 0.75])
