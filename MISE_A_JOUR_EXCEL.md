# Mise a jour depuis Excel

## Principe et colonnes

Lors d'une mise a jour depuis la feuille `accords` de `accords.xlsx`, regenerer `agreementRows` de `negos_html_files/negos-cgt-2023-2026.html` dans l'ordre d'Excel, en appariant les lignes par annee, site et titre.

Les colonnes sont reperees par leur **en-tete**, jamais par leur lettre (l'ordre change). Le classeur est ouvert depuis SharePoint : le fichier local peut etre en retard sur le dernier enregistrement, lire de preference le classeur ouvert dans Excel.

| En-tete Excel | Champ index | Regle |
|---|---|---|
| `année`, `site` | `year`, `site` | |
| `Accord ou négociation` | `title` | Titre court, objet seul ; ajouter l'annee quand un objet se repete (NAO, RCC, amenagement du temps de travail). |
| `URL accord`, `file name accord`, `page signature` | `documents[]` | Meme forme que les tracts : `{ "title", "url", "signatureTarget" }`. `title` est le nom exact du fichier. Plusieurs URLs separees par `, ` donnent plusieurs objets, dans le meme ordre que les noms de fichier. Vide = `[]`. `signatureTarget` reprend l'URL SharePoint de `page signature` ; omis s'il n'y a pas de capture. Pas de `%2F` dans le chemin. |
| `date VF` | `finalVersionDate` | Date finale lue dans le PDF (signature, validation ou page de garde), au format `jj/mm/aaaa`. Vide = `-`. |
| `accord majoritaire` | `accord` | `TRUE` = `accord` ; `FALSE` = `Pas d'accord` ; toute autre valeur (`À vérifier`) = `À vérifier`. Un pas d'accord reste un PV : le PDF est celui du PV, et les signatures confirmees ainsi que `signatureTarget` sont quand meme repris s'ils sont renseignes. |
| `CGT`, `CFDT`, `CFE-CGC`, `CFTC` | `signatures` | Liste des organisations confirmees : `cgt`, `cfdt`, `cfe`, `cftc`. Seul `TRUE` entre dans la liste, y compris pour un `Pas d'accord`. `FALSE`, `À vérifier` et `-` restent dehors. Aucune signature confirmee = `[]`. |
| — | `tags` | Derive du titre, du site et de l'annee. NAO ou interessement = `#salaires`. RCC = `#effectifs`. Amenagement du temps de travail = `#rtt`. Site = `#nnf`, `#nps` ou `#lan`. Annee = `#2023`, `#2024`, `#2025`, `#2026` (ou l'annee reelle de la ligne). |
| `Source signatures` | `signatureSource` | Preferer `p.X : signatures de...` en nommant les organisations visibles et toute absence. Signaler une version non signee. PV de désaccord : `PV de désaccord valide unilatéralement ; aucun accord collectif n’a été signé.` |
| `Summary` | `content` | Resume court affiche dans l'index. |
| `Position CGT` | `cgtPosition` | Affiche juste apres le resume, prefixe « Position CGT : ». Vide = ligne non affichee. |
| `tract associé` | `tract[].title` | Titre du tract. Plusieurs tracts : un titre par ligne, dans l'ordre des URLs. |
| `URL tract` | `tract[].url` | URL absolue et encodee. `-` = pas de tract (`tract: "-"`). |
| `autre source (email, teams, sharepoint)`, `file name tract` | — | Non reprises dans l'index (notes de travail / controle). Le nom du fichier tract doit correspondre a la fin de `URL tract`. |

## Affichage

- Badge : `Accord`, ou `Pas d'accord majoritaire`.
- Lien PDF unique : `Ouvrir l'accord`, ou `Ouvrir le PV de désaccord`. `Voir les signatures` s'affiche des qu'une capture existe, sauf pour un `Pas d'accord majoritaire`. Les coches des organisations restent affichees.
- Signatures, toujours dans cet ordre, coche si l'organisation est dans `signatures`, croix sinon : NNF et LAN = CGT, CFDT, CFE ; NPS = CGT, CFDT, CFE, CFTC. Le libelle affiche est `CFE`, pas `CFE-CGC`.
- Couleurs : CGT `#e63946`, CFDT `#f4a261`, CFE `#4da3ff`, CFTC `#9aa0aa`.
- Le selecteur de theme est toujours visible (`Tous les thèmes`, `Salaires`, `Effectifs`).
- Les selecteurs de site (NNF / NPS / LAN) et d'annee n'apparaissent que si `Tous les thèmes` est choisi. L'annee liste les annees du site choisi, y compris NPS et LAN. Un theme precis masque le site, l'annee et la representativite, et liste tous les perimetres de ce theme.
- Le camembert de representativite (2022) est affiche sous le titre, seulement lorsqu'un site est selectionne, dans l'ordre des resultats. Le resume commence par un titre en gras : « Representativite entreprise NNF », « Representativite etablissement NPS » ou « Representativite etablissement LAN ».
  - NNF : CFDT 48,60 %, CFE-CGC 27,91 %, CGT 23,49 %. Aucune OS n'est majoritaire : il faut la signature d'au moins 2 des 3 syndicats representatifs.
  - LAN : CFDT 51,39 %, CGT 32,18 %, CFE-CGC 16,44 %. La CFDT est majoritaire et peut valider seule un accord d'etablissement.
  - NPS : CFDT 42,17 %, CFE-CGC 28,09 %, CGT 18,20 %, CFTC 11,54 %. La CFDT et la CFTC ont ensemble la majorite et peuvent valider seules un accord d'etablissement.

