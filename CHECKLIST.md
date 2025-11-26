# ✅ Checklist complète : Publication sur Artifact Hub

Cette checklist vous guide pas à pas pour publier votre Helm chart sur Artifact Hub.

---

## 🔧 Phase 1 : Préparation du repository (30 minutes)

### 1.1 Configuration GitHub

- [ ] Repository GitHub public créé
- [ ] Clone du repository en local
- [ ] Branche `main` définie comme branche par défaut

### 1.2 Ajout des fichiers workflows

```bash
# Copier les workflows
mkdir -p .github/workflows
cp .github/workflows/release-helm-chart.yml votre-repo/.github/workflows/
cp .github/workflows/lint-test.yml votre-repo/.github/workflows/
```

- [ ] Workflow `release-helm-chart.yml` ajouté
- [ ] Workflow `lint-test.yml` ajouté
- [ ] Commit et push des workflows

### 1.3 Configuration des permissions GitHub Actions

1. Aller dans **Settings** > **Actions** > **General**
2. Section **Workflow permissions** :
   - [ ] Cocher **Read and write permissions**
   - [ ] Cocher **Allow GitHub Actions to create and approve pull requests**
3. [ ] Cliquer sur **Save**

### 1.4 Activation de GitHub Pages

1. Aller dans **Settings** > **Pages**
2. Configuration :
   - [ ] Source: **Deploy from a branch**
   - [ ] Branch: **gh-pages** / **/ (root)**
   - [ ] Cliquer sur **Save**

---

## 📦 Phase 2 : Création de la branche gh-pages (10 minutes)

```bash
# Créer la branche gh-pages vide
git checkout --orphan gh-pages
git rm -rf .
echo "# Helm Charts Repository" > README.md
git add README.md
git commit -m "Initialize gh-pages"
git push origin gh-pages

# Retourner sur main
git checkout main
```

- [ ] Branche `gh-pages` créée
- [ ] Push réussi
- [ ] Retour sur branche `main`

### Vérification

```bash
# Vérifier que les deux branches existent
git branch -a | grep -E "(main|gh-pages)"
```

- [ ] Les deux branches sont présentes

---

## 📝 Phase 3 : Validation du chart (15 minutes)

### 3.1 Vérification des fichiers requis

```bash
cd charts/outscale-s3-explorer
ls -la
```

- [ ] `Chart.yaml` présent et valide
- [ ] `values.yaml` présent et documenté
- [ ] `values.schema.json` présent
- [ ] `README.md` complet et à jour
- [ ] `Changelog.md` présent
- [ ] `templates/` contient tous les manifests Kubernetes
- [ ] `.helmignore` configuré

### 3.2 Validation technique

```bash
# Lint du chart
helm lint charts/outscale-s3-explorer

# Test du template
helm template test charts/outscale-s3-explorer

# Validation stricte
helm lint charts/outscale-s3-explorer --strict
```

- [ ] Aucune erreur de lint
- [ ] Templates générés correctement
- [ ] Validation stricte passée

### 3.3 Vérification de Chart.yaml

```yaml
# Vérifier la présence de :
apiVersion: v2
name: outscale-s3-explorer
version: 0.1.0
appVersion: "1.0.0"
keywords: [outscale, s3, storage, ...]
maintainers:
  - name: SolucTeam
    email: k.aziz.k@live.fr
annotations:
  artifacthub.io/category: storage
  artifacthub.io/license: Apache-2.0
  artifacthub.io/displayName: Outscale S3 Explorer
```

- [ ] Toutes les métadonnées présentes
- [ ] Annotations Artifact Hub correctes
- [ ] Version valide (semver)

### 3.4 Vérification de artifacthub-repo.yml

```bash
# Vérifier le fichier à la racine
cat artifacthub-repo.yml
```

- [ ] Fichier présent à la racine du repository
- [ ] `repositoryID` présent (temporaire au début)
- [ ] `owners` renseigné avec email valide

---

## 🚀 Phase 4 : Première release (20 minutes)

### 4.1 Préparation du script

```bash
# Rendre le script exécutable
chmod +x release.sh

# Test en dry-run
./release.sh patch --dry-run
```

