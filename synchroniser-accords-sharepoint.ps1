# Dossiers locaux synchronisés
$PeopleLibraryPath = "C:\Users\yelmghaz\Nokia\People library - France"
$CgtDocumentsPath = "C:\Users\yelmghaz\Nokia\CGT - NPS - Documents"
$ExistingCopiesDir = Join-Path $CgtDocumentsPath "salariés\accords négociés\copies"
$TargetFolder = Join-Path $ExistingCopiesDir "rh"
$RCC2026N1File = "Accord collectif portant sur une Rupture Conventionnelle Collective (RCC) au sein de Nokia Networks France (compressé).pdf"
$SourcePathOverrides = @{
    $RCC2026N1File = Join-Path $PeopleLibraryPath "Plan-de-transformation\RCC 2025\$RCC2026N1File"
}

if (-not (Test-Path -LiteralPath $PeopleLibraryPath)) {
    throw "Dossier source introuvable : $PeopleLibraryPath"
}
if (-not (Test-Path -LiteralPath $CgtDocumentsPath)) {
    throw "Dossier CGT introuvable : $CgtDocumentsPath"
}

$ExistingCopyNames = @{}
foreach ($CopiesDir in @($ExistingCopiesDir, $TargetFolder)) {
    if (Test-Path -LiteralPath $CopiesDir) {
        Get-ChildItem -LiteralPath $CopiesDir -Filter *.pdf -File | ForEach-Object {
            $ExistingCopyNames[$_.Name] = $true
        }
    }
}

New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
$CopiedFileCount = 0

$Files = @(
"Accord CGF.pdf",
"Accord établissement aménagement temps de travail 2022.pdf",
"NAO 2023 - PV désaccord.pdf",
"Accord aménagement temps travail NPS 2024.pdf",
"Accord_RCC_2026.pdf",
"Avenant nº 1 à l'Accord CSE du 21 septembre 2018.pdf",
"NAO_2026_Procès_verbal_d_accord_24 janvier_2026.pdf",
"Avenant RCC 2025.pdf",
"Accord Aménagement Temps Travail NPS 2026 (19 décembre 2025).pdf",
"Accord collectif portant sur une Rupture Conventionnelle Collective (RCC) au sein de Nokia Networks France (compressé).pdf",
"Accord d'entreprise relatif au Plan d'Epargne Entreprise au sein de Nokia Networks France (16 décembre 2025).pdf",
"Accord d'entreprise relatif au Plan d'Epargne Retraite d'Entreprise Collectif PERCOL (16 décembre 2025).pdf",
"Accord CET (24 juillet 2025).pdf",
"Accord d'intéressement 2025-2028.pdf",
"Procès verbal NAO (désaccord) 2025 (27 mars 2025).pdf",
"Avenant accord télétravail avril 2022.pdf",
"Accord don de jours 14 novembre 2024.pdf",
"Accord RCC 2024 (19 avril 2024).pdf",
"Accord cadre NPS nouvelle convention collective- 2024 signé.pdf",
"Avenant Procès-verbal de désaccord NAO 2024 (9 avril 2024).pdf",
"Accord de substitution non cadres - 30 novembre 2023.pdf",
"Accord harmonisation taux variable cible salariés non sales du 19 décembre 2023.pdf",
"Accord RCC 2023.pdf",
"Accord égalité professionnelle.pdf",
"Accord remboursement santé - 2023.pdf"
)

# Copie des PDF trouvés dans People library - France
foreach ($File in $Files) {

    if ($ExistingCopyNames.ContainsKey($File)) {
        Write-Host "Déjà présent dans copies/, ignoré : $File"
        continue
    }

    if ($SourcePathOverrides.ContainsKey($File)) {
        $OverridePath = $SourcePathOverrides[$File]
        $Matches = @()
        if (Test-Path -LiteralPath $OverridePath) {
            $Matches = @(Get-Item -LiteralPath $OverridePath)
        }
    }
    else {
        $Matches = @(Get-ChildItem -LiteralPath $PeopleLibraryPath -Filter $File -File -Recurse -ErrorAction SilentlyContinue)
    }
    if ($Matches.Count -eq 0) {
        Write-Warning "Introuvable dans People library - France : $File"
        continue
    }
    if ($Matches.Count -gt 1) {
        Write-Warning "Plusieurs fichiers correspondent, ignorés : $File"
        continue
    }

    Copy-Item -LiteralPath $Matches[0].FullName -Destination (Join-Path $TargetFolder $File) -Force
    $CopiedFileCount++
    Write-Host "Copié depuis People library : $File"
}

# Copie locale du PDF handicap utilisé pour l'accord BDESE
$BDESESourceFile = Join-Path $CgtDocumentsPath "NNF France\negos centrales\accord handicap 2025\ACCORD HANDICAP VERSION REVUE LE 8 juin 2026.pdf"
$BDESEFileName = "Accord handicap 2026.pdf"
if ($ExistingCopyNames.ContainsKey($BDESEFileName)) {
    Write-Host "Déjà présent dans copies/, ignoré : $BDESEFileName"
}
elseif (Test-Path -LiteralPath $BDESESourceFile) {
    Copy-Item -LiteralPath $BDESESourceFile -Destination (Join-Path $TargetFolder $BDESEFileName) -Force
    $CopiedFileCount++
    Write-Host "Copié depuis le dossier local : $BDESEFileName"
}
else {
    Write-Warning "PDF handicap local introuvable : $BDESESourceFile"
}

Write-Host "Terminé. PDF copiés : $CopiedFileCount"
