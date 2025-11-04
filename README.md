# Projet de Monitoring — TIG Stack (Telegraf, InfluxDB, Grafana)

## Objectif

Déployer une solution de monitoring complète pour un système Linux à l’aide de la **stack TIG** :

* **Telegraf** : collecte des métriques (CPU, mémoire, swap, etc.)
* **InfluxDB** : stocke les séries temporelles
* **Grafana** : visualise les données via des tableaux de bord dynamiques

---

## Architecture

```
[Linux System]
      │
      ▼
+-------------+
|  Telegraf   | → collecte CPU / RAM toutes les 10s
+-------------+
      │ (HTTP)
      ▼
+-------------+
|  InfluxDB   | → stocke les mesures dans la DB "telegraf"
+-------------+
      │ (HTTP)
      ▼
+-------------+
|  Grafana    | → visualise les métriques via dashboard
+-------------+
```

---

## Aperçus

### Conteneurs Docker

![Docker containers](docker.png)

### Tableau de bord Grafana

![Dashboard Grafana](grafana/dashboards/dashboard.png)

---

## Structure du projet

```
HEH_MONITOR_DOCKER/
├─ grafana/
│  ├─ dashboards/
│  │  ├─ dashboard.png
│  │  └─ telegraf-cpu-mem.json
│  ├─ provisioning/
│  │  ├─ datasources/
│  │  │  └─ influxdb.yaml
│  │  └─ dashboards/
│  │     └─ dashboards.yaml
├─ scripts/
│  └─ create-influx-db.sh
├─ telegraf/
│  └─ telegraf.conf
├─ docker-compose.yml
├─ docker.png
├─ ProjetMonitoring.pdf
└─ README.md
```

---

## Installation et exécution

### 1. Prérequis

* **Docker Desktop** ou **Docker Engine + Compose**
* Ports disponibles : `8086` (InfluxDB) et `3000` (Grafana)

### 2. Démarrage

```bash
docker compose up -d
```

### 3. Création de la base de données

```bash
docker exec -it influxdb influx -execute "CREATE DATABASE telegraf"
```

### 4. Vérification de la collecte

```bash
docker logs -f telegraf
# Doit afficher des lignes: "Wrote batch of X metrics"
```

### 5. Vérification du stockage

```bash
docker exec -it influxdb influx -execute "SHOW MEASUREMENTS ON telegraf"
# Résultat attendu : cpu, mem
```

---

## Accès à Grafana

Ouvrir : [http://localhost:3000](http://localhost:3000)
**Identifiants par défaut :**

```
admin / admin
```

La datasource **InfluxDB** est déjà configurée grâce au provisioning :

```yaml
url: http://influxdb:8086
database: telegraf
```

---

## Tableau de bord Grafana

Nom : **MonitoringDashboard**

### Panneaux inclus :

1. **CPU** — graphique de l’utilisation moyenne :

   ```sql
   SELECT mean("usage_idle") FROM "cpu" WHERE $timeFilter GROUP BY time($__interval) fill(null)
   ```
2. **Mémoire (graphique)** — évolution temporelle :

   ```sql
   SELECT mean("used_percent") FROM "mem" WHERE $timeFilter GROUP BY time($__interval) fill(null)
   ```
3. **Mémoire (jauge)** — pourcentage d’utilisation instantané.

---

## Commandes utiles

| Action                     | Commande                           |
| -------------------------- | ---------------------------------- |
| Démarrer                   | `docker compose up -d`             |
| Arrêter                    | `docker compose down`              |
| Voir les logs d’un service | `docker logs -f <service>`         |
| Recréer un conteneur       | `docker compose restart <service>` |
| Supprimer les volumes      | `docker compose down -v`           |

---

## Résumé du fonctionnement

1. **Telegraf** interroge le système toutes les 10 s.
2. Les métriques sont stockées dans **InfluxDB** (base `telegraf`).
3. **Grafana** interroge cette base et met à jour le tableau de bord.
4. L’ensemble fonctionne de manière autonome via **Docker Compose**.

---

## Auteur

Projet scolaire réalisé par **Tom Deneyer**
HEH — Bachelor 3 Informatique
Versions utilisées :

* Telegraf : 1.30.3
* InfluxDB : 1.8.10
* Grafana : 12.2.1