- [ ] Script exécutable
- [ ] Dry-run fonctionne sans erreur

### 4.2 Création de la première release

```bash
# Lancer la release
./release.sh patch -m "Initial release"
```

- [ ] Version bumpée (ex: 0.1.0 → 0.1.1)
- [ ] Changelog mis à jour
- [ ] Commit créé
- [ ] Push réussi

### 4.3 Vérification du workflow GitHub Actions

1. Aller sur : `https://github.com/SolucTeam/SolucTeam-helm-charts/actions`

- [ ] Workflow **Release Helm Chart** s'est déclenché
- [ ] Workflow terminé avec succès (badge vert)
- [ ] Durée < 5 minutes

### 4.4 Vérification de la GitHub Release

1. Aller sur : `https://github.com/SolucTeam/SolucTeam-helm-charts/releases`

- [ ] Release créée automatiquement
- [ ] Tag correct (ex: `outscale-s3-explorer-0.1.1`)
- [ ] Fichier `.tgz` attaché
- [ ] Notes de release générées

### 4.5 Vérification de GitHub Pages

```bash
# Vérifier l'index Helm
curl -s https://solucteam.github.io/SolucTeam-helm-charts/index.yaml | head -20
```

- [ ] Index Helm accessible
- [ ] Nouvelle version listée
- [ ] URL du chart correcte

### 4.6 Test d'installation depuis le repository

```bash
# Ajouter le repository
helm repo add solucteam-test https://solucteam.github.io/SolucTeam-helm-charts/
helm repo update

# Rechercher le chart
helm search repo solucteam-test

# Tester l'installation (dry-run)
helm install test solucteam-test/outscale-s3-explorer \
  --dry-run \
  --debug \
  --namespace test
```

- [ ] Repository ajouté avec succès
- [ ] Chart trouvé dans la recherche
- [ ] Installation dry-run réussie

---

## 🌐 Phase 5 : Enregistrement sur Artifact Hub (15 minutes)

### 5.1 Création du compte