## Classement local des PDF

- Le PDF GEPP est dans `negos_html_files/copies/`.
- Les documents HRLibrary et BDESE sont places dans `copies_rh/`, au meme niveau que `negos_html_files/`.
- La source RH synchronisee localement est `C:\Users\yelmghaz\Nokia\People library - France`.
- Le PDF BDESE Handicap provient de `C:\Users\yelmghaz\Nokia\CGT - NPS - Documents\NNF France\negos centrales\accord handicap 2025\ACCORD HANDICAP VERSION REVUE LE 8 juin 2026.pdf` et est copie sous le nom de `file name accord`.
- Apres une resynchronisation, supprimer les PDF de `negos_html_files/copies/` et de `copies_rh/`, ainsi que les JPG de `negos_html_files/signatures/`, qui ne sont plus references par le classeur ouvert. Les PDF de `negos_html_files/copies/` et `copies_rh/` sont ignores par git.
- Le script ignore un PDF RH deja present dans `copies_rh/` et ne deplace ni ne remplace le PDF GEPP de `negos_html_files/copies/`.

## Captures de signatures

Une capture JPG par PDF se trouve dans `negos_html_files/signatures/`. Les captures `cgt_` proviennent du PDF GEPP de `negos_html_files/copies/`; les captures `rh_` proviennent de `copies_rh/`. Fusionner les pages cote a cote lorsque les signatures sont reparties sur plusieurs pages.

Dans l'index, stocker l'URL SharePoint de `page signature` dans `documents[].signatureTarget`. Format visionneuse image, pour ouvrir le JPG et non le dossier : `https://nokia.sharepoint.com/:i:/r/sites/CGT39/Shared%20Documents/salari%C3%A9s/accords%20n%C3%A9goci%C3%A9s/negos_html_files/signatures/rh_nom_p10_signature.jpg?csf=1&web=1`. En Excel, `page signature` contient la meme URL. Si aucune page de signature ou aucun document n'existe, laisser `page signature` vide et omettre `signatureTarget`.

Verifier chaque capture visuellement : certains scans sont tournes (redresser l'image) et certains PDF locaux ne sont pas signes (ne pas produire de capture dans ce cas).

Le champ `link` n'est pas utilise dans l'index et ne doit pas etre ajoute. `firstRoundDate` n'est pas conserve dans `agreementRows`.

- Accord HRLibrary : URL commencant par `https://nokia.sharepoint.com/sites/HRLibrary/`.
- Accord BDESE Centrale : URL commencant par `https://nokia.sharepoint.com/sites/BDESENNF-Centrale/`.
- Accord AUXAD : URL visionneuse `:b:/r/` sur `/sites/BDESENNF-CSE-C/`, pas un lien `AllItems.aspx`.
- Documents CGT39 : URL sous `/sites/CGT39/`.
- Tracts : URL commencant par `https://nokia.sharepoint.com/sites/CGT39/Shared%20Documents/salari%C3%A9s/tracts%20diffus%C3%A9s/`.

Le dossier `salariés` apparait une seule fois dans le chemin des tracts.

## Encodage des URLs

- Espaces : `%20`
- `é` : `%C3%A9`
- `è` : `%C3%A8`
- `à` : `%C3%A0`
- Conserver les paramètres SharePoint existants (`?web=1`, `DocIdRedir.aspx`, etc.).

## Controles avant commit

1. Verifier qu'il n'existe plus de cible relative :

```bash
grep -nE '"(url|signatureTarget)": "(\.\./|20[0-9][0-9]/|captures_signatures/)' negos_html_files/negos-cgt-2023-2026.html
```

2. Verifier les chemins sensibles :

- HRLibrary ne doit pas contenir `/sites/CGT39/HRLibrary/`.
- BDESE Centrale doit utiliser `/sites/BDESENNF-Centrale/`. AUXAD doit utiliser `:b:/r/sites/BDESENNF-CSE-C/`.
- Les tracts doivent utiliser `/sites/CGT39/Shared%20Documents/salari%C3%A9s/tracts%20diffus%C3%A9s/`.
- Les tracts ne doivent jamais contenir `salari%C3%A9s/salari%C3%A9s`.

3. Verifier que les titres, noms de fichier, statuts, `signatureSource`, `Summary`, `Position CGT`, `URL accord` et `page signature` concordent entre Excel et l'index. `documents[].signatureTarget` doit etre l'URL de `page signature`. Les JPG correspondants doivent exister dans `negos_html_files/signatures/`. Un PV de desaccord garde son `signatureTarget`, mais le lien « Voir les signatures » n'est pas affiche.

4. Executer le diagnostic VS Code sur `negos_html_files/negos-cgt-2023-2026.html`.

5. Ne modifier `accords.xlsx` que si la mise a jour Excel a ete explicitement demandee.
