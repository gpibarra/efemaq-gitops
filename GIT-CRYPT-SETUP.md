# Configuración de Git-Crypt

Este proyecto usa **git-crypt** para encriptar automáticamente archivos con secretos (passwords, tokens, keys, etc.).

## Estructura del Repositorio Multi-Servidor

Este es un repositorio GitOps que gestiona **múltiples servidores**. La encriptación se configura **a nivel raíz** y aplica a todos los servidores:

```
gitops/                                    # ← RAÍZ del repositorio (estás aquí)
├── .git/                                  # Repositorio Git
├── .gitattributes                         # ← CONFIGURACIÓN DE ENCRIPTACIÓN (aquí)
├── GIT-CRYPT-SETUP.md                     # ← Este archivo
├── setup-git-crypt.sh                     # Script de configuración
│
├── 1_elefante/                            # Servidor 1
│   └── provision/
│       └── group_vars/
│           ├── all/secrets.yml            # ✅ Encriptado automáticamente
│           ├── production_servers/secrets.yml  # ✅ Encriptado
│           └── test_servers/secrets.yml   # ✅ Encriptado
│
├── 2_jirafa/                              # Servidor 2
│   └── provision/
│       └── group_vars/*/secrets.yml       # ✅ También encriptado
│
└── 3_tigre/                               # Servidor 3
    └── provision/
        └── group_vars/*/secrets.yml       # ✅ También encriptado
```

### Configuración de Encriptación

El archivo `.gitattributes` en la **raíz** del repositorio define qué archivos se encriptan:

**Ventaja**: Un solo `.gitattributes` protege **todos los servidores** del repositorio.

## Tabla de contenidos

- [Instalación](#instalación)
- [Primera configuración (Setup inicial)](#primera-configuración-setup-inicial)
- [Uso diario](#uso-diario)
- [Compartir acceso con el equipo](#compartir-acceso-con-el-equipo)
- [Verificar encriptación](#verificar-encriptación)
- [Troubleshooting](#troubleshooting)

---

## Instalación

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install git-crypt
```

### macOS

```bash
brew install git-crypt
```

### Arch Linux

```bash
sudo pacman -S git-crypt
```

### Verificar instalación

```bash
git-crypt --version
```

---

## Primera configuración (Setup inicial)

### Para el primer usuario (quien crea el repo):

**1. Inicializar git-crypt** (solo la primera vez):

```bash
cd /path/to/gitops
git-crypt init
```

**2. Exportar la key** (para compartir con el equipo):

```bash
git-crypt export-key ~/git-crypt-key
```

**⚠️ IMPORTANTE**: Guarda este archivo `git-crypt-key` en un lugar seguro:

- 1Password
- LastPass
- USB encriptado
- NO lo subas a Git
- NO lo envíes por email sin encriptar

**3. Commit y push**:

```bash
git add .
git commit -m "Setup git-crypt for secrets management"
git push
```

Los archivos `**/secrets.yml` se encriptarán automáticamente.

---

### Para nuevos miembros del equipo:

**1. Clonar el repo**:

```bash
git clone https://github.com/usuario/gitops.git
cd gitops
```

**2. Obtener la key** del administrador (archivo `git-crypt-key`)

**3. Desbloquear el repo**:

```bash
git-crypt unlock /path/to/git-crypt-key
```

**4. Verificar**:

```bash
cat 1_elefante/provision/group_vars/all/secrets.yml
```

Deberías ver el contenido en texto plano.

---

## Uso diario

### Editar secretos

Los archivos se encriptan/desencriptan **automáticamente**:

```bash
# Editar normalmente
vim 1_elefante/provision/group_vars/all/secrets.yml

# Commit normal (se encripta automáticamente)
git add 1_elefante/provision/group_vars/all/secrets.yml
git commit -m "Update secrets"
git push
```

### Archivos que se encriptan automáticamente

Según `.gitattributes`:

### Ver estado de encriptación

```bash
git-crypt status
```

Salida ejemplo:

```
    encrypted: 1_elefante/provision/group_vars/all/secrets.yml
    encrypted: 1_elefante/provision/group_vars/test_servers/secrets.yml
    encrypted: 1_elefante/provision/group_vars/production_servers/secrets.yml
not encrypted: 1_elefante/provision/site.yml
not encrypted: README.md
```

### Cerrar sesión (lock)

Si quieres bloquear los archivos encriptados:

```bash
git-crypt lock
```

Esto encripta todos los archivos localmente. Para desbloquear de nuevo:

```bash
git-crypt unlock /path/to/git-crypt-key
```

---

## Compartir acceso con el equipo

### Método 1: Key simétrica (más simple)

**Administrador:**

```bash
# Exportar key
git-crypt export-key ~/git-crypt-key

# # pasar a base64 y copiar
# cat ./.git/git-crypt/keys/default | base64 | xclip -selection clipboard
# # revertir
# cat ~/git-crypt-key | base64 --decode > ./git-crypt-key

# Compartir de forma segura:
# - 1Password
# - LastPass
# - Entrega en persona (USB)
# - Mensaje encriptado (Signal, Telegram secret chat)
```

**Nuevo usuario:**

```bash
git clone repo
git-crypt unlock /path/to/git-crypt-key
```

### Método 2: GPG keys (más seguro, por usuario)

**Administrador agrega nuevo usuario:**

```bash
# El usuario debe tener una GPG key
git-crypt add-gpg-user USER_GPG_KEY_ID
git push
```

**Nuevo usuario desbloquea:**

```bash
git clone repo
git-crypt unlock
# Usa su propia GPG key automáticamente
```

**Ventaja**: Cada usuario tiene su propia key, puedes revocar acceso individualmente.

---

## Verificar encriptación

### Ver archivo sin desencriptar

```bash
# Ver cómo se ve encriptado en Git
git show HEAD:1_elefante/provision/group_vars/all/secrets.yml | head -n 5
```

Deberías ver datos binarios/encriptados.

### Ver archivo desencriptado

```bash
# Ver normalmente
cat 1_elefante/provision/group_vars/all/secrets.yml
```

### Verificar en GitHub/GitLab

Entra a GitHub y abre `secrets.yml`. Deberías ver contenido encriptado (binario).

---

## Seguridad

### Buenas prácticas:

- ✅ Nunca hagas commit de secretos sin encriptar
- ✅ Verifica `git-crypt status` antes de push
- ✅ Guarda múltiples copias de la key
- ✅ Rota secretos regularmente
- ✅ Usa diferentes secretos para test y producción
- ✅ Documenta quién tiene acceso

### NO hacer:

- ❌ No subas la key (`git-crypt-key`) al repo
- ❌ No compartas la key por email sin encriptar
- ❌ No uses los mismos secretos en dev y prod
- ❌ No guardes la key en la misma máquina que el repo (backup remoto)

---

## Referencias

- [Git-crypt GitHub](https://github.com/AGWA/git-crypt)
- [Git-crypt Tutorial](https://dev.to/heroku/how-to-manage-your-secrets-with-git-crypt-56ih)