1. Aller sur : [https://artifacthub.io/](https://artifacthub.io/)
2. Cliquer sur **Sign in**
3. Se connecter avec **GitHub**

- [ ] Compte Artifact Hub créé
- [ ] Connexion GitHub autorisée

### 5.2 Ajout du repository

1. Cliquer sur votre profil en haut à droite
2. Sélectionner **Control Panel**
3. Cliquer sur **Add repository**

Remplir le formulaire :

```
Kind: Helm charts
Name: outscale-s3-explorer
Display name: Outscale S3 Explorer  
URL: https://solucteam.github.io/SolucTeam-helm-charts/
Description: (optionnel)
```

- [ ] Repository ajouté sur Artifact Hub
- [ ] Confirmation reçue

### 5.3 Récupération du Repository ID

1. Dans le **Control Panel**, cliquer sur le repository créé
2. Copier le **Repository ID** (format UUID)

- [ ] Repository ID copié

### 5.4 Mise à jour de artifacthub-repo.yml

```bash
# Éditer le fichier
nano artifacthub-repo.yml

# Remplacer par le vrai Repository ID
repositoryID: <votre-nouveau-repository-id>

owners:
  - name: SolucTeam
    email: k.aziz.k@live.fr

# Commit et push
git add artifacthub-repo.yml
git commit -m "chore: update Artifact Hub repository ID"
git push origin main
```

- [ ] `artifacthub-repo.yml` mis à jour avec le vrai ID
- [ ] Commit et push effectués

---

## ✅ Phase 6 : Vérifications finales (30 minutes)

### 6.1 Première synchronisation Artifact Hub

⏰ **Attendre 30 minutes** pour la première synchronisation

Pendant ce temps, vérifier :

```bash
# Branche gh-pages contient artifacthub-repo.yml
git checkout gh-pages
ls -la artifacthub-repo.yml
git checkout main
```

- [ ] `artifacthub-repo.yml` présent dans `gh-pages`

### 6.2 Vérification sur Artifact Hub

Après 30 minutes, aller sur :
`https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer`

- [ ] Page du package accessible
- [ ] README affiché correctement
- [ ] Version affichée
- [ ] Commandes d'installation présentes
- [ ] Liens vers GitHub fonctionnels
- [ ] Badge "Verified Publisher" (si configuré)

### 6.3 Test d'installation finale

```bash
# Avec le repository officiel
helm repo add outscale-s3-explorer https://solucteam.github.io/SolucTeam-helm-charts/
helm repo update

# Installer dans un cluster de test
helm install test-final outscale-s3-explorer/outscale-s3-explorer \
  --namespace test \
  --create-namespace

# Vérifier
kubectl get pods -n test
helm list -n test

# Nettoyer
helm uninstall test-final -n test
kubectl delete namespace test
```

- [ ] Installation réussie
- [ ] Pods démarrés correctement
- [ ] Service accessible
- [ ] Désinstallation propre

### 6.4 Mise à jour du README principal

```bash
# Mettre à jour avec les badges et liens Artifact Hub
cp README-new.md README.md
git add README.md
git commit -m "docs: update README with Artifact Hub links"
git push origin main
```

- [ ] README mis à jour
- [ ] Badges Artifact Hub ajoutés
- [ ] Liens fonctionnels

---

## 🎯 Phase 7 : Communication (15 minutes)

### 7.1 Annonce de la release

- [ ] Tweet/post sur les réseaux sociaux
- [ ] Mise à jour de la documentation
- [ ] Notification aux utilisateurs

### 7.2 Ajout des badges dans le README

```markdown
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/outscale-s3-explorer)](https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer)
[![Release Charts](https://github.com/SolucTeam/SolucTeam-helm-charts/actions/workflows/release-helm-chart.yml/badge.svg)](https://github.com/SolucTeam/SolucTeam-helm-charts/actions/workflows/release-helm-chart.yml)
```

- [ ] Badges ajoutés au README
- [ ] Commit et push effectués

---

## 📊 Checklist de maintenance continue

### Releases futures

Pour chaque nouvelle release :

- [ ] Tester en local avec `./release.sh patch --dry-run`
- [ ] Mettre à jour le Changelog
- [ ] Créer la release : `./release.sh patch`
- [ ] Vérifier le workflow GitHub Actions
- [ ] Attendre 30 minutes pour la sync Artifact Hub
- [ ] Vérifier la page Artifact Hub
- [ ] Tester l'installation

### Maintenance mensuelle

- [ ] Vérifier les issues GitHub
- [ ] Répondre aux questions sur Artifact Hub
- [ ] Mettre à jour la documentation
- [ ] Vérifier les dépendances
- [ ] Scanner les vulnérabilités
- [ ] Mettre à jour les exemples

---

## 🆘 En cas de problème

### Le workflow échoue

1. Vérifier les logs : `https://github.com/SolucTeam/SolucTeam-helm-charts/actions`
2. Vérifier les permissions GitHub Actions
3. Consulter la section [Dépannage](./ARTIFACT_HUB_GUIDE.md#-dépannage)

### Le chart n'apparaît pas sur Artifact Hub

1. Attendre 30 minutes minimum
2. Forcer la synchronisation sur Artifact Hub (bouton "Sync")
3. Vérifier que `artifacthub-repo.yml` est dans `gh-pages`
4. Vérifier les logs d'Artifact Hub (si disponibles)

### Erreur d'installation du chart

1. Valider avec `helm lint`
2. Tester avec `helm template`
3. Vérifier les logs des pods
4. Ouvrir une issue sur GitHub

---

## 🎉 Félicitations !

Si toutes les cases sont cochées, votre Helm chart est maintenant :

✅ Publié sur GitHub
✅ Disponible via GitHub Pages
✅ Référencé sur Artifact Hub
✅ Installable par tous via Helm

---

## 📚 Ressources

- [Guide complet](./ARTIFACT_HUB_GUIDE.md)
- [Documentation Artifact Hub](https://artifacthub.io/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Temps total estimé** : ~2h30 (première fois)

Pour les releases suivantes : ~5 minutes grâce à l'automatisation ! 🚀