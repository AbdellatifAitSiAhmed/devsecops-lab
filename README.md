# 🔐 DevSecOps Lab — ENSA Marrakech

> Infrastructure DevSecOps complète : containerisation, orchestration Kubernetes, pipeline CI/CD sécurisé, VPN WireGuard et monitoring Prometheus/Grafana.

**Module** : Durcissement Système et Sécurité des Données  
**Filière** : GCDSTE — Génie Cyber-Défense et Systèmes de Télécommunications Embarqués  
**Établissement** : ENSA Marrakech | Année universitaire 2025/2026

---

## 👥 Équipe

| Membre | VM | IP VPN |
|--------|----|--------|
| Abdellatif AIT SI AHMED | `asa@asa` (Ubuntu 24.04) | `10.8.0.2` |
| Lahsen AIT OIHMANE | `ubuntu@ubuntu-box` (Ubuntu 24.04) | `10.8.0.3` |
| VPS DigitalOcean | Serveur Cloud | `10.8.0.1` |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Actions CI/CD                   │
│         GitLeaks → Trivy → Integration Tests            │
└─────────────────────────────────────────────────────────┘
                          │
              ┌───────────▼───────────┐
              │   Docker Compose      │
              │   (Local / VPS)       │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  Kubernetes (Minikube) │
              │   namespace: lab-network│
              └───────────┬───────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌────▼────┐      ┌─────▼─────┐    ┌──────▼──────┐
   │  SSH    │      │    DNS    │    │     FTP     │
   │OpenSSH  │      │  BIND9    │    │  ProFTPD+TLS│
   │Port 2222│      │Port 5454  │    │   Port 21   │
   └─────────┘      └───────────┘    └─────────────┘
        │
   ┌────▼────┐      ┌───────────┐
   │  MySQL  │      │   DHCP    │
   │  8.0    │      │  ISC DHCP │
   │labdb    │      │172.20.0/24│
   └─────────┘      └───────────┘
```

---

## 📦 Services déployés

| Service | Image | Port | Technologie |
|---------|-------|------|-------------|
| SSH | `devsecops-lab-ssh-server` | 2222 / NodePort 30022 | OpenSSH + ED25519 |
| DNS | `devsecops-lab-dns-server` | 5454 / NodePort 30053 | BIND9 + zone lab.local |
| FTP | `devsecops-lab-ftp-server` | 21 / NodePort 30021 | ProFTPD + TLS |
| MySQL | `mysql:8.0` | 3306 / NodePort 30306 | Base `labdb` + Secrets |
| DHCP | `devsecops-lab-dhcp` | — | ISC DHCP 172.20.0.0/24 |

---

## 🚀 Lancement rapide

### Docker Compose (local)

```bash
# Cloner le repo
git clone https://github.com/AbdellatifAitSiAhmed/devsecops-lab.git
cd devsecops-lab

# Créer les secrets (remplace par tes propres mots de passe)
mkdir -p sql/secrets
echo "${MYSQL_ROOT_PASSWORD}" > sql/secrets/root_password.txt
echo "${MYSQL_USER_PASSWORD}" > sql/secrets/user_password.txt

# Lancer tous les services
docker compose up -d

# Vérifier
docker compose ps
```

### Kubernetes (Minikube)

```bash
# Démarrer Minikube avec registry locale
minikube start
minikube addons enable registry

# Construire et pousser les images
docker build -t localhost:5000/devsecops-lab-ssh-server ./ssh
docker push localhost:5000/devsecops-lab-ssh-server

# Déployer
kubectl apply -f k8s/
kubectl get pods -n lab-network
```

---

## 🔒 Sécurité CI/CD

Le pipeline GitHub Actions (`.github/workflows/pipeline.yml`) exécute 3 jobs séquentiels à chaque push sur `master` :

```
Job 1 — Secret Detection (GitLeaks)
    └── Scan du repo pour clés API, mots de passe exposés
          ↓ (0 secret détecté ✅)
