# ELC2D – Extraction de Linéaments Curvilignes 2D
**Une interface MATLAB pour l’extraction 2D de linéaments curvilignes**

### À quoi sert ce dépôt ?
ELC2D est une interface MATLAB destinée à l’extraction de linéaments curvilignes en 2D. Elle s’appuie sur des techniques avancées de séparation de sources non supervisée, incluant l’Analyse en Composantes Principales (ACP), les Transformées en Ondelettes Continues 2D (TOC) et l’optimisation bayésienne, afin de proposer une solution complète pour l’analyse et l’extraction de linéaments dans les données géophysiques et géoscientifiques.

**Veuillez citer le logiciel comme suit (version anglaise de référence) :**
> Abbassi, B. (2024). CLE2D: Curvilinear Lineament Extraction: Bayesian Optimization of Principal Component Wavelet Analysis and Hysteresis Thresholding. GitHub. https://github.com/bahmanabbassi/CLE2D

---

### Configuration et exécution
* **Matériel :** Ce programme est conçu pour fonctionner sur tout ordinateur personnel sous Windows disposant d’au moins 8 Go de RAM. L’augmentation de la mémoire permet de traiter des images plus grandes en une seule fois. Comme le programme manipule de grandes matrices, la vitesse de lecture/écriture du disque est également importante. Un disque SSD NVMe est recommandé.
* **Logiciel :** ELC2D est fourni sous forme de fichiers MATLAB (`.p` et `.mlapp`). Il nécessite **MATLAB 2024a (version 24.1) ou ultérieure**.

**Boîtes à outils MATLAB requises :**
* Statistics and Machine Learning Toolbox
* Wavelet Toolbox
* Optimization Toolbox

**Installation :**
1. Copiez le dossier du dépôt (fichiers MATLAB et jeux de données) dans le répertoire de votre choix.
2. Dans MATLAB, placez le dossier d’ELC2D dans le **Current Folder**.
3. Lancez l’interface en tapant `ELC2D` dans la fenêtre de commande MATLAB.

L’interface ELC2D offre un ensemble complet d’outils pour l’extraction de linéaments curvilignes, avec une ergonomie adaptée aux utilisateurs francophones.

---

### Dépendances et remerciements
Ce projet utilise certains composants de **Yet Another Wavelet Toolbox (YAWTB)**, copyright (C) 2001‑2002 par l’équipe YAWTB. Les en‑têtes de licence originaux ont été conservés dans les fichiers concernés, conformément aux conditions d’utilisation de YAWTB. [YAWTB GitHub](https://github.com/jacquesdurden/yawtb).

**ELC2D utilise également :**
* Une implémentation MATLAB de **PCA / ICA** (dont `fastICA.m`) développée par Brian Moore :
  *Brian Moore (2026). PCA and ICA Package, MATLAB Central File Exchange. Consulté le 16 mars 2026.* [Lien](https://www.mathworks.com/matlabcentral/fileexchange/38300-pca-and-ica-package)
* Un code de **détection de failles géologiques** (hysteresis thresholding / step filtering) développé par Costas Panagiotakis :
  *Costas Panagiotakis (2026). Detection of Geological Faults, MATLAB Central File Exchange. Consulté le 16 mars 2026.* [Lien](https://www.mathworks.com/matlabcentral/fileexchange/64693-detection-of-geological-faults)

*Note : Nous recommandons, en plus de citer CLE2D/ELC2D, d’inclure ces références lorsque les modules PCA/ICA, détection de failles ou ondelettes de YAWTB sont explicitement utilisés.*

---

### Utilisation de l’interface
L’interface ELC2D comporte plusieurs fenêtres et fonctionnalités principales, résumées ci‑dessous.

#### Coordonnées & Espacement
* **Max / Min Lat & Lon :** Définir les limites géographiques.
* **Méthode :** Choisir la méthode de saisie des coordonnées. Les coordonnées peuvent être lues à partir d’un fichier texte préparé (Min Lon, Max Lon, Min Lat, Max Lat).
* **Espacement :** Définir la valeur d’espacement en secondes d’arc. Au Québec, chaque seconde d’arc de latitude correspond à environ 33 mètres, et chaque seconde d’arc de longitude à environ 17 mètres. Le programme ajuste automatiquement ces rapports à l'échelle mondiale.
* **Filtre :** Appliquer un filtre de lissage aux données d’entrée.

#### Données d’entrée & Linéaments numérisés
* **Interpolation 2D :** Sélectionner la méthode d’interpolation pour les points (réguliers ou irréguliers).
* **Xn / Yn :** Récupérer le nombre de pixels en X et Y après interpolation.
* **Type de cibles :** Choisir les cibles (failles numérisées) sous forme de données `.csv` ou d’images.
* **Seuil 1 & 2 :** Ajuster les valeurs de coupure pour définir ou affiner une zone tampon autour des linéaments.

#### Extraction des caractéristiques spectrales
1. **TOC 2D :** Décompose les entrées en caractéristiques spectrales brutes. Ajustez le nombre d’échelles (`na`), la dilatation et les angles. Des ondelettes mères isotropes et anisotropes sont disponibles.
2. **ACPS (ACP Spectrale) :** Utilisée pour la séparation spectrale des sources.
   * **RLCO :** Ratio de lissage des coefficients d’ondelettes pour éviter les artefacts d’interpolation.
   * **β :** Angle de symétrie pour la TOC.

#### Extraction des linéaments
* **Résolution des lignes :** Des résolutions plus élevées donnent des résultats plus nets au prix d’un coût de calcul plus important.
* **FÉ # d’angles :** Nombre d’angles utilisés pour calculer l’Aspect dans le seuillage par hystérèse.
* **MaxIter Opt Bayésienne :** Nombre maximal d’itérations pour le réglage.
* **w & VLFÉ :** Contrôle la largeur du filtre en marches et sa variabilité selon la complexité spectrale.
* **AutoLigne :** Affiner automatiquement les hyperparamètres (`na`, `WSFR`, `DR`, `w` et `VSFW`).

#### Tracer (Plot)
* **Tracer les résultats :** Afficher les résultats.
* **Filtre :** Appliquer un filtre sur les résultats tracés.
* **Fermer / Effacer tout :** Réinitialiser l'espace de travail.

---

### Formats d’entrée / sortie
ELC2D prend en charge des données d’entrée au format `.csv` de type XYZ :
* **Colonne X :** Longitudes
* **Colonne Y :** Latitudes
* **Colonne Z :** Valeurs de l’image géoscientifique (réflectance, intensité magnétique, etc.).

Les sorties générées par ELC2D sont principalement au format MATLAB `.fig` (caractéristiques spectrales extraites et linéaments curvilignes détectés), permettant une visualisation directe dans MATLAB.

---

### Contact & Licence
**Développeur principal :** Bahman Abbassi (bahman.abbassi@uqat.ca)
**Chercheur principal :** Li-Zhen Cheng
**Affiliation :** Institut de Recherche en Mines et en Environnement (IRME), Université du Québec en Abitibi-Témiscamingue (UQAT)

Ce programme est un logiciel libre : vous pouvez le redistribuer et/ou le modifier selon les termes de la **Licence Publique Générale GNU (v3 ou ultérieure)** telle que publiée par la Free Software Foundation. Ce programme est distribué dans l’espoir qu’il sera utile, mais SANS AUCUNE GARANTIE. Voir la [Licence Publique Générale GNU](https://www.gnu.org/licenses/) pour plus de détails.
