#!/bin/bash

# ============================================
# Script de release automatique du Helm Chart
# ============================================

set -e  # Arrêter en cas d'erreur

CHART_DIR="charts/outscale-s3-explorer"
CHART_YAML="$CHART_DIR/Chart.yaml"
CHANGELOG="$CHART_DIR/Changelog.md"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

show_help() {
    cat << EOF
${BLUE}╔════════════════════════════════════════════════════════════╗
║  Outscale S3 Explorer - Script de Release                 ║
╚════════════════════════════════════════════════════════════╝${NC}

${GREEN}Usage:${NC}
    ./release.sh [VERSION] [OPTIONS]

${GREEN}Arguments:${NC}
    VERSION              Version à release (ex: 0.1.1, 1.0.0)
                        Peut aussi être: patch, minor, major

${GREEN}Options:${NC}
    ${YELLOW}-m, --message MSG${NC}       Message de commit personnalisé
    ${YELLOW}-d, --dry-run${NC}           Simuler sans commit/push
    ${YELLOW}-s, --skip-validation${NC}   Skip la validation Helm
    ${YELLOW}-h, --help${NC}              Afficher cette aide

${GREEN}Exemples:${NC}
    ${CYAN}# Release version spécifique${NC}
    ./release.sh 0.1.1

    ${CYAN}# Release patch (0.1.0 → 0.1.1)${NC}
    ./release.sh patch

    ${CYAN}# Release minor (0.1.1 → 0.2.0)${NC}
    ./release.sh minor

    ${CYAN}# Release major (0.2.0 → 1.0.0)${NC}
    ./release.sh major

    ${CYAN}# Dry-run pour tester${NC}
    ./release.sh 0.1.1 --dry-run

    ${CYAN}# Avec message custom${NC}
    ./release.sh patch -m "Fix authentication bug"

EOF
}

# Fonction pour obtenir la version actuelle
get_current_version() {
    grep "^version:" "$CHART_YAML" | awk '{print $2}'
}

# Fonction pour bumper la version
bump_version() {
    local current=$1
    local type=$2
    
    IFS='.' read -ra VERSION_PARTS <<< "$current"
    local major="${VERSION_PARTS[0]}"
    local minor="${VERSION_PARTS[1]}"
    local patch="${VERSION_PARTS[2]}"
    
    case $type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Parse des arguments
NEW_VERSION=""
COMMIT_MESSAGE=""
DRY_RUN=false
SKIP_VALIDATION=false

if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--message)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        patch|minor|major)
            BUMP_TYPE="$1"
            shift
            ;;
        *)
            if [ -z "$NEW_VERSION" ]; then
                NEW_VERSION="$1"
            else
                log_error "Argument inconnu: $1"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# ============================================
# Vérifications préliminaires
# ============================================

log_header "🔍 Vérifications préliminaires"

# Vérifier que nous sommes sur main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    log_error "Vous devez être sur la branche 'main'"
    echo "  Branche actuelle: $CURRENT_BRANCH"
    exit 1
fi
log_info "Branche: $CURRENT_BRANCH"

# Vérifier qu'il n'y a pas de modifications non committées
if ! git diff-index --quiet HEAD --; then
    log_error "Il y a des modifications non committées"
    echo "  Veuillez commit ou stash vos modifications"
    git status --short
    exit 1
fi
log_info "Aucune modification non committée"

# Vérifier que le chart existe
if [ ! -f "$CHART_YAML" ]; then
    log_error "Fichier Chart.yaml introuvable: $CHART_YAML"
    exit 1
fi
log_info "Chart trouvé: $CHART_DIR"

# ============================================
# Calcul de la version
# ============================================

log_header "📊 Version"

CURRENT_VERSION=$(get_current_version)
log_info "Version actuelle: $CURRENT_VERSION"

# Si bump type (patch/minor/major), calculer la nouvelle version
if [ -n "$BUMP_TYPE" ]; then
    NEW_VERSION=$(bump_version "$CURRENT_VERSION" "$BUMP_TYPE")
    log_info "Bump type: $BUMP_TYPE"
fi

if [ -z "$NEW_VERSION" ]; then
    log_error "Aucune version spécifiée"
    show_help
    exit 1
fi

log_info "Nouvelle version: ${GREEN}$NEW_VERSION${NC}"

# Vérifier que la nouvelle version est supérieure
if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
    log_error "La nouvelle version doit être différente de l'actuelle"
    exit 1
fi

# ============================================
# Validation du chart
# ============================================

if [ "$SKIP_VALIDATION" = false ]; then
    log_header "✅ Validation du chart"
    
    if ! command -v helm &> /dev/null; then
        log_error "Helm n'est pas installé"
        exit 1
    fi
    
    log_info "Lint du chart..."
    if helm lint "$CHART_DIR"; then
        log_info "Chart valide"
    else
        log_error "La validation a échoué"
        exit 1
    fi
    
    log_info "Test du template..."
    helm template test "$CHART_DIR" > /dev/null
    log_info "Template valide"
