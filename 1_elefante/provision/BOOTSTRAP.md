# Guía de Bootstrap - Configuración Inicial de Servidores

Esta guía explica cómo configurar un servidor nuevo por primera vez, creando el usuario `efemaq` que se usará para todas las operaciones posteriores.

## 📂 Contexto del Repositorio

Este directorio (`1_elefante/provision/`) es parte de un **repositorio GitOps multi-servidor**:

```
gitops/                          # ← Raíz del repositorio
├── 1_elefante/                  # ← Este servidor
│   └── provision/               # ← Estás aquí
│       ├── BOOTSTRAP.md         # Este archivo
│       └── group_vars/*/secrets.yml  # Encriptados automáticamente
├── 2_jirafa/                    # Servidor 2
└── 3_tigre/                     # Servidor 3
```

**Ver**: [README.md](README.md#-estructura-del-repositorio-gitops) para más detalles sobre la estructura.

---

## Flujo de Trabajo

```
┌─────────────────────────────────────────────────────────────────┐
│  PRIMERA VEZ: Bootstrap con usuario admin                       │
│  ↓                                                              │
│  1. Conectarse con usuario admin/root                           │
│  2. Crear usuario efemaq                                        │
│  3. Configurar SSH keys                                         │
│  4. Configurar sudo sin contraseña                              │
│  5. Hardening SSH (deshabilitar root, password auth)            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  SUBSECUENTES VECES: Provisioning normal con usuario efemaq     │
│  ↓                                                              │
│  1. Conectarse con usuario efemaq (SSH key)                     │
│  2. Ejecutar playbooks de infraestructura                       │
│  3. Desplegar servicios (Docker, Traefik, Portainer, etc)       │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisitos

1. **Servidor fresco** con Ubuntu/Debian
2. **Usuario admin** o root con acceso SSH
3. **Contraseña** del usuario admin
4. **Tu clave SSH pública** (generalmente en `./provision/.ssh/id_ed25519.pub`)

## Paso 1: Preparar las Credenciales

### 1.1. Obtener tu clave SSH pública

```bash
# Crear clave SSH
ssh-keygen -t ed25519 -C "info@efemaq.com.ar" -f ./provision/.ssh/id_ed25519
```

```bash
# Ver clave pública
# cat ./provision/.ssh/id_ed25519.pub
cat ./provision/.ssh/id_ed25519.pub | xclip -selection clipboard
# MD5 fingerprint:
ssh-keygen -l -E md5 -f ./provision/.ssh/id_ed25519.pub | cut -d ' ' -f 2 | sed "s/MD5://g"
# SHA256 fingerprint:
ssh-keygen -l -E SHA256 -f ./provision/.ssh/id_ed25519.pub | cut -d ' ' -f 2 | sed "s/SHA256://g"
```

## Paso 2: Configurar el Inventario de Bootstrap

Edita el inventario de bootstrap con la IP de tu servidor:

```bash
nano ./provision/inventories/production/hosts-bootstrap.yml
```

Cambia la IP según tu servidor:

```yaml
elefante:
  ansible_host: 10.0.0.10 # ← Cambiar por tu IP real
```

## Paso 3: Ejecutar el Bootstrap

### 3.1. Ambiente de Producción

```bash
ansible-playbook \
  -i ./provision/inventories/production/hosts-bootstrap.yml \
  ./provision/playbooks/bootstrap.yml \
  -u root \
  --ask-pass \
  --ask-become-pass
```

**Parámetros:**

- `-u root`: Usuario inicial (puede ser `root` o `admin` según tu servidor)
- `--ask-pass`: Pedirá la contraseña SSH del usuario admin
- `--ask-become-pass`: Pedirá la contraseña de sudo (normalmente la misma)

### 3.2. Ambiente de Test (Vagrant)

Si estás usando Vagrant para el ambiente de test:

```bash
ansible-playbook \
  -i ./provision/inventories/test/hosts-bootstrap.yml \
  ./provision/playbooks/bootstrap.yml \
  -u vagrant \
  --private-key ./test/ubuntu2404/.vagrant/machines/default/virtualbox/private_key
```

**Nota para Test:** En ambientes Vagrant, el usuario `vagrant` generalmente ya tiene sudo sin contraseña, pero el playbook configurará el usuario `efemaq` de la misma forma que en producción.

### 3.3. Verificar la conexión con el nuevo usuario

**¡IMPORTANTE!** No cierres tu sesión SSH actual hasta verificar que el nuevo usuario funciona.

```bash
# Para PRODUCCIÓN: Probar conexión con el usuario efemaq
ssh efemaq@10.0.0.10 -i ./provision/.ssh/id_ed25519

# Para TEST: Probar conexión con el usuario efemaq
ssh efemaq@192.168.56.103 -i ./provision/.ssh/id_ed25519

# Verificar sudo sin contraseña (en cualquier ambiente)
sudo whoami
# Debería devolver: root (sin pedir contraseña)
```

Ahora ambos ambientes usarán:

- Usuario: `efemaq`
- SSH key: `./provision/.ssh/id_ed25519`
- Sin contraseñas (autenticación por clave)

## Paso 4: Provisioning Normal

Una vez que el bootstrap es exitoso, usa el playbook principal con el usuario `efemaq` (ver [README.md](README.md) para más detalles).

## Comandos Útiles

### Para Producción

```bash
# Ver todos los hosts en el inventario de bootstrap
ansible-inventory -i ./provision/inventories/production/hosts-bootstrap.yml --list

# Probar conexión sin ejecutar tareas
ansible all -i ./provision/inventories/production/hosts-bootstrap.yml -m ping -u admin --ask-pass
ansible all -i ./provision/inventories/production/hosts.yml -m ping

```

### Para Test (Vagrant)

```bash
# Ver todos los hosts en el inventario de bootstrap de test
ansible-inventory -i ./provision/inventories/test/hosts-bootstrap.yml --list

# Probar conexión sin ejecutar tareas (con clave de Vagrant)
ansible all -i ./provision/inventories/test/hosts-bootstrap.yml -m ping -u vagrant --private-key ./test/ubuntu2404/.vagrant/machines/default/virtualbox/private_key
ansible all -i ./provision/inventories/test/hosts.yml -m ping

```
