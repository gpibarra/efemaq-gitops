# GitOps Repository - Efemaq Infrastructure

Repositorio centralizado para gestión de infraestructura de múltiples servidores usando **GitOps** con Ansible.

## Estructura del Repositorio Multi-Servidor

Este repositorio gestiona **múltiples servidores** de forma independiente:

```
gitops/                                    # ← RAÍZ del repositorio (estás aquí)
├── .git/                                  # Repositorio Git
├── .gitattributes                         # Configuración de encriptación git-crypt
├── .gitignore                             # Archivos ignorados por Git
├── README.md                              # ← Este archivo
├── GIT-CRYPT-SETUP.md                     # Documentación de git-crypt
├── setup-git-crypt.sh                     # Script de configuración git-crypt
│
├── 1_elefante/                            # Servidor 1
│   ├── ...
│   ├── ...
│
├── 2_jirafa/                              # Servidor 2
│   ├── ...
│   ├── ...
│
└── 3_tigre/                               # Servidor 3
    ├── ...
    ├── ...
```

## Seguridad: Encriptación con Git-Crypt

### ¿Por qué git-crypt?

- **Transparente**: Los archivos se encriptan/desencriptan automáticamente
- **Selectivo**: Solo encripta archivos sensibles (secrets.yml, .env, keys, etc.)
- **Compatible**: Funciona con cualquier flujo de trabajo Git
- **Multi-usuario**: Permite compartir acceso de forma segura

**Ventaja**: Un solo archivo `.gitattributes` protege **TODOS los servidores** del repositorio.

### Configuración

Ver [GIT-CRYPT-SETUP.md](GIT-CRYPT-SETUP.md) para instrucciones completas de:
- Instalación
- Configuración inicial
- Compartir acceso con el equipo
- Verificación

## Inicio Rápido

### 1. Clonar el Repositorio

```bash
git clone <repo-url>
cd gitops
```

### 2. Desbloquear Secretos

```bash
# Obtener git-crypt-key del administrador
git-crypt unlock /path/to/git-crypt-key
```

### 3. Acceder a un Servidor

```bash
cd 1_elefante
```

Ver la documentación específica de cada servidor en su directorio `provision/README.md`.

## Herramientas y Tecnologías

- **Ansible**: Automatización de infraestructura
- **Git-Crypt**: Encriptación transparente de secretos
- **Docker & Docker Swarm**: Contenedorización y orquestación de servicios
- **Traefik**: Reverse proxy, load balancing y SSL automático
- **Portainer**: Gestión de Docker Swarm desde UI web
- **Vagrant**: Entornos de prueba locales

## Flujo de Trabajo GitOps

```
┌──────────────────────────────────────────────────────────┐
│ 1. Modificar configuración localmente                    │
│    cd 1_elefante/provision                               │
│    vim group_vars/production_servers/vars.yml            │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 2. Probar en ambiente de Test                            │
│    ansible-playbook -i inventories/test/hosts.yml \      │
│                     site.yml                             │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 3. Verificar funcionamiento                              │
│    ssh efemaq@test-server                                │
│    docker ps                                             │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 4. Commit y push a Git                                   │
│    git add .                                             │
│    git commit -m "feat: update traefik config"           │
│    git push                                              │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 5. Deploy a Producción                                   │
│    ansible-playbook -i inventories/production/hosts.yml \│
│                     site.yml                             │
└──────────────────────────────────────────────────────────┘
```