Job 2 — Vulnerability Scan (Trivy 0.70.0)
    └── Scan images SSH, DNS, FTP → exit-code 1 si CVE CRITICAL
          ↓ (0 CVE critique ✅)
Job 3 — Integration Tests
    └── docker compose up → tests SSH/DNS/FTP/MySQL fonctionnels
          ↓ (tous les services répondent ✅)
```

---

## 🌐 VPN WireGuard

Tunnel chiffré entre les deux VMs via un VPS DigitalOcean (port 51820) :

```
VM Abdellatif (10.8.0.2) ──── WireGuard ────┐
                                              ├── VPS (10.8.0.1)
VM Lahsen      (10.8.0.3) ── WireGuard ─────┘
```

- Protocole : WireGuard (Curve25519 + ChaCha20 + Poly1305)
- Latence : ~87ms (10.8.0.1) | ~168ms (10.8.0.3)
- Perte de paquets : **0%** (validé avec `ping -c 3`)

---

## 📊 Monitoring

Stack **kube-prometheus-stack** déployée via Helm dans le namespace `monitoring` :

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=${GRAFANA_ADMIN_PASSWORD}
```

- **Prometheus** : collecte métriques en mode pull
- **Grafana** : dashboards temps réel (CPU 63.5% | RAM 44.6%)
- **AlertManager** : gestion des alertes

---

## 📁 Structure du projet

```
devsecops-lab/
├── .github/
│   └── workflows/
│       └── pipeline.yml        # CI/CD GitHub Actions
├── ssh/
│   ├── Dockerfile              # OpenSSH + ED25519 + PermitRootLogin no
│   └── sshd_config
├── dns/
│   ├── Dockerfile              # BIND9 + zone lab.local
│   └── named.conf
├── ftp/
│   ├── Dockerfile              # ProFTPD + TLS
│   └── proftpd.conf
├── dhcp/
│   ├── Dockerfile              # ISC DHCP 172.20.0.0/24
│   └── dhcpd.conf
├── sql/
│   ├── init.sql                # Création base labdb + table services
│   └── secrets/                # Exclus du repo (.gitignore)
├── k8s/
│   ├── namespace.yaml
│   ├── ssh-deployment.yaml
│   ├── dns-deployment.yaml
│   ├── ftp-deployment.yaml
│   └── mysql-statefulset.yaml
├── vpn/
│   └── wg0-server.conf         # Config WireGuard VPS
├── docker-compose.yml
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🔑 Sécurité des secrets

Les données sensibles sont **exclues du dépôt** via `.gitignore` :

```gitignore
sql/secrets/
ssh/keys/
vpn/*.conf
*.pem
*.key
```

Gestion runtime via **Docker Secrets** et **Kubernetes Secrets** :
- Mots de passe MySQL injectés via `/run/secrets/`
- Clés SSH montées en volume read-only

---

## ✅ Résultats de validation

| Test | Résultat |
|------|----------|
| GitLeaks (secrets) | ✅ 0 secret détecté |
| Trivy SSH image | ✅ 0 CVE CRITICAL |
| Trivy DNS image | ✅ 0 CVE CRITICAL |
| Trivy FTP image | ✅ 0 CVE CRITICAL |
| SSH connexion ED25519 | ✅ Validé |
| DNS résolution lab.local | ✅ Validé |
| FTP TLS (226 Transfer complete) | ✅ Validé |
| MySQL SELECT services | ✅ SSH/DNS/FTP/DHCP visibles |
| WireGuard ping 0% loss | ✅ Validé |
| Kubernetes 4 pods Running | ✅ Validé |
| Grafana CPU/RAM metrics | ✅ 63.5% / 44.6% |

---

## 🛠️ Technologies utilisées

![Docker](https://img.shields.io/badge/Docker-29.4.3-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Minikube_v1.38.1-326CE5?logo=kubernetes&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions&logoColor=white)
![WireGuard](https://img.shields.io/badge/WireGuard-VPN-88171A?logo=wireguard&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-Dashboards-F46800?logo=grafana&logoColor=white)
