# Estructura del Directorio Provision

## 📂 Contexto: Repositorio Multi-Servidor

Este directorio es parte de un repositorio GitOps que gestiona **múltiples servidores**.

```
gitops/                                    # ← RAÍZ del repositorio Git
├── .git/                                  # Repositorio Git
├── .gitattributes                         # ← Configuración de encriptación git-crypt
├── .gitignore                             # Archivos ignorados por Git
├── GIT-CRYPT-SETUP.md                     # Documentación de git-crypt
├── setup-git-crypt.sh                     # Script de configuración
│
├── 1_elefante/                            # Servidor 1: Elefante
│   ├── .devcontainer/                     # Configuración Dev Container
│   ├── provision/                         # ← ESTÁS AQUÍ (ver estructura abajo)
│   └── test/                              # VMs de test (Vagrant)
│
├── 2_jirafa/                              # Servidor 2 (futuro)
│   └── provision/
│
└── 3_tigre/                               # Servidor 3 (futuro)
    └── provision/
```

### 🔐 Encriptación con Git-Crypt

**IMPORTANTE**: El archivo `.gitattributes` está en la raíz del repositorio (dos niveles arriba):

- **Ubicación**: `gitops/.gitattributes` (no en `provision/`)
- **Patrón**: `**/secrets.yml filter=git-crypt diff=git-crypt`
- **Efecto**: Todos los archivos `secrets.yml` en cualquier subdirectorio se encriptan automáticamente
- **Ver**: [../../GIT-CRYPT-SETUP.md](../../GIT-CRYPT-SETUP.md)

---

## 📁 Estructura del Directorio `1_elefante/provision/`

```
provision/
├── README.md                          # Documentación completa
├── setup.sh                           # Script de configuración inicial
├── ansible.cfg                        # Configuración de Ansible
├── site.yml                           # Playbook principal
├── requirements.yml                   # Dependencias de Ansible
├── Makefile                           # Comandos útiles (make deploy-test, etc.)
├── .gitignore                         # Archivos a ignorar en git
│
├── inventories/                       # Inventarios por ambiente
│   ├── test/
│   │   └── hosts.yml                  # Servidores de test/staging
│   └── production/
│       └── hosts.yml                  # Servidores de producción
│
├── group_vars/                        # Variables por grupos de hosts
│   ├── all.yml                        # Variables globales
│   ├── test_servers.yml               # Variables específicas de test
│   └── production_servers.yml         # Variables específicas de producción
│
├── host_vars/                         # Variables por host individual (vacío)
│
├── roles/                             # Roles de Ansible
│   ├── docker/                        # Rol de Docker
│   │   ├── defaults/
│   │   │   └── main.yml               # Variables por defecto
│   │   ├── tasks/
│   │   │   └── main.yml               # Tareas principales
│   │   ├── handlers/
│   │   │   └── main.yml               # Handlers (restart, reload)
│   │   ├── templates/                 # Plantillas Jinja2 (vacío)
│   │   └── files/                     # Archivos estáticos (vacío)
│   │
│   ├── docker_swarm/                  # Rol de Docker Swarm
│   │   ├── defaults/
│   │   │   └── main.yml               # Variables por defecto
│   │   ├── tasks/
│   │   │   └── main.yml               # Tareas principales
│   │   ├── handlers/
│   │   │   └── main.yml               # Handlers
│   │   ├── templates/                 # Plantillas (vacío)
│   │   └── files/                     # Archivos estáticos (vacío)
│   │
│   └── portainer/                     # Rol de Portainer
│       ├── defaults/
│       │   └── main.yml               # Variables por defecto
│       ├── tasks/
│       │   └── main.yml               # Tareas principales
│       ├── handlers/
│       │   └── main.yml               # Handlers
│       ├── templates/                 # Plantillas (vacío)
│       └── files/                     # Archivos estáticos (vacío)
│
└── playbooks/                         # Playbooks adicionales
    ├── maintenance.yml                # Tareas de mantenimiento
    └── backup.yml                     # Backup de configuraciones y datos
```

## Descripción de Componentes

### Archivos Principales

- **README.md**: Documentación completa del proyecto con instrucciones de uso
- **setup.sh**: Script de instalación inicial de dependencias
- **ansible.cfg**: Configuración global de Ansible
- **site.yml**: Playbook principal que orquesta todos los roles
- **requirements.yml**: Colecciones de Ansible necesarias

### Inventarios

Definen los hosts target organizados por ambiente:
- **test**: Para pruebas con Vagrant o VMs de desarrollo
- **production**: Para servidores de producción

### Variables

- **group_vars/**: Variables aplicables a grupos de hosts
- **host_vars/**: Variables específicas de hosts individuales

### Roles

Cada rol es independiente y reutilizable:
- **docker**: Instala y configura Docker CE con todas sus dependencias
- **docker_swarm**: Despliega Docker Swarm en contenedor Docker
- **portainer**: Despliega Portainer CE para gestión de Docker
- **traefik**: Despliega Traefik como proxy inverso y balanceador de carga

### Playbooks Adicionales

- **maintenance.yml**: Actualización de sistema, limpieza de Docker, métricas
- **backup.yml**: Backup de volúmenes y configuraciones

## Comandos Rápidos

```bash
# Configuración inicial
cd provision
./setup.sh

# Despliegue en test
ansible-playbook -i inventories/test/hosts.yml site.yml

# Despliegue en producción
ansible-playbook -i inventories/production/hosts.yml site.yml

# Verificar conectividad
ansible all -i inventories/test/hosts.yml -m ping
ansible all -i inventories/production/hosts.yml -m ping

# Mantenimiento
ansible-playbook -i inventories/test/hosts.yml playbooks/maintenance.yml

# Backup
ansible-playbook -i inventories/production/hosts.yml playbooks/backup.yml
```

## GitOps Workflow

1. Modificar código en local
2. Commit y push a repositorio
3. Probar en ambiente de test
4. Si todo OK, desplegar a producción
5. Todo queda versionado y auditable
