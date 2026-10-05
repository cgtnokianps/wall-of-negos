# Mise a jour depuis Excel

## Principe et colonnes

Lors d'une mise a jour depuis la feuille `accords` de `accords.xlsx`, regenerer `agreementRows` de `index.html` dans l'ordre d'Excel, en appariant les lignes par annee, site et titre.

Les colonnes sont reperees par leur **en-tete**, jamais par leur lettre (l'ordre change). Le classeur est ouvert depuis SharePoint : le fichier local peut etre en retard sur le dernier enregistrement, lire de preference le classeur ouvert dans Excel.

| En-tete Excel | Champ index | Regle |
|---|---|---|
| `année`, `site` | `year`, `site` | |
| `Accord ou négociation` | `title` | Titre court, objet seul ; ajouter l'annee quand un objet se repete (NAO, RCC, amenagement du temps de travail). |
| `URL accord` | `documentTarget` | URL brute absolue, reportee telle quelle. Vide = document introuvable. Plusieurs URLs separees par `, ` = tableau. Pas de `%2F` dans le chemin. |
| `file name accord` | `fileName` | Nom exact du fichier de l'URL. Ne jamais reconstruire l'URL a partir du nom. `-` = vide. |
| `date VF` | `finalVersionDate` | Date finale lue dans le PDF (signature, validation ou page de garde), au format `jj/mm/aaaa`. Vide = `-`. |
| `Validité` | `validity` | Formule basee sur CGT/CFDT/CFE-CGC : 2 signatures confirmees ou plus = `TRUE` ; 2 signatures encore possibles mais non verifiees = `À vérifier` ; sinon `FALSE`. Un PV de désaccord est valide comme procès-verbal. |
| `CGT`, `CFDT`, `CFE-CGC` | `cgt`, `cfdt`, `cfeCgc` | `TRUE` = ✅, `FALSE` = ❌, `À vérifier` ; `-` pour un PV de désaccord (rien à signer). |
| `page signature` | `signatureTarget` | URL SharePoint de la capture sous `https://nokia.sharepoint.com/sites/CGT39/Shared%20Documents/salari%C3%A9s/accords%20n%C3%A9goci%C3%A9s/captures_signatures/` ; dans l'index, chemin relatif `captures_signatures/...`. Vide ou `-` = pas de capture. |
| `Source signatures` | `signatureSource` | Preferer `p.X : signatures de...` en nommant les organisations visibles et toute absence. Signaler une version non signee. PV de désaccord : `PV de désaccord valide unilatéralement ; aucun accord collectif n’a été signé.` |
| `Summary` | `content` | Resume court affiche dans l'index. |
| `Position CGT` | `cgtPosition` | |
| `tract associé` | `tract[].title` | Titre du tract. Plusieurs tracts : un titre par ligne, dans l'ordre des URLs. |
| `URL tract` | `tract[].url` | URL absolue et encodee. `-` = pas de tract (`tract: "-"`). |
| `autre source (email, teams, sharepoint)`, `file name tract` | — | Non reprises dans l'index (notes de travail / controle). Le nom du fichier tract doit correspondre a la fin de `URL tract`. |

## Classement local des PDF

- `copies/` contient uniquement les copies locales CGT39.
- Les documents HRLibrary et BDESE sont places dans `copies/rh/`.
- La source RH synchronisee localement est `C:\Users\yelmghaz\Nokia\People library - France`.
- Le PDF BDESE Handicap provient de `C:\Users\yelmghaz\Nokia\CGT - NPS - Documents\NNF France\negos centrales\accord handicap 2025\ACCORD HANDICAP VERSION REVUE LE 8 juin 2026.pdf` et est copie sous le nom de fichier de la colonne E.
- Le script ignore un PDF RH deja present dans `copies/rh/` et ne deplace ni ne remplace les copies CGT39 de `copies/`.

## Captures de signatures

Une capture JPG par PDF se trouve dans `captures_signatures/`. Les captures `cgt_` proviennent des PDF de `copies/`; les captures `rh_` proviennent de `copies/rh/`. Fusionner les pages cote a cote lorsque les signatures sont reparties sur plusieurs pages.

Dans l'index, stocker le chemin relatif de la capture dans `signatureTarget`, par exemple `captures_signatures/rh_nom_p10_signature.jpg`. En Excel, `page signature` contient l'URL SharePoint absolue construite avec le prefixe CGT39 ci-dessus. Si aucune page de signature ou aucun document n'existe, laisser `page signature` et `signatureTarget` vides.

Verifier chaque capture visuellement : certains scans sont tournes (redresser l'image) et certains PDF locaux ne sont pas signes (ne pas produire de capture dans ce cas).

Le champ `link` n'est pas utilise dans l'index et ne doit pas etre ajoute. `firstRoundDate` n'est pas conserve dans `agreementRows`.

- Accord HRLibrary : URL commencant par `https://nokia.sharepoint.com/sites/HRLibrary/`.
- Accord BDESE : URL commencant par `https://nokia.sharepoint.com/sites/BDESENNF-Centrale/`.
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
grep -nE '"(documentTarget|url)": "(\.\./|20[0-9][0-9]/)' index.html
```

2. Verifier les chemins sensibles :

- HRLibrary ne doit pas contenir `/sites/CGT39/HRLibrary/`.
- BDESE doit utiliser `/sites/BDESENNF-Centrale/`.
- Les tracts doivent utiliser `/sites/CGT39/Shared%20Documents/salari%C3%A9s/tracts%20diffus%C3%A9s/`.
- Les tracts ne doivent jamais contenir `salari%C3%A9s/salari%C3%A9s`.

3. Verifier que les titres, noms de fichier, statuts, `signatureSource`, `URL accord` et `page signature` concordent entre Excel et l'index. Les captures `signatureTarget` doivent exister dans `captures_signatures/`.

4. Executer le diagnostic VS Code sur `index.html`.

5. Ne modifier `accords.xlsx` que si la mise a jour Excel a ete explicitement demandee.
