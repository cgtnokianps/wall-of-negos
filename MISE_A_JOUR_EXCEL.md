# Mise a jour depuis Excel

## Principe

Lors d'une prochaine mise a jour depuis `accords.xlsx`, reporter les nouvelles lignes dans `agreementRows` de `index.html`.

Les URLs doivent etre completes directement dans les donnees. Ne pas utiliser de chemin relatif comme `../../../HRLibrary/...` ou `2025/tract.pdf`.

La colonne D d'Excel s'appelle `URL` (anciennement `Lien`) et contient deja l'URL brute absolue du document (texte, pas d'hyperlien). La reporter telle quelle dans `documentTarget` : normalement aucune correction n'est necessaire. Cellule vide = document introuvable.

- Accord CGT39 : renseigner `documentTarget` avec l'URL complete du document dans le dossier des accords negocies.
- Accord HRLibrary : renseigner `documentTarget` avec une URL commencant par `https://nokia.sharepoint.com/sites/HRLibrary/`. Ne pas ajouter `CGT39`.
- Accord BDESE : renseigner `documentTarget` avec une URL commencant par `https://nokia.sharepoint.com/sites/BDESENNF-Centrale/`.
- Tract : renseigner `tractTarget` avec une URL commencant par `https://nokia.sharepoint.com/sites/CGT39/Shared%20Documents/salari%C3%A9s/tracts%20diffus%C3%A9s/`.

Le dossier `salariés` apparait une seule fois dans le chemin des tracts.

## Encodage des URLs

- Espaces : `%20`
- `é` : `%C3%A9`
- `è` : `%C3%A8`
- `à` : `%C3%A0`
- Conserver les paramètres SharePoint existants (`?web=1`, `DocIdRedir.aspx`, etc.).

## Champs a verifier

Pour chaque ligne Excel :

- `year`, `site`, `title`
- `link` : `CGT39`, `HRLibrary` ou `BDESE` (a deduire du domaine de l'URL : `/sites/CGT39/`, `/sites/HRLibrary/`, `/sites/BDESENNF-Centrale/`)
- `documentTarget` : valeur de la colonne Excel `URL`, ou chaine vide si la cellule est vide
- `tractTarget` : URL absolue, ou chaine vide si aucun tract
- `validity`, `cgt`, `cfdt`, `cfeCgc`
- `content`, `cgtPosition`, `signatureSource`

`fileName` peut rester comme information descriptive, mais il ne doit plus servir a reconstruire le lien.

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

3. Executer le test de rendu Node utilise dans le projet et verifier le nombre total d'accords, de liens de documents et de liens de tracts.

4. Executer le diagnostic VS Code sur `index.html`.

5. Ne modifier `accords.xlsx` que si la mise a jour Excel a ete explicitement demandee.
