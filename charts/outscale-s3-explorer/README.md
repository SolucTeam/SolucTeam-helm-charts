# ⛵ Outscale S3 Explorer - Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/outscale-s3-explorer)](https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.19+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-3.0+-0F1689?logo=helm&logoColor=white)](https://helm.sh/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Chart Helm officiel pour déployer **Outscale S3 Explorer** - une interface web moderne pour la gestion d'objets S3 compatible Outscale.

---

## 📋 Table des matières

- [Description](#-description)
- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Exemples d'utilisation](#-exemples-dutilisation)
- [Commandes utiles](#-commandes-utiles)
- [Dépannage](#-dépannage)
- [Sécurité](#-sécurité)
- [Support](#-support)

---

## 🎯 Description

**Outscale S3 Explorer** est une application web complète pour la gestion de stockage S3 compatible Outscale. Elle offre une interface utilisateur moderne construite avec React et TypeScript, packagée dans un conteneur Docker tout-en-un pour un déploiement Kubernetes simplifié.

### Stack technique

- ✨ **Frontend** : React 18 + Vite + TypeScript + Tailwind CSS
- 🔌 **Backend** : Proxy Node.js/Express pour l'API S3
- 🌐 **Serveur Web** : Nginx (reverse proxy + fichiers statiques)
- 🔒 **Sécurité** : Support TLS, SecurityContext, NetworkPolicies

---

## 🚀 Fonctionnalités

### Gestion S3

- 📦 **Buckets** : Création, suppression, listage
- 📁 **Navigation** : Exploration des dossiers et fichiers
- ⬆️ **Upload** : Téléversement avec barre de progression
- ⬇️ **Download** : Téléchargement d'objets
- 🗑️ **Suppression** : Gestion des objets et dossiers
- 🔍 **Recherche** : Filtrage et recherche rapide

### Multi-régions Outscale

Support natif des régions Outscale :
- 🇪🇺 `eu-west-2` (Paris)
- 🇫🇷 `cloudgouv-eu-west-1` (CloudGouv)
- 🇺🇸 `us-east-2` (Virginia)
- 🇺🇸 `us-west-1` (Californie)

### Haute disponibilité

- 📊 **Autoscaling** : HPA avec scaling automatique (3-20 pods)
- 🔄 **Réplication** : Déploiement multi-pods par défaut
- 💚 **Health Checks** : Liveness et Readiness probes
- 🎯 **Anti-affinity** : Distribution intelligente sur les nœuds
- 📈 **Monitoring** : Prêt pour Prometheus

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Ingress Controller                    │    │
│  │      https://outscale-s3-explorer.example.com      │    │
│  │              (NGINX/Traefik/ALB)                   │    │
│  └──────────────────────┬─────────────────────────────┘    │
│                         │ TLS                               │
│  ┌──────────────────────▼─────────────────────────────┐    │
│  │         Service (LoadBalancer/ClusterIP)           │    │
│  │              Port 80/443                           │    │
│  └──────────────────────┬─────────────────────────────┘    │
│                         │                                   │
│  ┌──────────────────────▼─────────────────────────────┐    │
│  │        Deployment - 3 Replicas (default)           │    │
│  │  ┌─────────────────────────────────────────────┐   │    │
│  │  │         Pod: outscale-s3-explorer           │   │    │
│  │  │  ┌───────────────────────────────────────┐  │   │    │
│  │  │  │   Nginx (Port 80)                    │  │   │    │
│  │  │  │   - Serve static files               │  │   │    │
│  │  │  │   - Reverse proxy to Express         │  │   │    │
│  │  │  │                                       │  │   │    │
│  │  │  │   ↓ /api/* → Express (Port 3001)     │  │   │    │
│  │  │  │                                       │  │   │    │
│  │  │  │   Node.js/Express                    │  │   │    │
│  │  │  │   - Proxy S3 API calls               │  │   │    │
│  │  │  │   - Handle authentication            │  │   │    │
│  │  │  └───────────────────────────────────────┘  │   │    │
│  │  └─────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │    Horizontal Pod Autoscaler (HPA)                 │    │
│  │    • Min Replicas: 3                               │    │
│  │    • Max Replicas: 20                              │    │
│  │    • Target CPU: 70%                               │    │
│  │    • Target Memory: 80%                            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│                         ↓                                   │
│                  Outscale OOS                               │
│              (eu-west-2, cloudgouv...)                      │
└─────────────────────────────────────────────────────────────┘
```

### Caractéristiques de l'architecture

- ✅ **Stateless** : Aucun PersistentVolume requis
- ✅ **localStorage** : Données utilisateur stockées côté navigateur
- ✅ **Conteneur tout-en-un** : Frontend + Backend + Nginx dans une seule image
- ✅ **Scalable** : Autoscaling horizontal automatique
- ✅ **Résilient** : Health checks et rolling updates

---

## ✅ Prérequis

### Versions minimales requises

| Composant | Version | Statut |
|-----------|---------|--------|
| **Kubernetes** | 1.19+ | ✅ Requis |
| **Helm** | 3.0+ | ✅ Requis |
| **kubectl** | 1.19+ | ✅ Requis |
| **Metrics Server** | - | ⚠️ Optionnel (requis pour HPA) |
| **Cert-Manager** | - | ⚠️ Optionnel (requis pour TLS auto) |

### Vérification de l'accès au cluster

```bash
# Vérifier la connexion au cluster
kubectl cluster-info
kubectl get nodes

# Vérifier Helm
helm version

# Vérifier les nodes disponibles
kubectl get nodes -o wide
```

---

## 📦 Installation

### Méthode 1 : Via Artifact Hub (Recommandée)

```bash
# Ajouter le repository Helm
helm repo add outscale-s3-explorer https://solucteam.github.io/outscale-s3-explorer/
helm repo update

# Installer le chart
helm install my-s3-explorer outscale-s3-explorer/outscale-s3-explorer \
  --namespace s3-explorer \
  --create-namespace

# Vérifier le déploiement
kubectl get pods -n s3-explorer
```

### Méthode 2 : Depuis les sources

```bash
# Cloner le repository
git clone https://github.com/SolucTeam/outscale-s3-explorer.git
cd outscale-s3-explorer/charts/outscale-s3-explorer

# Installer le chart
helm install outscale-s3-explorer . \
  --namespace s3-explorer \
  --create-namespace

# Vérifier l'installation
helm status outscale-s3-explorer -n s3-explorer
```

### Méthode 3 : Avec un fichier de valeurs personnalisé

```bash
# Créer votre fichier de configuration
cat > my-values.yaml <<EOF
image:
  repository: ghcr.io/solucteam/outscale-s3-explorer
  tag: "v1.0.0"

ingress:
  enabled: true
  hosts:
    - host: s3.mycompany.com
      paths:
        - path: /
          pathType: Prefix
EOF

# Installer avec les valeurs personnalisées
helm install outscale-s3-explorer . \
  -f my-values.yaml \
  --namespace s3-explorer \
  --create-namespace
```

### Vérification post-installation

```bash
# Statut du déploiement
helm status outscale-s3-explorer -n s3-explorer

# Vérifier les pods
kubectl get pods -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer

# Vérifier le service
kubectl get svc -n s3-explorer

# Vérifier l'ingress (si activé)
kubectl get ingress -n s3-explorer

# Voir les logs
kubectl logs -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer --tail=50
```

---

## ⚙️ Configuration

### Paramètres principaux

#### 🐳 Image Docker

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `image.repository` | string | Repository de l'image Docker | `ghcr.io/solucteam/outscale-s3-explorer` |
| `image.tag` | string | Tag de l'image | `v1.0.0` |
| `image.pullPolicy` | string | Politique de pull (`Always`, `IfNotPresent`, `Never`) | `IfNotPresent` |
| `imagePullSecrets` | array | Secrets pour registry privé | `[]` |

#### 🔄 Réplication et Scaling

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `replicaCount` | integer | Nombre de replicas (si HPA désactivé) | `3` |
| `autoscaling.enabled` | boolean | Activer HPA | `true` |
| `autoscaling.minReplicas` | integer | Nombre minimum de pods | `3` |
| `autoscaling.maxReplicas` | integer | Nombre maximum de pods | `20` |
| `autoscaling.targetCPUUtilizationPercentage` | integer | Seuil CPU pour scaling | `70` |
| `autoscaling.targetMemoryUtilizationPercentage` | integer | Seuil mémoire pour scaling | `80` |

#### 🌐 Service

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `service.type` | string | Type de service (`ClusterIP`, `NodePort`, `LoadBalancer`) | `LoadBalancer` |
| `service.port` | integer | Port du service | `80` |
| `service.annotations` | object | Annotations du service | `{}` |

#### 🌍 Ingress

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `ingress.enabled` | boolean | Activer l'Ingress | `true` |
| `ingress.className` | string | Classe de l'Ingress controller | `nginx` |
| `ingress.annotations` | object | Annotations Ingress | Voir values.yaml |
| `ingress.hosts[].host` | string | Nom d'hôte | `outscale-s3-explorer.production.com` |
| `ingress.tls[].secretName` | string | Secret TLS | `outscale-s3-explorer-tls` |
| `ingress.tls[].hosts` | array | Hosts couverts par TLS | `[outscale-s3-explorer.production.com]` |

#### 💾 Ressources

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `resources.requests.cpu` | string | CPU demandée | `500m` |
| `resources.requests.memory` | string | Mémoire demandée | `512Mi` |
| `resources.limits.cpu` | string | CPU maximale | `1000m` |
| `resources.limits.memory` | string | Mémoire maximale | `1Gi` |

#### 🔒 Sécurité

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `podSecurityContext.runAsNonRoot` | boolean | Exécuter en non-root | `true` |
| `podSecurityContext.runAsUser` | integer | User ID | `101` |
| `podSecurityContext.fsGroup` | integer | Filesystem group ID | `101` |
| `securityContext.allowPrivilegeEscalation` | boolean | Autoriser escalade de privilèges | `false` |
| `securityContext.readOnlyRootFilesystem` | boolean | Filesystem en lecture seule | `false` |
| `securityContext.capabilities.drop` | array | Capacités Linux à supprimer | `["ALL"]` |

#### 🩺 Health Checks

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `livenessProbe.initialDelaySeconds` | integer | Délai avant première vérification | `40` |
| `livenessProbe.periodSeconds` | integer | Intervalle entre vérifications | `30` |
| `livenessProbe.timeoutSeconds` | integer | Timeout de la probe | `10` |
| `readinessProbe.initialDelaySeconds` | integer | Délai avant première vérification | `10` |
| `readinessProbe.periodSeconds` | integer | Intervalle entre vérifications | `10` |
| `readinessProbe.timeoutSeconds` | integer | Timeout de la probe | `5` |

---

## 📚 Exemples d'utilisation

### 🏠 Environnement de développement

Configuration légère pour développement local :

```yaml
# values-dev.yaml
replicaCount: 1

image:
  repository: ghcr.io/solucteam/outscale-s3-explorer
  tag: dev
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: false

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 101
  fsGroup: 101
```

**Installation** :
```bash
helm install outscale-s3-explorer . \
  -f values-dev.yaml \
  -n dev \
  --create-namespace

# Accès local via port-forward
kubectl port-forward -n dev svc/outscale-s3-explorer 8080:80
# Ouvrir http://localhost:8080
```

### 🧪 Environnement de staging

Configuration intermédiaire pour tests :

```yaml
# values-staging.yaml
replicaCount: 2

image:
  repository: ghcr.io/solucteam/outscale-s3-explorer
  tag: "v1.0.0-rc1"
  pullPolicy: Always

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: staging-s3.mycompany.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: staging-s3-tls
      hosts:
        - staging-s3.mycompany.com

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

**Installation** :
```bash
helm install outscale-s3-explorer . \
  -f values-staging.yaml \
  -n staging \
  --create-namespace
```

### 🏭 Environnement de production

Configuration haute disponibilité pour production :

```yaml
# values-production.yaml
replicaCount: 5  # Utilisé uniquement si autoscaling.enabled=false

image:
  repository: ghcr.io/solucteam/outscale-s3-explorer
  tag: "v1.0.0"
  pullPolicy: Always

imagePullSecrets:
  - name: ghcr-secret

service:
  type: LoadBalancer
  port: 80
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/rate-limit: "100"
  hosts:
    - host: s3.mycompany.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: s3-mycompany-tls
      hosts:
        - s3.mycompany.com

resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 2Gi

autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

# Distribution multi-zones
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
                - outscale-s3-explorer
        topologyKey: topology.kubernetes.io/zone

topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: outscale-s3-explorer

# Monitoring Prometheus
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "80"
  prometheus.io/path: "/metrics"

# Sécurité renforcée
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 101
  fsGroup: 101
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 101
  capabilities:
    drop:
      - ALL
```

**Installation** :
```bash
# Créer le secret pour le registry privé (si nécessaire)
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<username> \
  --docker-password=<token> \
  -n production

# Installer le chart
helm install outscale-s3-explorer . \
  -f values-production.yaml \
  -n production \
  --create-namespace

# Vérifier le déploiement
kubectl rollout status deployment/outscale-s3-explorer -n production
```

### 🔐 Configuration avec Let's Encrypt

Certificats TLS automatiques avec Cert-Manager :

```yaml
# Prérequis: cert-manager installé
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

ingress:
  enabled: true
  className: "nginx"
  annotations:
    # Pour Let's Encrypt Production
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    # OU pour Let's Encrypt Staging (tests)
    # cert-manager.io/cluster-issuer: "letsencrypt-staging"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  hosts:
    - host: s3.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: s3-example-tls  # Cert-manager créera ce secret automatiquement
      hosts:
        - s3.example.com
```

### 📊 Monitoring avec Prometheus

Configuration pour scraping Prometheus :

```yaml
# Activer les annotations Prometheus
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "80"
  prometheus.io/path: "/metrics"

# Optionnel: ServiceMonitor pour Prometheus Operator
# Créer un fichier custom-servicemonitor.yaml:
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: outscale-s3-explorer
  namespace: s3-explorer
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: outscale-s3-explorer
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
```

---

## 🛠️ Commandes utiles

### Gestion du cycle de vie

```bash
# ============================================
# INSTALLATION
# ============================================

# Installation simple
helm install outscale-s3-explorer . -n s3-explorer --create-namespace

# Installation avec values custom
helm install outscale-s3-explorer . -f my-values.yaml -n s3-explorer --create-namespace

# Installation avec paramètres en ligne
helm install outscale-s3-explorer . \
  --set image.tag=v1.0.1 \
  --set replicaCount=5 \
  -n s3-explorer --create-namespace

# Dry-run (simulation)
helm install outscale-s3-explorer . --dry-run --debug -n s3-explorer

# ============================================
# MISE À JOUR
# ============================================

# Mise à jour simple
helm upgrade outscale-s3-explorer . -n s3-explorer

# Mise à jour avec nouveau fichier values
helm upgrade outscale-s3-explorer . -f my-values.yaml -n s3-explorer

# Mise à jour d'un paramètre spécifique
helm upgrade outscale-s3-explorer . --set image.tag=v1.0.2 -n s3-explorer

# Mise à jour avec réutilisation des valeurs précédentes
helm upgrade outscale-s3-explorer . --reuse-values -n s3-explorer

# ============================================
# ROLLBACK
# ============================================

# Voir l'historique des releases
helm history outscale-s3-explorer -n s3-explorer

# Rollback à la version précédente
helm rollback outscale-s3-explorer -n s3-explorer

# Rollback à une version spécifique
helm rollback outscale-s3-explorer 3 -n s3-explorer

# ============================================
# STATUT ET INFORMATION
# ============================================

# Voir le statut de la release
helm status outscale-s3-explorer -n s3-explorer

# Lister toutes les releases
helm list -n s3-explorer

# Obtenir les valeurs actuelles
helm get values outscale-s3-explorer -n s3-explorer

# Obtenir tous les manifests générés
helm get manifest outscale-s3-explorer -n s3-explorer

# ============================================
# DÉSINSTALLATION
# ============================================

# Désinstaller la release
helm uninstall outscale-s3-explorer -n s3-explorer

# Désinstaller en gardant l'historique
helm uninstall outscale-s3-explorer -n s3-explorer --keep-history
```

### Debugging et monitoring

```bash
# ============================================
# PODS
# ============================================

# Lister les pods
kubectl get pods -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer

# Détails d'un pod
kubectl describe pod <pod-name> -n s3-explorer

# Voir les logs
kubectl logs -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer --tail=100 -f

# Logs d'un pod spécifique
kubectl logs <pod-name> -n s3-explorer -f

# Exécuter une commande dans un pod
kubectl exec -it <pod-name> -n s3-explorer -- /bin/sh

# ============================================
# SERVICES ET INGRESS
# ============================================

# Voir le service
kubectl get svc -n s3-explorer

# Détails du service
kubectl describe svc outscale-s3-explorer -n s3-explorer

# Voir l'ingress
kubectl get ingress -n s3-explorer

# Détails de l'ingress
kubectl describe ingress outscale-s3-explorer -n s3-explorer

# ============================================
# MONITORING
# ============================================

# Utilisation des ressources (nécessite metrics-server)
kubectl top pods -n s3-explorer
kubectl top nodes

# Statut HPA
kubectl get hpa -n s3-explorer
kubectl describe hpa outscale-s3-explorer -n s3-explorer

# Événements du namespace
kubectl get events -n s3-explorer --sort-by='.lastTimestamp'

# Statut du déploiement
kubectl rollout status deployment/outscale-s3-explorer -n s3-explorer
kubectl rollout history deployment/outscale-s3-explorer -n s3-explorer

# ============================================
# ACCÈS À L'APPLICATION
# ============================================

# Port-forward pour accès local
kubectl port-forward -n s3-explorer svc/outscale-s3-explorer 8080:80
# Puis ouvrir http://localhost:8080

# Obtenir l'IP du LoadBalancer
kubectl get svc outscale-s3-explorer -n s3-explorer -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Obtenir l'URL de l'Ingress
kubectl get ingress outscale-s3-explorer -n s3-explorer -o jsonpath='{.spec.rules[0].host}'
```

### Validation et tests

```bash
# ============================================
# VALIDATION DU CHART
# ============================================

# Linter le chart
helm lint .

# Valider avec values custom
helm lint . -f values-production.yaml

# Dry-run complet
helm install test-release . --dry-run --debug -n test

# Générer les manifests sans installer
helm template outscale-s3-explorer . > manifests.yaml

# Générer avec values custom
helm template outscale-s3-explorer . -f my-values.yaml > manifests.yaml

# ============================================
# TESTS
# ============================================

# Tester la connectivité depuis un pod temporaire
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n s3-explorer -- \
  curl http://outscale-s3-explorer.s3-explorer.svc.cluster.local

# Vérifier les DNS
kubectl run -it --rm debug --image=busybox --restart=Never -n s3-explorer -- \
  nslookup outscale-s3-explorer.s3-explorer.svc.cluster.local

# Tester le health check
kubectl exec -it <pod-name> -n s3-explorer -- wget -qO- http://localhost:80/
```

---

## 🐛 Dépannage

### Problèmes courants

#### ❌ Pods en CrashLoopBackOff

**Symptômes** :
```bash
kubectl get pods -n s3-explorer
# NAME                                       READY   STATUS             RESTARTS
# outscale-s3-explorer-xxx                   0/1     CrashLoopBackOff   5
```

**Diagnostic** :
```bash
# 1. Voir les logs du pod
kubectl logs <pod-name> -n s3-explorer --previous

# 2. Décrire le pod pour voir les events
kubectl describe pod <pod-name> -n s3-explorer

# 3. Vérifier l'image
kubectl get pod <pod-name> -n s3-explorer -o jsonpath='{.spec.containers[*].image}'
```

**Solutions courantes** :
- ✅ Vérifier que l'image existe dans le registry
- ✅ Vérifier les credentials (`imagePullSecrets`)
- ✅ Augmenter les ressources si `OOMKilled`
- ✅ Vérifier la configuration de l'application

#### ❌ ImagePullBackOff

**Symptômes** :
```bash
kubectl get pods -n s3-explorer
# NAME                                       READY   STATUS              RESTARTS
# outscale-s3-explorer-xxx                   0/1     ImagePullBackOff    0
```

**Solutions** :
```bash
# 1. Vérifier les events
kubectl describe pod <pod-name> -n s3-explorer

# 2. Créer un secret pour registry privé
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<username> \
  --docker-password=<token> \
  -n s3-explorer

# 3. Mettre à jour values.yaml
cat >> values.yaml <<EOF
imagePullSecrets:
  - name: ghcr-secret
EOF

# 4. Upgrade la release
helm upgrade outscale-s3-explorer . -f values.yaml -n s3-explorer
```

#### ⚠️ Health checks échouent

**Symptômes** :
- Pods en état `Running` mais pas `READY`
- Restarts fréquents

**Diagnostic** :
```bash
# Vérifier les probes
kubectl describe pod <pod-name> -n s3-explorer | grep -A 10 "Liveness\|Readiness"

# Tester manuellement
kubectl exec <pod-name> -n s3-explorer -- wget -qO- http://localhost:80/
```

**Solutions** :
```yaml
# Augmenter les délais dans values.yaml
livenessProbe:
  initialDelaySeconds: 60  # Au lieu de 40
  periodSeconds: 30
  timeoutSeconds: 15
  failureThreshold: 5

readinessProbe:
  initialDelaySeconds: 20  # Au lieu de 10
  periodSeconds: 10
  timeoutSeconds: 10
  failureThreshold: 3
```

```bash
# Appliquer les changements
helm upgrade outscale-s3-explorer . -f values.yaml -n s3-explorer
```

#### 🌐 Impossible d'accéder via Ingress

**Diagnostic** :
```bash
# 1. Vérifier l'Ingress
kubectl get ingress -n s3-explorer
kubectl describe ingress outscale-s3-explorer -n s3-explorer

# 2. Vérifier le service
kubectl get svc outscale-s3-explorer -n s3-explorer

# 3. Vérifier l'Ingress Controller
kubectl get pods -n ingress-nginx  # Pour NGINX
kubectl logs -n ingress-nginx <ingress-controller-pod>

# 4. Tester le service directement
kubectl port-forward svc/outscale-s3-explorer 8080:80 -n s3-explorer
# Ouvrir http://localhost:8080
```

**Solutions** :
```bash
# Vérifier le DNS
nslookup s3.mycompany.com

# Vérifier les annotations
kubectl get ingress outscale-s3-explorer -n s3-explorer -o yaml

# Re-créer l'Ingress
kubectl delete ingress outscale-s3-explorer -n s3-explorer
helm upgrade outscale-s3-explorer . -n s3-explorer
```

#### 📈 HPA ne scale pas

**Diagnostic** :
```bash
# Vérifier le HPA
kubectl get hpa -n s3-explorer
kubectl describe hpa outscale-s3-explorer -n s3-explorer

# Vérifier Metrics Server
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods -n s3-explorer
```

**Solutions** :
```bash
# Installer Metrics Server si absent
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Vérifier que les ressources sont définies dans values.yaml
# (Le HPA nécessite resources.requests)
```

#### 🔒 Erreurs de permissions

**Symptômes** :
- Erreurs `Permission denied` dans les logs
- Pods qui ne peuvent pas écrire

**Solutions** :
```yaml
# Ajuster le SecurityContext dans values.yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 101
  fsGroup: 101

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false  # Changer en false si nécessaire
  capabilities:
    drop:
      - ALL
```

---

## 🔒 Sécurité

### Bonnes pratiques implémentées

#### 🛡️ Container Security

- ✅ **Non-root user** : L'application s'exécute avec l'UID 101 (nginx)
- ✅ **Read-only filesystem** : Option disponible (désactivée par défaut pour compatibilité)
- ✅ **Dropped capabilities** : Toutes les capacités Linux sont supprimées
- ✅ **No privilege escalation** : `allowPrivilegeEscalation: false`

#### 🌐 Network Security

```yaml
# NetworkPolicy exemple (à adapter selon vos besoins)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: outscale-s3-explorer-netpol
  namespace: s3-explorer
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: outscale-s3-explorer
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
      ports:
        - protocol: TCP
          port: 80
  egress:
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 53  # DNS
    - to:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: 443  # Outscale API
```

#### 🔐 TLS/SSL

Configuration avec Cert-Manager pour Let's Encrypt :

```yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  tls:
    - secretName: outscale-s3-explorer-tls
      hosts:
        - s3.mycompany.com
```

#### 🔑 Secrets Management

**Recommandations** :
- Utiliser [External Secrets Operator](https://external-secrets.io/) pour gérer les credentials
- Ne jamais commiter de credentials dans les values files
- Utiliser des outils comme [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) ou [SOPS](https://github.com/mozilla/sops)

Exemple avec External Secrets :
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: outscale-s3-explorer-secrets
  namespace: s3-explorer
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: outscale-s3-credentials
  data:
    - secretKey: accessKey
      remoteRef:
        key: secret/outscale/s3
        property: accessKey
    - secretKey: secretKey
      remoteRef:
        key: secret/outscale/s3
        property: secretKey
```

### Scan de sécurité

```bash
# Scanner l'image Docker avec Trivy
trivy image ghcr.io/solucteam/outscale-s3-explorer:v1.0.0

# Scanner les manifests Kubernetes
helm template outscale-s3-explorer . | kubesec scan -

# Scanner avec Checkov
helm template outscale-s3-explorer . | checkov -f -
```

---

## 📊 Monitoring et Observabilité

### Métriques Prometheus

L'application expose des métriques au format Prometheus :

```yaml
# Configuration dans values.yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "80"
  prometheus.io/path: "/metrics"
```

**Métriques disponibles** :
- `http_requests_total` : Nombre total de requêtes HTTP
- `http_request_duration_seconds` : Durée des requêtes
- `nodejs_memory_usage_bytes` : Utilisation mémoire Node.js
- `nginx_connections_active` : Connexions Nginx actives

### Dashboard Grafana

Exemple de dashboard Grafana (à importer) :

```json
{
  "dashboard": {
    "title": "Outscale S3 Explorer",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Pod CPU Usage",
        "targets": [
          {
            "expr": "container_cpu_usage_seconds_total{namespace='s3-explorer'}"
          }
        ]
      }
    ]
  }
}
```

### Logs

```bash
# Logs en temps réel
kubectl logs -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer -f --tail=100

# Logs avec horodatage
kubectl logs -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer --timestamps=true

# Exporter les logs
kubectl logs -n s3-explorer -l app.kubernetes.io/name=outscale-s3-explorer > app.log
```

### Tracing (optionnel)

Intégration avec Jaeger/Zipkin possible via OpenTelemetry.

---

## 🚀 Performance

### Optimisations recommandées

#### Resource Limits

```yaml
# Pour haute charge
resources:
  requests:
    cpu: 1000m
    memory: 1Gi
  limits:
    cpu: 4000m
    memory: 4Gi
```

#### Autoscaling agressif

```yaml
autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 50
  targetCPUUtilizationPercentage: 60
  targetMemoryUtilizationPercentage: 70
```

#### Cache et CDN

Pour améliorer les performances, considérez :
- CloudFlare ou AWS CloudFront devant l'application
- Redis pour le cache des métadonnées S3
- CDN pour les assets statiques

---

## 📖 Documentation complémentaire

- 📘 **[Changelog](./Changelog.md)** - Historique des versions
- 🔧 **[Values Schema](./values.schema.json)** - Validation des paramètres
- 🏗️ **[Architecture](../../docs/ARCHITECTURE.md)** - Architecture détaillée
- 🐳 **[Dockerfile](../../Dockerfile)** - Build de l'image Docker
- 🔐 **[Security](../../docs/SECURITY.md)** - Guide de sécurité
- 📊 **[Monitoring](../../docs/MONITORING.md)** - Guide de monitoring

---

## 🤝 Support et Contribution

### Obtenir de l'aide

- 💬 **Discord** : [Rejoindre le serveur](https://discord.gg/solucteam)
- 📧 **Email** : <support@solucteam.com>
- 🐛 **Issues** : [GitHub Issues](https://github.com/SolucTeam/outscale-s3-explorer/issues)
- 📖 **Documentation** : [Wiki](https://github.com/SolucTeam/outscale-s3-explorer/wiki)

### Contribuer

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](../../CONTRIBUTING.md) pour les guidelines.

```bash
# Fork le projet
git clone https://github.com/<votre-username>/outscale-s3-explorer.git
cd outscale-s3-explorer

# Créer une branche
git checkout -b feature/ma-fonctionnalite

# Faire vos modifications
# ...

# Commit et push
git commit -m "feat: ajout de ma fonctionnalité"
git push origin feature/ma-fonctionnalite

# Créer une Pull Request sur GitHub
```

---

## 📄 License

Ce projet est sous licence **Apache 2.0**. Voir le fichier [LICENSE](../../LICENSE) pour plus de détails.

```
Copyright 2025 SolucTeam

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 🙏 Remerciements

- [Helm](https://helm.sh/) - Le gestionnaire de packages pour Kubernetes
- [Kubernetes](https://kubernetes.io/) - Orchestrateur de conteneurs
- [Outscale](https://outscale.com/) - Cloud Provider
- [NGINX](https://nginx.org/) - Serveur web haute performance
- [React](https://react.dev/) - Framework UI
- [Vite](https://vitejs.dev/) - Build tool

---

<div align="center">

**⭐ Si ce projet vous est utile, n'hésitez pas à lui donner une étoile sur GitHub !**

Made with ❤️ by [SolucTeam](https://github.com/SolucTeam)

</div>