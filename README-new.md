# 📦 SolucTeam Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/outscale-s3-explorer)](https://artifacthub.io/packages/search?repo=outscale-s3-explorer)
[![Release Charts](https://github.com/SolucTeam/SolucTeam-helm-charts/actions/workflows/release-helm-chart.yml/badge.svg)](https://github.com/SolucTeam/SolucTeam-helm-charts/actions/workflows/release-helm-chart.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Repository officiel des Helm Charts pour les projets SolucTeam.

---

## 📚 Charts disponibles

| Chart | Version | Description | Documentation |
|-------|---------|-------------|---------------|
| [outscale-s3-explorer](./charts/outscale-s3-explorer) | [![Chart Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/SolucTeam/SolucTeam-helm-charts/main/charts/outscale-s3-explorer/Chart.yaml&query=$.version&label=version)](https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer) | Interface web moderne pour gérer le stockage S3 Outscale | [README](./charts/outscale-s3-explorer/README.md) |

---

## 🚀 Quick Start

### Ajouter le repository Helm

```bash
# Ajouter le repository
helm repo add solucteam https://solucteam.github.io/SolucTeam-helm-charts/

# Mettre à jour
helm repo update

# Rechercher les charts disponibles
helm search repo solucteam
```

### Installer un chart

```bash
# Installation simple
helm install my-release solucteam/outscale-s3-explorer

# Installation avec personnalisation
helm install my-release solucteam/outscale-s3-explorer \
  --namespace production \
  --create-namespace \
  --set image.tag=v1.0.0 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=s3.mydomain.com

# Installation avec fichier de valeurs
helm install my-release solucteam/outscale-s3-explorer \
  -f my-values.yaml \
  --namespace production \
  --create-namespace
```

---

## 📖 Documentation

### Guides principaux

- 🎯 **[Guide de publication Artifact Hub](./ARTIFACT_HUB_GUIDE.md)** - Comment publier automatiquement vos charts
- 📝 **[Contributing Guide](./CONTRIBUTING.md)** - Comment contribuer au projet

### Documentation des charts

- **[Outscale S3 Explorer](./charts/outscale-s3-explorer/README.md)** - Documentation complète

---

## 🛠️ Pour les développeurs

### Créer une nouvelle release

```bash
# Rendre le script exécutable
chmod +x release.sh

# Release patch (0.1.0 → 0.1.1)
./release.sh patch

# Release avec message personnalisé
./release.sh patch -m "Fix authentication issue"
```

Pour plus de détails, consultez le **[Guide de publication](./ARTIFACT_HUB_GUIDE.md)**.

---

## 🌐 Liens utiles

- 📦 **[Artifact Hub](https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer)**
- 🏠 **[GitHub Repository](https://github.com/SolucTeam/SolucTeam-helm-charts)**
- 🌐 **[Helm Repository](https://solucteam.github.io/SolucTeam-helm-charts/)**

---

## 🤝 Support

- 📧 **Email** : k.aziz.k@live.fr
- 🐛 **Issues** : [GitHub Issues](https://github.com/SolucTeam/SolucTeam-helm-charts/issues)

---

## 📄 License

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](./LICENSE) pour plus de détails.

---

<div align="center">

**⭐ Si ce projet vous est utile, n'hésitez pas à lui donner une étoile !**

Made with ❤️ by [SolucTeam](https://github.com/SolucTeam)

</div>