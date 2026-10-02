# Mise a jour depuis Excel

## Principe et colonnes

Lors d'une mise a jour depuis la feuille `accords` de `accords.xlsx`, synchroniser les donnees avec `agreementRows` de `index.html` en appariant les lignes par annee, site et titre.

- A `année`, B `site`, C `Accord ou négociation` : titre court, objet seul ; ajouter l'annee quand un objet se repete (NAO, RCC, amenagement du temps de travail).
- D `URL` : URL brute absolue du document. La reporter telle quelle dans `documentTarget`. Cellule vide = document introuvable. Plusieurs URLs separees par `, ` deviennent un tableau.
- E `file name` : reprendre le nom de fichier exact de l'URL en D. Ne jamais reconstruire D a partir de E.
- F `Validité` : formule basee sur G-I. Deux signatures confirmees ou plus = `TRUE`; si deux signatures restent possibles mais non verifiees = `À vérifier`; sinon = `FALSE`. Exception : un PV de désaccord est valide comme procès-verbal, avec G-I a `-` et la source `PV de désaccord valide unilatéralement ; aucun accord collectif n’a été signé.`
- G-I `CGT`, `CFDT`, `CFE-CGC` : statuts confirmes par la page de signature ; `-` pour un PV de désaccord (rien à signer).
- J `page signature` : URL SharePoint brute vers la capture JPG sous `https://nokia.sharepoint.com/sites/CGT39/Shared%20Documents/salari%C3%A9s/accords%20n%C3%A9goci%C3%A9s/captures_signatures/`.
- K `Source signatures` : preferer `p.X : signatures de...` en nommant les organisations visibles et toute absence. Si la capture est une version non signee, l'indiquer au lieu de la presenter comme preuve.
- L `date VF` : date finale lue dans le PDF (page de signature, date de validation ou page de garde) ; reporter dans `finalVersionDate`.
- M `Contenu`, N `Position CGT`, O `tract` : champs descriptifs et tract. Le lien du tract reste absolu.

## Classement local des PDF

- `copies/` contient uniquement les copies locales CGT39.
- Les documents HRLibrary et BDESE sont places dans `copies/rh/`.
- La source RH synchronisee localement est `C:\Users\yelmghaz\Nokia\People library - France`.
- Le PDF BDESE Handicap provient de `C:\Users\yelmghaz\Nokia\CGT - NPS - Documents\NNF France\negos centrales\accord handicap 2025\ACCORD HANDICAP VERSION REVUE LE 8 juin 2026.pdf` et est copie sous le nom de fichier de la colonne E.
- Le script ignore un PDF RH deja present dans `copies/rh/` et ne deplace ni ne remplace les copies CGT39 de `copies/`.

## Captures de signatures

Une capture JPG par PDF se trouve dans `captures_signatures/`. Les captures `cgt_` proviennent des PDF de `copies/`; les captures `rh_` proviennent de `copies/rh/`. Fusionner les pages cote a cote lorsque les signatures sont reparties sur plusieurs pages.

Dans l'index, stocker le chemin relatif de la capture dans `signatureTarget`, par exemple `captures_signatures/rh_nom_p10_signature.jpg`. En Excel, J contient l'URL SharePoint absolue construite avec le prefixe CGT39 ci-dessus. Si aucune page de signature ou aucun document n'existe, laisser J et `signatureTarget` vides.

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
rg '"(documentTarget|tractTarget)": "\.\./|"tractTarget": "20[0-9][0-9]/' index.html
```

2. Verifier les chemins sensibles :

- HRLibrary ne doit pas contenir `/sites/CGT39/HRLibrary/`.
- BDESE doit utiliser `/sites/BDESENNF-Centrale/`.
- Les tracts doivent utiliser `/sites/CGT39/Shared%20Documents/salari%C3%A9s/tracts%20diffus%C3%A9s/`.
- Les tracts ne doivent jamais contenir `salari%C3%A9s/salari%C3%A9s`.

3. Verifier que les titres, filenames, statuts, `signatureSource`, URLs D et captures J concordent. Les captures `signatureTarget` doivent exister dans `captures_signatures/`.

4. Executer le diagnostic VS Code sur `index.html`.

5. Ne modifier `accords.xlsx` que si la mise a jour Excel a ete explicitement demandee.