else
    log_warn "Validation skippée"
fi

# ============================================
# Mise à jour des fichiers
# ============================================

if [ "$DRY_RUN" = false ]; then
    log_header "📝 Mise à jour des fichiers"
    
    # Mise à jour Chart.yaml
    log_info "Mise à jour de Chart.yaml..."
    sed -i.bak "s/^version: .*/version: $NEW_VERSION/" "$CHART_YAML"
    rm "${CHART_YAML}.bak"
    
    # Mise à jour du Changelog
    log_info "Mise à jour du Changelog..."
    DATE=$(date +%Y-%m-%d)
    TEMP_CHANGELOG=$(mktemp)
    
    cat > "$TEMP_CHANGELOG" << EOF
# Changelog

Toutes les modifications notables de ce chart Helm seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### À venir
- Support des métriques Prometheus
- Dashboards Grafana
- Support des secrets externes (External Secrets Operator)

---

## [$NEW_VERSION] - $DATE

### Changed
EOF
    
    if [ -n "$COMMIT_MESSAGE" ]; then
        echo "- $COMMIT_MESSAGE" >> "$TEMP_CHANGELOG"
    else
        echo "- Version bump to $NEW_VERSION" >> "$TEMP_CHANGELOG"
    fi
    
    echo "" >> "$TEMP_CHANGELOG"
    
    # Copier le reste du changelog (en ignorant la première section)
    if [ -f "$CHANGELOG" ]; then
        awk '/^## \[0\.1\.0\]/{flag=1} flag' "$CHANGELOG" >> "$TEMP_CHANGELOG"
    fi
    
    mv "$TEMP_CHANGELOG" "$CHANGELOG"
    
    log_info "Fichiers mis à jour"
fi

# ============================================
# Résumé des changements
# ============================================

log_header "📋 Résumé"

cat << EOF
  ${CYAN}Chart:${NC}              outscale-s3-explorer
  ${CYAN}Version actuelle:${NC}   $CURRENT_VERSION
  ${CYAN}Nouvelle version:${NC}   ${GREEN}$NEW_VERSION${NC}
  ${CYAN}Branche:${NC}            $CURRENT_BRANCH
  ${CYAN}Dry-run:${NC}            $DRY_RUN
EOF

if [ -n "$COMMIT_MESSAGE" ]; then
    echo -e "  ${CYAN}Message:${NC}            $COMMIT_MESSAGE"
fi

echo ""

# ============================================
# Confirmation
# ============================================

if [ "$DRY_RUN" = false ]; then
    read -p "Confirmer la release de la version $NEW_VERSION ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Release annulée"
        exit 0
    fi
fi

# ============================================
# Commit et push
# ============================================

if [ "$DRY_RUN" = false ]; then
    log_header "🚀 Release"
    
    # Commit
    log_info "Création du commit..."
    if [ -n "$COMMIT_MESSAGE" ]; then
        FULL_COMMIT_MESSAGE="chore: release version $NEW_VERSION

$COMMIT_MESSAGE"
    else
        FULL_COMMIT_MESSAGE="chore: release version $NEW_VERSION"
    fi
    
    git add "$CHART_YAML" "$CHANGELOG"
    git commit -m "$FULL_COMMIT_MESSAGE"
    
    log_info "Commit créé: $(git rev-parse --short HEAD)"
    
    # Push
    log_info "Push vers origin/main..."
    git push origin main
    
    log_info "Release poussée avec succès! 🎉"
    
    echo ""
    log_header "✅ Prochaines étapes"
    cat << EOF
  1. ${CYAN}Vérifier le workflow GitHub Actions${NC}
     https://github.com/SolucTeam/SolucTeam-helm-charts/actions

  2. ${CYAN}Attendre la création de la release${NC}
     https://github.com/SolucTeam/SolucTeam-helm-charts/releases

  3. ${CYAN}Vérifier GitHub Pages (après ~2 min)${NC}
     https://solucteam.github.io/SolucTeam-helm-charts/index.yaml

  4. ${CYAN}Tester l'installation${NC}
     helm repo update
     helm search repo outscale-s3-explorer
     helm install test outscale-s3-explorer/outscale-s3-explorer --version $NEW_VERSION

  5. ${CYAN}Vérifier Artifact Hub (après ~30 min)${NC}
     https://artifacthub.io/packages/helm/outscale-s3-explorer/outscale-s3-explorer

EOF
else
    log_header "🧪 Mode Dry-Run"
    log_info "Aucune modification effectuée"
    log_info "Les fichiers suivants auraient été modifiés:"
    echo "  - $CHART_YAML"
    echo "  - $CHANGELOG"
fi

echo ""
log_info "Script terminé!"