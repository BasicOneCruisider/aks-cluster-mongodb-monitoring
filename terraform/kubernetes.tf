# ================================================================
# KUBERNETES & HELM RESOURCES
# ================================================================

# Namespace pour l'application rating
resource "kubernetes_namespace" "ratingapp" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "ratingapp"
    labels = {
      name        = "ratingapp"
      environment = "workshop"
      managed-by  = "terraform"
    }
    annotations = {
      "terraform.io/managed" = "true"
    }
  }
}

# Installation MongoDB via Helm
resource "helm_release" "mongodb" {
  depends_on = [
    kubernetes_namespace.ratingapp,
    azurerm_kubernetes_cluster.aks
  ]

  name       = "ratings"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "18.1.1" # Version fixe pour la reproductibilité
  namespace  = kubernetes_namespace.ratingapp.metadata[0].name

  values = [
    <<EOF
architecture: standalone

auth:
  enabled: ${var.mongodb_auth_enabled}
  rootUser: ${var.mongodb_root_user}

service:
  type: ClusterIP
  ports:
    mongodb: 27017

persistence:
  enabled: true
  size: ${var.mongodb_storage_size}
  storageClass: "managed-csi"

resources:
  limits:
    cpu: 750m
    memory: 768Mi
  requests:
    cpu: 500m
    memory: 512Mi

metrics:
  enabled: true
  prometheusRule:
    enabled: false

networkPolicy:
  enabled: false

podSecurityContext:
  enabled: true
  fsGroup: 1001

containerSecurityContext:
  enabled: true
  runAsUser: 1001
  runAsNonRoot: true

livenessProbe:
  enabled: true
  initialDelaySeconds: 30
  periodSeconds: 20
  timeoutSeconds: 10
  failureThreshold: 6

readinessProbe:
  enabled: true
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
EOF
  ]

  timeout         = 600
  wait            = true
  cleanup_on_fail = true

  set {
    name  = "fullnameOverride"
    value = "ratings-mongodb"
  }
}

# Secret personnalisé pour la connexion MongoDB
resource "kubernetes_secret" "mongo_secret" {
  depends_on = [kubernetes_namespace.ratingapp]

  metadata {
    name      = "mongosecret"
    namespace = kubernetes_namespace.ratingapp.metadata[0].name
    labels = {
      app        = "mongodb"
      managed-by = "terraform"
    }
  }

  type = "Opaque"

  data = {
    MONGOCONNECTION = "mongodb://Faris:Faris-2024@ratings-mongodb.ratingapp:27017/ratingapp"
  }
}
