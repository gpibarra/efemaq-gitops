# Ansible Deployment - Docker Swarm, Portainer & Traefik

Este repositorio contiene la configuración de Ansible para el despliegue automatizado de servidores con Docker Swarm, Portainer y Traefik siguiendo las mejores prácticas de GitOps.

## Tabla de Contenidos

- [Inicio Rápido](#inicio-rápido)
  - [Configuración Inicial (Bootstrap)](#configuración-inicial-de-servidores-nuevos)
  - [Provisioning Rápido](#provisioning-rápido-después-del-bootstrap)
- [Requisitos Previos](#requisitos-previos)
- [Configuración del Inventario](#configuración-del-inventario)
- [Uso](#uso)
  - [Despliegue Completo](#despliegue-completo)
  - [Despliegue por Componentes](#despliegue-por-componentes-tags)
  - [Estadísticas del Servidor](#estadísticas-del-servidor)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Componentes Desplegados](#componentes-desplegados)
  - [Docker](#1-docker)
  - [Docker Swarm](#2-docker-swarm)
  - [Portainer](#3-portainer)
  - [Traefik](#4-traefik)
- [Verificación Post-Despliegue](#verificación-post-despliegue)
- [Workflow GitOps Completo](#workflow-gitops-completo)
- [Troubleshooting](#troubleshooting)
- [Personalización](#personalización)
  - [Configuración de Traefik](#configurar-traefik-con-lets-encrypt)
- [Mantenimiento](#mantenimiento)
- [Ejemplos de Uso con Traefik](#ejemplos-de-uso-con-traefik)
- [Mejores Prácticas](#mejores-prácticas)
- [Seguridad](#seguridad)

## Documentación

Asegurarse que Ansible y Python estén instalados: Ver [setup_ubuntu.sh](setup_ubuntu.sh) o [setup_macos.sh](setup_macos.sh) para detalles.

Asegurarse las dependencias de Ansible y Python estén satisfechas. Ver [setup.sh](setup.sh) para detalles.

## Inicio Rápido

### Configuración Inicial de Servidores Nuevos

**¿Es la primera vez que configuras el servidor?** Primero necesitas crear el usuario `efemaq` y configurar el acceso SSH:

**Ver [BOOTSTRAP.md](BOOTSTRAP.md)** para la guía completa de configuración inicial

El proceso de bootstrap:

1. Crea el usuario `efemaq`
2. Configura las claves SSH
3. Establece sudo sin contraseña

Una vez completado el bootstrap, continúa con esta guía para el provisioning normal.

### Provisioning Rápido (después del bootstrap)

```bash
# Para Test
ansible-playbook -i inventories/test/hosts.yml ./provision/site.yml

# Para Producción
ansible-playbook -i inventories/production/hosts.yml ./provision/site.yml
```

## Requisitos Previos

### En tu máquina local:

1. **Ansible** (versión 2.15 o superior):

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# macOS
brew install ansible

# Python pip
pip install ansible
```

### En los servidores destino:

- Sistema operativo: Ubuntu 20.04/22.04/24.04 LTS (Debian-based)
- Python 3.x instalado
- Acceso SSH configurado con clave pública
- Usuario `efemaq` con privilegios sudo (creado mediante [BOOTSTRAP.md](BOOTSTRAP.md))

## Configuración del Inventario

**IMPORTANTE:** Esta configuración es para el provisioning normal, después de completar el bootstrap.

### Ambiente de Test

Edita [inventories/test/hosts.yml](inventories/test/hosts.yml):

```yaml
all:
  children:
    test_servers:
      hosts:
        test-server-01:
          ansible_host: 192.168.56.103
          ansible_user: efemaq
          ansible_ssh_private_key_file: ./provision/.ssh/id_ed25519
```

### Ambiente de Producción

Edita [inventories/production/hosts.yml](inventories/production/hosts.yml):

```yaml
all:
  children:
    production_servers:
      hosts:
        elefante:
          ansible_host: 10.0.0.10
          ansible_user: efemaq
          ansible_ssh_private_key_file: ./provision/.ssh/id_ed25519
```

### Variables de Configuración

Revisa y ajusta las variables en:

- [group_vars/all.yml](group_vars/all.yml) - Variables globales
- [group_vars/test_servers.yml](group_vars/test_servers.yml) - Específicas de test
- [group_vars/production_servers.yml](group_vars/production_servers.yml) - Específicas de producción

### Verificar Conectividad

Asegúrate de poder conectarte a los servidores con el usuario `efemaq`:

```bash
# Verificar conectividad a test
ansible all -i ./provision/inventories/test/hosts.yml -m ping

# Verificar conectividad a producción
ansible all -i ./provision/inventories/production/hosts.yml -m ping
```

## Uso

### Despliegue Completo

#### Ambiente de Test:

```bash
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml
```

#### Ambiente de Producción:

```bash
ansible-playbook -i ./provision/inventories/production/hosts.yml ./provision/site.yml
```

### Despliegue por Componentes (Tags)

Puedes desplegar componentes individuales usando tags:

```bash
# Solo Docker
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml --tags docker

# Solo Docker Swarm
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml --tags swarm

# Solo Portainer
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml --tags portainer

# Solo Traefik
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml --tags traefik
```

### Dry-run (Verificar cambios sin aplicar)

```bash
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml --check --diff
```

### Verificar Sintaxis

```bash
ansible-playbook ./provision/site.yml --syntax-check
```

### Estadísticas del Servidor

Para obtener estadísticas detalladas del servidor (RAM, CPU, disco), utiliza el playbook de estadísticas:

```bash
# Para Test
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/playbooks/server_stats.yml

# Para Producción
ansible-playbook -i ./provision/inventories/production/hosts.yml ./provision/playbooks/server_stats.yml
```

El playbook muestra:

- **Memoria (RAM)**: Total, usado, disponible y porcentaje de uso
- **CPU**: Cantidad de CPUs, modelo, uso actual y load average
- **Disco**: Espacio total, usado, disponible y porcentaje de uso
- **Sistemas de archivos**: Todos los filesystems montados
- **Uptime**: Tiempo de actividad del servidor
- **Docker**: Contenedores, imágenes y volúmenes (si Docker está instalado)
- **Docker Swarm**: Nodos y servicios (si Swarm está activo)

**Ejemplo de salida:**

```
TASK [Display Memory Statistics]
ok: [test-server-01] =>
  msg:
  - ''
  - 📊 MEMORY (RAM)
  - 'Total: 3.8Gi | Used: 1.2Gi | Available: 2.1Gi | Usage: 31.6%'

TASK [Display CPU Statistics]
ok: [test-server-01] =>
  msg:
  - ''
  - 💻 CPU
  - 'CPUs: 4 | Model: Intel(R) Core(TM) i7 | Usage: 15.2% | Load Avg: 0.52, 0.58, 0.59'

TASK [Display Disk Statistics]
ok: [test-server-01] =>
  msg:
  - ''
  - 💾 DISK (Root Filesystem)
  - 'Total: 50G | Used: 12G | Available: 35G | Usage: 26% | Mounted: /'
```

## Componentes Desplegados

### 1. Docker

- **Versión**: Latest Docker CE
- **Incluye**: Docker Engine, Docker CLI, Containerd, Docker Compose Plugin
- **Configuración**:
  - Log driver: json-file
  - Storage driver: overlay2
  - Usuarios agregados al grupo docker

### 2. Docker Swarm

- **Modo**: Manager (single node)
- **Red Overlay**: `swarm_network` (encrypted)
- **Características**:
  - Orquestación nativa de Docker
  - Alta disponibilidad y escalabilidad
  - Load balancing integrado
  - Service discovery automático
  - Rolling updates

### 3. Portainer

- **Versión**: Community Edition (latest)
- **Modo de despliegue**: Docker Swarm service
- **Réplicas**: 1 (en nodo manager)
- **Puertos**:
  - HTTP: 9000
  - HTTPS: 9443
- **Acceso**: `https://<servidor-ip>:9443`
- **Persistencia**: Docker volume `portainer_data`
- **Features**: Gestión completa de Docker Swarm desde UI web

### 4. Traefik

- **Versión**: Latest v3.x
- **Modo de despliegue**: Docker Swarm service
- **Réplicas**: 1 (en nodo manager)
- **Puertos**:
  - HTTP: 80
  - HTTPS: 443
  - Dashboard: 8080
- **Acceso Dashboard**: `http://<servidor-ip>:8080/dashboard/`
- **Persistencia**:
  - Certificados SSL: `/var/lib/traefik/acme.json`
- **Features**:
  - Reverse proxy automático
  - Let's Encrypt integrado
  - Service discovery para Swarm
  - Load balancing
  - SSL/TLS automático

## Arquitectura Docker Swarm

Este despliegue configura un cluster de Docker Swarm con la siguiente arquitectura:

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Swarm Manager                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Traefik    │  │  Portainer   │  │ Your Apps... │       │
│  │   Service    │  │   Service    │  │   Services   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                           │                                 │
│                  ┌────────────────┐                         │
│                  │ swarm_network  │                         │
│                  │ (overlay)      │                         │
│                  └────────────────┘                         │
│                                                             │
│  Puertos publicados:                                        │
│  - 80/443 (Traefik HTTP/HTTPS)                              │
│  - 8080 (Traefik Dashboard)                                 │
│  - 9000/9443 (Portainer)                                    │
└─────────────────────────────────────────────────────────────┘
```

**Ventajas de usar Docker Swarm:**

- **Orquestación nativa**: No requiere herramientas externas como Kubernetes
- **Alta disponibilidad**: Servicios se redistribuyen automáticamente si un nodo falla
- **Escalabilidad**: Aumenta réplicas con un solo comando
- **Load balancing**: Distribuye tráfico automáticamente entre réplicas
- **Rolling updates**: Actualiza servicios sin downtime
- **Service discovery**: Los servicios se descubren automáticamente por nombre

## Verificación Post-Despliegue

Después del despliegue, verifica que todo esté funcionando:

```bash
# Conectarse al servidor
ssh efemaq@192.168.56.103 -i ./provision/.ssh/id_ed25519 # para test

# Verificar Docker
docker --version
docker ps

# Verificar Docker Swarm
docker node ls
docker service ls

# Verificar que Portainer esté corriendo
docker service ls | grep portainer
docker service ps portainer

# Verificar que Traefik esté corriendo
docker service ls | grep traefik
docker service ps traefik

# Verificar logs de Traefik
docker service logs traefik

# Ver estado de la red overlay
docker network ls | grep swarm_network
docker network inspect swarm_network

# Acceder a Portainer
# Abrir navegador: https://192.168.56.103:9443

# Acceder a Traefik Dashboard
# Abrir navegador: http://192.168.56.103:8080/dashboard/
```

## Workflow GitOps Completo

### Flujo Completo: De Servidor Nuevo a Producción

```
┌─────────────────────────────────────────────────────────────────┐
│ FASE 1: BOOTSTRAP (Solo la primera vez)                         │
├─────────────────────────────────────────────────────────────────┤
│ 1. Servidor nuevo con usuario admin/root                        │
│ 2. Ejecutar playbook bootstrap (ver BOOTSTRAP.md)               │
│    → Crea usuario efemaq                                        │
│    → Configura SSH keys                                         │
│    → Aplica hardening SSH                                       │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ FASE 2: PROVISIONING (Cada vez que cambies infraestructura)     │
├─────────────────────────────────────────────────────────────────┤
│ 1. Modificar playbooks/roles localmente                         │
│ 2. Commit a git                                                 │
│ 3. Test en Vagrant                                              │
│ 4. Verificar funcionamiento                                     │
│ 5. Deploy a producción                                          │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo de Trabajo Recomendado

#### 1. Primera Vez: Bootstrap del Servidor

Si es un servidor nuevo, ejecuta primero el bootstrap (ver [BOOTSTRAP.md](BOOTSTRAP.md)).

#### 2. Desarrollo Local

- Modifica playbooks y roles

#### 3. Test en Vagrant

**IMPORTANTE:** Siempre probar en test antes de producción

```bash
# Levantar VM si no está corriendo
cd ../test/ubuntu2404
vagrant up
cd ../..

# Desplegar
ansible-playbook -i ./provision/inventories/test/hosts.yml ./provision/site.yml
```

#### 4. Verificación Completa

Verifica que todo funcione correctamente:

```bash
# Conectarse al servidor de test
ssh efemaq@192.168.56.103 -i ./provision/.ssh/id_ed25519

# Verificar servicios
docker ps
docker logs traefik
docker logs portainer

# Verificar conectividad
curl http://localhost:8080/dashboard/
```

Accesos web:

- **Portainer**: https://192.168.56.103:9443
- **Traefik Dashboard**: http://192.168.56.103:8080/dashboard/

#### 5. Persistir cambios

- Commit a git con mensajes descriptivos

```bash
git add .
git commit -m "feat: agregar configuración de Traefik"
git push
```

#### 6. Despliegue a Producción

Solo después de verificar en test:

```bash
cd provision/

# Dry-run primero (recomendado)
ansible-playbook -i inventories/production/hosts.yml site.yml --check --diff

# Desplegar a producción
ansible-playbook -i inventories/production/hosts.yml site.yml
```

#### 6. Verificación en Producción

```bash
# Conectarse al servidor de producción
ssh efemaq@10.0.0.10 -i ./provision/.ssh/id_ed25519

# Verificar servicios
docker ps
systemctl status docker

# Ver logs
docker logs -f traefik
docker logs -f portainer
```

## Troubleshooting

### Problemas de Conexión SSH

#### Error: "Failed to connect to the host via ssh"

Este error puede ocurrir por varias razones:

**1. El servidor no ha sido bootstrapeado:**

Si es la primera vez que configuras el servidor, necesitas ejecutar el bootstrap primero:

```bash
# Ver BOOTSTRAP.md para la guía completa
ansible-playbook \
  -i inventories/production/hosts-bootstrap.yml \
  playbooks/bootstrap.yml \
  -u admin \
  --ask-pass
```

**2. Usuario o clave SSH incorrecta:**

```bash
# Verificar que puedes conectarte manualmente
ssh -i ../.ssh/id_ed25519 efemaq@192.168.56.103

# Para test
ssh -i ../.ssh/id_ed25519 efemaq@192.168.56.103

# Para producción
ssh -i ../.ssh/id_ed25519 efemaq@10.0.0.10
```

**3. IP incorrecta en el inventario:**

```bash
# Verificar que el inventario tenga la IP correcta
cat inventories/test/hosts.yml
cat inventories/production/hosts.yml
```

**4. Firewall bloqueando SSH:**

```bash
# En el servidor, verificar que el puerto 22 esté abierto
sudo ufw status
sudo ufw allow 22/tcp
```

#### Error: "Permission denied (publickey)"

El usuario no tiene tu clave SSH pública configurada:

```bash
# Ver BOOTSTRAP.md para configurar el usuario efemaq correctamente
# O manualmente:
ssh-copy-id -i ../.ssh/id_ed25519.pub efemaq@<servidor-ip>
```

### Problemas con Roles

#### Error: "docker: command not found"

El rol de Docker falló durante la instalación. Revisa los logs:

```bash
# Ver logs de Ansible
tail -f ansible.log

# Re-ejecutar solo el rol de Docker
ansible-playbook -i inventories/test/hosts.yml site.yml --tags docker -vvv
```

### Portainer no accesible

```bash
# Conectarse al servidor
ssh vagrant@192.168.56.10

# Verificar que el contenedor esté corriendo
docker ps | grep portainer

# Ver logs de Portainer
docker logs portainer

# Verificar puertos
sudo netstat -tulpn | grep 9443
```

### Permisos de usuario Docker

Si un usuario no puede ejecutar comandos docker:

```bash
# En el servidor
sudo usermod -aG docker <usuario>
# Cerrar sesión y volver a entrar
```

### Traefik no accesible

```bash
# Conectarse al servidor
ssh vagrant@192.168.56.10

# Verificar que el contenedor esté corriendo
docker ps | grep traefik

# Ver logs de Traefik
docker logs traefik

# Ver logs en tiempo real
docker logs -f traefik

# Verificar puertos
sudo netstat -tulpn | grep -E '80|443|8080'

# Verificar la red de Traefik
docker network ls | grep traefik
docker network inspect traefik_network

# Verificar certificados SSL (si usa ACME)
sudo ls -la /var/lib/traefik/acme.json
sudo cat /var/lib/traefik/acme.json | jq
```

### Problemas con certificados SSL de Traefik

```bash
# Verificar permisos del archivo acme.json
sudo chmod 600 /var/lib/traefik/acme.json

# Reiniciar Traefik para regenerar certificados
docker restart traefik

# Ver estado de los certificados en el dashboard
# http://<servidor-ip>:8080/dashboard/
```

## Personalización

### Cambiar versión de Portainer

Edita [group_vars/all.yml](group_vars/all.yml):

```yaml
portainer_version: "2.19.4" # Versión específica
```

### Agregar usuarios al grupo Docker

Edita el inventario o group_vars:

```yaml
docker_users:
  - vagrant
  - usuario1
  - usuario2
```

### Configuración avanzada de Docker

Edita [group_vars/production_servers.yml](group_vars/production_servers.yml):

```yaml
docker_daemon_options:
  log-driver: "json-file"
  log-opts:
    max-size: "100m"
    max-file: "5"
  storage-driver: "overlay2"
  live-restore: true
  userland-proxy: false
```

### Configurar Traefik con Let's Encrypt

Para habilitar SSL automático con Let's Encrypt, edita [group_vars/all.yml](group_vars/all.yml) o el archivo específico del ambiente:

```yaml
traefik_acme_email: "tu-email@dominio.com"
traefik_acme_storage: "/var/lib/traefik/acme.json"
traefik_acme_ca_server: "https://acme-v02.api.letsencrypt.org/directory" # Producción
# traefik_acme_ca_server: "https://acme-staging-v02.api.letsencrypt.org/directory"  # Staging/Test
```

### Configurar dominios en Traefik

Para exponer un servicio a través de Traefik, agrega labels al contenedor Docker:

```yaml
# En docker-compose.yml o al crear el contenedor
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myapp.rule=Host(`myapp.ejemplo.com`)"
  - "traefik.http.routers.myapp.entrypoints=websecure"
  - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
  - "traefik.http.services.myapp.loadbalancer.server.port=80"
```

### Agregar autenticación básica con Traefik

```bash
# Generar contraseña hasheada
htpasswd -nb admin tu_contraseña

# Agregar middleware en el servicio
labels:
  - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$..."
  - "traefik.http.routers.myapp.middlewares=auth"
```

### Personalizar Dashboard de Traefik

Edita [group_vars/all.yml](group_vars/all.yml):

```yaml
traefik_dashboard_enabled: true
traefik_dashboard_port: 8080
traefik_api_insecure: false # true para test, false para producción
```

## Mantenimiento

### Actualizar componentes

```bash
# Actualizar Docker a la última versión
ansible-playbook -i inventories/production/hosts.yml site.yml --tags docker

# Actualizar Portainer
ansible-playbook -i inventories/production/hosts.yml site.yml --tags portainer

# Actualizar Traefik
ansible-playbook -i inventories/production/hosts.yml site.yml --tags traefik
```

### Backup de Portainer

```bash
# En el servidor
docker run --rm -v portainer_data:/data -v $(pwd):/backup ubuntu tar czf /backup/portainer-backup.tar.gz /data
```

### Restore de Portainer

```bash
# En el servidor
docker run --rm -v portainer_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/portainer-backup.tar.gz -C /
```

### Backup de certificados SSL de Traefik

```bash
# En el servidor
sudo cp /var/lib/traefik/acme.json ~/backups/traefik-acme-$(date +%Y%m%d).json
sudo chmod 600 ~/backups/traefik-acme-*.json

# O crear un backup completo de Traefik
sudo tar czf ~/backups/traefik-backup-$(date +%Y%m%d).tar.gz /var/lib/traefik /etc/traefik
```

### Restore de certificados SSL de Traefik

```bash
# En el servidor
# Detener Traefik
docker stop traefik

# Restaurar certificados
sudo cp ~/backups/traefik-acme-YYYYMMDD.json /var/lib/traefik/acme.json
sudo chmod 600 /var/lib/traefik/acme.json

# Iniciar Traefik
docker start traefik
```

## Mejores Prácticas

### Flujo de Trabajo

1. **Bootstrap primero**: En servidores nuevos, siempre ejecuta el bootstrap antes del provisioning (ver [BOOTSTRAP.md](BOOTSTRAP.md))
2. **Siempre probar en test primero**: Nunca despliegues directamente a producción sin probar en Vagrant
3. **Usar control de versiones**: Todos los cambios deben estar en git antes de desplegar
4. **Documentar cambios**: Usa commits descriptivos siguiendo [Conventional Commits](https://www.conventionalcommits.org/)
5. **Revisar diffs**: Usa `--check --diff` antes de aplicar cambios en producción

### Seguridad y Operaciones

6. **Usuario dedicado**: Siempre usa el usuario `efemaq` para provisioning, nunca root directamente
7. **SSH keys**: No uses autenticación por contraseña en producción, solo claves SSH
8. **Secrets**: Usa Ansible Vault para secretos sensibles (contraseñas, API keys, etc.)
9. **Backups**: Mantén backups regulares de volúmenes de Docker y certificados SSL
10. **Tags**: Usa tags para despliegues selectivos y evitar re-ejecutar todo

### Calidad del Código

11. **Idempotencia**: Los playbooks deben ser idempotentes (ejecutables múltiples veces sin efectos adversos)
12. **Dry-run**: Usa `--check` antes de aplicar cambios críticos
13. **Logging**: Revisa logs después de cada despliegue
14. **Testing**: Verifica manualmente los servicios después de cada despliegue

## Seguridad

### Usar Ansible Vault para Secretos

```bash
# Crear archivo encriptado
ansible-vault create group_vars/production_servers.vault.yml

# Editar archivo encriptado
ansible-vault edit group_vars/production_servers.vault.yml

# Ejecutar playbook con vault
ansible-playbook -i inventories/production/hosts.yml site.yml --ask-vault-pass
```

### Recomendaciones de Seguridad

- Mantener Docker actualizado
- Configurar firewall (UFW/iptables)
- Usar autenticación de dos factores en Portainer
- Limitar acceso SSH (solo por clave, no por contraseña)
- Revisar logs regularmente
- Implementar fail2ban

#### Seguridad específica de Traefik:

- **Dashboard**: Proteger el dashboard con autenticación básica o OAuth
- **Certificados SSL**: Usar Let's Encrypt en producción, permisos 600 en acme.json
- **Headers de seguridad**: Configurar middlewares para headers HTTP seguros
- **Rate limiting**: Implementar límites de tasa para prevenir ataques
- **Logs**: Activar logs de acceso y monitorearlo con herramientas como fail2ban
- **API**: Deshabilitar la API insegura en producción (`api.insecure=false`)
- **Red Docker**: Aislar servicios en redes Docker separadas
- **Actualizaciones**: Mantener Traefik actualizado a la última versión

Ejemplo de configuración segura de Traefik:

```yaml
# En group_vars/production_servers.yml
traefik_api_insecure: false
traefik_dashboard_auth_enabled: true
traefik_dashboard_auth_users:
  - "admin:$apr1$..." # Generar con htpasswd

traefik_security_headers:
  - "traefik.http.middlewares.security.headers.sslredirect=true"
  - "traefik.http.middlewares.security.headers.stsSeconds=31536000"
  - "traefik.http.middlewares.security.headers.stsIncludeSubdomains=true"
  - "traefik.http.middlewares.security.headers.stsPreload=true"
  - "traefik.http.middlewares.security.headers.forceSTSHeader=true"
```

## Ejemplos de Uso con Docker Swarm y Traefik

### Desplegar aplicaciones en Docker Swarm

#### Ejemplo 1: Servicio web simple con Traefik y HTTPS

```bash
# Crear un servicio de ejemplo
docker service create \
  --name webapp \
  --network swarm_network \
  --label "traefik.enable=true" \
  --label "traefik.http.routers.webapp.rule=Host(\`webapp.ejemplo.com\`)" \
  --label "traefik.http.routers.webapp.entrypoints=websecure" \
  --label "traefik.http.routers.webapp.tls.certresolver=letsencrypt" \
  --label "traefik.http.services.webapp.loadbalancer.server.port=80" \
  --replicas 3 \
  nginx:alpine
```

#### Ejemplo 2: Stack completo con docker-compose (Swarm mode)

```yaml
# stack.yml
version: "3.8"

services:
  webapp:
    image: nginx:alpine
    networks:
      - swarm_network
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role == worker
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.webapp.rule=Host(\`webapp.ejemplo.com\`)"
        - "traefik.http.routers.webapp.entrypoints=websecure"
        - "traefik.http.routers.webapp.tls.certresolver=letsencrypt"
        - "traefik.http.services.webapp.loadbalancer.server.port=80"
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first

networks:
  swarm_network:
    external: true
```

```bash
# Desplegar el stack
docker stack deploy -c stack.yml myapp

# Ver servicios del stack
docker stack services myapp

# Ver tareas (réplicas) del servicio
docker service ps myapp_webapp

# Escalar el servicio
docker service scale myapp_webapp=5

# Actualizar imagen sin downtime
docker service update --image nginx:latest myapp_webapp

# Eliminar el stack
docker stack rm myapp
```

### Ejemplo 2: Múltiples aplicaciones con subdominios

```yaml
services:
  api:
    image: myapi:latest
    networks:
      - traefik_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.ejemplo.com`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"

  frontend:
    image: myfrontend:latest
    networks:
      - traefik_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`www.ejemplo.com`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"
```

### Ejemplo 3: Aplicación con autenticación básica

```yaml
services:
  admin:
    image: admin-panel:latest
    networks:
      - traefik_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.admin.rule=Host(`admin.ejemplo.com`)"
      - "traefik.http.routers.admin.entrypoints=websecure"
      - "traefik.http.routers.admin.tls.certresolver=letsencrypt"
      # Autenticación básica
      - "traefik.http.routers.admin.middlewares=admin-auth"
      - "traefik.http.middlewares.admin-auth.basicauth.users=admin:$$apr1$$..."
```

### Ejemplo 4: Rate limiting y headers de seguridad

```yaml
services:
  public-api:
    image: public-api:latest
    networks:
      - traefik_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.publicapi.rule=Host(`api.ejemplo.com`)"
      - "traefik.http.routers.publicapi.entrypoints=websecure"
      - "traefik.http.routers.publicapi.tls.certresolver=letsencrypt"
      # Rate limiting: 100 requests por segundo
      - "traefik.http.routers.publicapi.middlewares=api-ratelimit,api-headers"
      - "traefik.http.middlewares.api-ratelimit.ratelimit.average=100"
      - "traefik.http.middlewares.api-ratelimit.ratelimit.burst=50"
      # Headers de seguridad
      - "traefik.http.middlewares.api-headers.headers.customResponseHeaders.X-Robots-Tag=noindex,nofollow"
      - "traefik.http.middlewares.api-headers.headers.sslRedirect=true"
```

## Soporte

Para problemas o preguntas:

1. Revisar logs: `tail -f ansible.log`
2. Ejecutar con verbose: `ansible-playbook ... -vvv`
3. Verificar documentación de Ansible: https://docs.ansible.com
4. Documentación de Traefik: https://doc.traefik.io/traefik/

## Licencia

Ver archivo [LICENSE](../../LICENSE) en la raíz del proyecto.

## Contribuciones

1. Fork el repositorio
2. Crea una rama para tu feature
3. Haz commit de tus cambios
4. Push a la rama
5. Crea un Pull Request
