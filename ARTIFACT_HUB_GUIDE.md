# 🚀 Guide de publication sur Artifact Hub

Ce guide vous explique comment publier automatiquement votre Helm chart sur [Artifact Hub](https://artifacthub.io/) via GitHub Actions.

---

## 📋 Prérequis

- ✅ Repository GitHub public
- ✅ Helm chart valide dans le dossier `charts/`
- ✅ Fichier `artifacthub-repo.yml` à la racine
- ✅ Accès administrateur au repository

---

## 🔧 Configuration initiale

### Étape 1 : Activer GitHub Pages

1. **Aller dans les Settings du repository**
   ```
   https://github.com/SolucTeam/SolucTeam-helm-charts/settings/pages
   ```

2. **Configurer GitHub Pages**
   - Source : `Deploy from a branch`
   - Branch : `gh-pages`
   - Folder : `/ (root)`
   - Cliquer sur **Save**

3. **Attendre le déploiement**
   - L'URL sera : `https://solucteam.github.io/SolucTeam-helm-charts/`

### Étape 2 : Créer la branche gh-pages

```bash
# Créer une branche gh-pages vide
git checkout --orphan gh-pages
git rm -rf .
git commit --allow-empty -m "Initial gh-pages commit"
git push origin gh-pages

# Retourner sur main
git checkout main
```

### Étape 3 : Vérifier artifacthub-repo.yml

Assurez-vous que le fichier `artifacthub-repo.yml` est présent à la racine :

```yaml
# artifacthub-repo.yml
repositoryID: d109cb2a-3a01-463f-b599-1cd5babfe411

owners:
  - name: SolucTeam
    email: k.aziz.k@live.fr
```

> ⚠️ **Important** : Le `repositoryID` sera fourni par Artifact Hub après l'enregistrement.

---

## 🤖 Workflow GitHub Actions

Le workflow `.github/workflows/release-helm-chart.yml` fait automatiquement :

1. ✅ Package le Helm chart
2. ✅ Crée une release GitHub avec le fichier `.tgz`
3. ✅ Met à jour l'index Helm dans `gh-pages`
4. ✅ Copie `artifacthub-repo.yml` dans `gh-pages`

### Déclenchement automatique

Le workflow se déclenche automatiquement :
- ✅ Sur chaque push vers `main` qui modifie `charts/**`
- ✅ Manuellement via l'onglet "Actions"

### Première release manuelle

```bash
# 1. Modifier la version dans Chart.yaml
cd charts/outscale-s3-explorer
# Changer version: 0.1.0 → 0.1.1

# 2. Commit et push
git add Chart.yaml
git commit -m "chore: bump chart version to 0.1.1"
git push origin main

# 3. Le workflow se déclenche automatiquement
# Vérifier : https://github.com/SolucTeam/SolucTeam-helm-charts/actions
```

---

## 🌐 Enregistrement sur Artifact Hub

### Étape 1 : Se connecter à Artifact Hub

1. Aller sur [artifacthub.io](https://artifacthub.io/)
2. Se connecter avec GitHub
3. Autoriser l'accès

### Étape 2 : Ajouter le repository Helm

1. **Cliquer sur votre profil** → **Control Panel**
2. **Cliquer sur "Add repository"**
3. **Remplir le formulaire** :

   ```
   Kind: Helm charts
   Name: outscale-s3-explorer
   Display name: Outscale S3 Explorer
   URL: https://solucteam.github.io/SolucTeam-helm-charts/
   ```

4. **Vérification** (optionnel)
   - Cocher "Verified Publisher" si vous voulez le badge vérifié
   - Nécessite de prouver la propriété du domaine

5. **Cliquer sur "Add"**

### Étape 3 : Récupérer le Repository ID

1. Une fois le repository ajouté, Artifact Hub génère un `repositoryID`
2. **Copier ce repositoryID**
3. **Mettre à jour `artifacthub-repo.yml`** :

   ```yaml
   repositoryID: <le-nouveau-repository-id>
   
   owners:
     - name: SolucTeam
       email: k.aziz.k@live.fr
   ```

4. **Commit et push** :

   ```bash
   git add artifacthub-repo.yml
   git commit -m "chore: update Artifact Hub repository ID"
   git push origin main
   ```

### Étape 4 : Vérifier la synchronisation

1. Artifact Hub scanne automatiquement votre repository toutes les **30 minutes**
2. Vérifier votre chart : `https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer`

---

## 🔄 Workflow de release

### Release standard

```bash
# 1. Faire vos modifications dans le chart
cd charts/outscale-s3-explorer
# ... modifications ...

# 2. Bumper la version dans Chart.yaml
# version: 0.1.0 → 0.1.1

# 3. Mettre à jour CHANGELOG.md
cat >> Changelog.md <<EOF

## [0.1.1] - $(date +%Y-%m-%d)

### Fixed
- Correction du bug XYZ

EOF

# 4. Commit et push
git add .
git commit -m "chore: release version 0.1.1"
git push origin main

# 5. Le workflow se déclenche automatiquement
# Suivre la progression : GitHub Actions > release-helm-chart
```

### Release majeure

Pour une version majeure (breaking changes) :

```bash
# 1. Créer une branche de release
git checkout -b release/v1.0.0

# 2. Bumper la version
# Chart.yaml: version: 0.9.0 → 1.0.0

# 3. Mettre à jour CHANGELOG.md avec tous les breaking changes

# 4. Mettre à jour Chart.yaml annotations
cat >> Chart.yaml <<EOF
annotations:
  artifacthub.io/changes: |
    - kind: changed
      description: Breaking - Nouvelle structure de configuration
    - kind: added
      description: Support du multi-tenancy
EOF

# 5. Commit et merge
git add .
git commit -m "chore: release version 1.0.0"
git push origin release/v1.0.0

# 6. Créer une Pull Request et merger vers main
```

---

## 🎯 Vérifications post-release

### 1. Vérifier GitHub Release

```bash
# Ouvrir dans le navigateur
https://github.com/SolucTeam/SolucTeam-helm-charts/releases
```

Vérifier :
- ✅ Tag créé (ex: `outscale-s3-explorer-0.1.1`)
- ✅ Fichier `.tgz` attaché
- ✅ Notes de release générées

### 2. Vérifier GitHub Pages

```bash
# Vérifier l'index Helm
curl https://solucteam.github.io/SolucTeam-helm-charts/index.yaml
```

Vérifier :
- ✅ Nouvelle version présente dans l'index
- ✅ URL du chart correcte
- ✅ Métadonnées à jour

### 3. Tester l'installation

```bash
# Ajouter le repository
helm repo add outscale-s3-explorer https://solucteam.github.io/SolucTeam-helm-charts/
helm repo update

# Rechercher le chart
helm search repo outscale-s3-explorer

# Installer
helm install test-release outscale-s3-explorer/outscale-s3-explorer \
  --version 0.1.1 \
  --namespace test \
  --create-namespace

# Vérifier
helm list -n test
kubectl get pods -n test

# Nettoyer
helm uninstall test-release -n test
kubectl delete namespace test
```

### 4. Vérifier Artifact Hub

1. Attendre 30 minutes (synchronisation automatique)
2. Ouvrir : `https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer`
3. Vérifier :
   - ✅ Nouvelle version affichée
   - ✅ README rendu correctement
   - ✅ Valeurs affichées
   - ✅ Métadonnées correctes

---

## 📊 Badges à ajouter dans README.md

Ajouter ces badges dans votre README principal :

```markdown
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/outscale-s3-explorer)](https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer)
[![Release Charts](https://github.com/SolucTeam/SolucTeam-helm-charts/actions/workflows/release-helm-chart.yml/badge.svg)](https://github.com/SolucTeam/SolucTeam-helm-charts/actions/workflows/release-helm-chart.yml)
[![GitHub release](https://img.shields.io/github/v/release/SolucTeam/SolucTeam-helm-charts?include_prereleases)](https://github.com/SolucTeam/SolucTeam-helm-charts/releases)
```

---

## 🐛 Dépannage

### Le workflow échoue

**Problème** : `Error: failed to create GitHub release`

**Solution** :
```bash
# Vérifier les permissions GitHub Actions
# Settings > Actions > General > Workflow permissions
# ✅ Cocher "Read and write permissions"
```

### La branche gh-pages n'existe pas

**Solution** :
```bash
# Créer manuellement la branche
git checkout --orphan gh-pages
git rm -rf .
echo "# Helm Charts Repository" > README.md
git add README.md
git commit -m "Initialize gh-pages"
git push origin gh-pages
git checkout main
```

### Artifact Hub ne trouve pas le repository

**Problème** : "Repository not found" sur Artifact Hub

**Solutions** :
1. ✅ Vérifier que GitHub Pages est activé
2. ✅ Vérifier que l'URL est accessible : `https://solucteam.github.io/SolucTeam-helm-charts/index.yaml`
3. ✅ Attendre 30 minutes pour la synchronisation
4. ✅ Vérifier le `repositoryID` dans `artifacthub-repo.yml`

### Le chart n'apparaît pas sur Artifact Hub

**Problème** : Le repository est enregistré mais le chart n'apparaît pas

**Solutions** :
1. ✅ Vérifier que `artifacthub-repo.yml` est dans la branche `gh-pages`
2. ✅ Vérifier les métadonnées dans `Chart.yaml` :
   ```yaml
   annotations:
     artifacthub.io/category: storage
     artifacthub.io/license: Apache-2.0
   ```
3. ✅ Forcer une synchronisation manuelle sur Artifact Hub (bouton "Sync")

### Erreur de validation du chart

**Problème** : `helm lint` échoue

**Solution** :
```bash
# Valider localement
helm lint charts/outscale-s3-explorer

# Tester le template
helm template test charts/outscale-s3-explorer

# Vérifier le schema JSON
helm lint charts/outscale-s3-explorer --with-subcharts --strict
```

---

## 📚 Ressources utiles

- 📖 [Artifact Hub Documentation](https://artifacthub.io/docs/)
- 🔧 [Chart Releaser GitHub Action](https://github.com/helm/chart-releaser-action)
- 📦 [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- 🌐 [GitHub Pages Documentation](https://docs.github.com/en/pages)

---

## ✅ Checklist complète

### Avant la première release

- [ ] Repository GitHub public créé
- [ ] GitHub Pages activé sur branche `gh-pages`
- [ ] Branche `gh-pages` créée
- [ ] Workflow GitHub Actions configuré
- [ ] `artifacthub-repo.yml` à la racine
- [ ] Chart validé avec `helm lint`
- [ ] README.md complet avec exemples
- [ ] CHANGELOG.md créé
- [ ] LICENSE ajouté

### Pour chaque release

- [ ] Version bumpée dans `Chart.yaml`
- [ ] `appVersion` mise à jour si nécessaire
- [ ] CHANGELOG.md mis à jour
- [ ] Annotations `artifacthub.io/changes` ajoutées
- [ ] Tests locaux effectués
- [ ] Commit avec message conventionnel
- [ ] Push vers `main`
- [ ] Workflow GitHub Actions réussi
- [ ] Release GitHub créée
- [ ] GitHub Pages mis à jour
- [ ] Test d'installation depuis le repository Helm
- [ ] Vérification sur Artifact Hub (après 30 min)

---

## 🎉 Félicitations !

Votre Helm chart est maintenant publié et accessible à tous via :

- 🌐 **GitHub Pages** : `https://solucteam.github.io/SolucTeam-helm-charts/`
- 📦 **Artifact Hub** : `https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer`
- 🚀 **Installation** : `helm repo add outscale-s3-explorer https://solucteam.github.io/SolucTeam-helm-charts/`

---

**Questions ou problèmes ?** Ouvrez une [issue GitHub](https://github.com/SolucTeam/SolucTeam-helm-charts/issues) !