# Traefik Role

Este rol instala y configura Traefik como reverse proxy con soporte para SSL automático usando Let's Encrypt.

## Características

- **Reverse Proxy**: Enruta tráfico basado en dominios
- **SSL automático**: Genera certificados SSL gratuitos con Let's Encrypt
- **Dashboard**: Interfaz web para monitorear Traefik
- **Docker integration**: Detección automática de contenedores
- **Security headers**: Headers de seguridad pre-configurados

## Variables principales

Edita `group_vars/all.yml` para configurar:

```yaml
# Dominio principal
domain_name: "tudominio.com"

# Email para Let's Encrypt
traefik_acme_email: "admin@tudominio.com"

# Habilitar dashboard
traefik_dashboard_enabled: true
```

## Uso

### 1. Configurar dominio

Edita `provision/group_vars/all.yml`:

```yaml
domain_name: "midominio.com"
traefik_acme_email: "admin@midominio.com"
```

### 2. Configurar DNS

Apunta estos subdominios a tu servidor:

- `traefik.midominio.com` → IP del servidor (para dashboard)
- `portainer.midominio.com` → IP del servidor (si usas Traefik con Portainer)

### 3. Ejecutar el playbook

```bash
cd provision
ansible-playbook -i inventories/production/hosts.yml site.yml --tags traefik
```

### 4. Acceder al dashboard

```
https://traefik.tudominio.com
```

**Usuario**: `admin`

**Password**: Se genera automáticamente en el primer despliegue

## Integración con otros servicios

### Portainer con Traefik

Edita `group_vars/all.yml`:

```yaml
portainer_use_traefik: true
```

Accede a Portainer en: `https://portainer.tudominio.com`

### Agregar un nuevo servicio

Agrega estas labels a tu contenedor Docker:

```yaml
labels:
  traefik.enable: "true"
  traefik.http.routers.miapp.rule: "Host(`miapp.tudominio.com`)"
  traefik.http.routers.miapp.entrypoints: "websecure"
  traefik.http.routers.miapp.tls: "true"
  traefik.http.routers.miapp.tls.certresolver: "letsencrypt"
  traefik.http.services.miapp.loadbalancer.server.port: "8080"
```

Asegúrate de que el contenedor esté en la red `traefik-public`:

```yaml
networks:
  - name: traefik-public
```

## Puertos

- **80**: HTTP (redirige a HTTPS)
- **443**: HTTPS
- **8080**: Dashboard de Traefik

## Certificados SSL

Los certificados se almacenan en:

```
/var/lib/traefik/acme.json
```

### Let's Encrypt Staging (para pruebas)

Si quieres probar sin agotar el límite de Let's Encrypt, edita `defaults/main.yml`:

```yaml
traefik_acme_ca_server: "https://acme-staging-v02.api.letsencrypt.org/directory"
```

**Nota**: Los certificados de staging no son válidos en navegadores.

### Let's Encrypt Production

Para producción (por defecto):

```yaml
traefik_acme_ca_server: "https://acme-v02.api.letsencrypt.org/directory"
```

## Seguridad

### Headers de seguridad

Están habilitados por defecto en `dynamic.yml`:

- X-XSS-Protection
- X-Content-Type-Options
- Strict-Transport-Security (HSTS)
- X-Frame-Options

### Autenticación básica

Para proteger el dashboard, edita `defaults/main.yml`:

```yaml
traefik_dashboard_auth_enabled: true
traefik_dashboard_auth_users: "admin:$$apr1$$..."
```

## Troubleshooting

### Ver logs de Traefik

```bash
docker logs traefik
```

### Verificar configuración

```bash
docker exec traefik cat /etc/traefik/traefik.yml
```

### Verificar certificados

```bash
docker exec traefik cat /data/acme.json | jq
```

### El certificado no se genera

1. Verifica que el dominio apunte correctamente a tu servidor
2. Verifica que los puertos 80 y 443 estén abiertos
3. Verifica los logs: `docker logs traefik`
4. Prueba con Let's Encrypt staging primero

### Dashboard no accesible

1. Verifica que `traefik_dashboard_enabled: true`
2. Verifica que el DNS de `traefik.tudominio.com` apunte a tu servidor
3. Espera unos minutos para que se genere el certificado

## Red de Docker

Traefik crea una red llamada `traefik-public`. Todos los servicios que quieras exponer deben estar conectados a esta red.

```bash
docker network ls | grep traefik
```

## Ejemplo completo

Para desplegar una aplicación web con SSL:

1. **Configura tu dominio en DNS**: `miapp.tudominio.com` → IP del servidor

2. **Despliega tu contenedor**:

```yaml
- name: Deploy my app
  community.docker.docker_container:
    name: myapp
    image: myapp:latest
    networks:
      - name: traefik-public
    labels:
      traefik.enable: "true"
      traefik.http.routers.myapp.rule: "Host(`miapp.tudominio.com`)"
      traefik.http.routers.myapp.entrypoints: "websecure"
      traefik.http.routers.myapp.tls.certresolver: "letsencrypt"
      traefik.http.services.myapp.loadbalancer.server.port: "8080"
```

3. **Accede**: `https://miapp.tudominio.com` (con SSL automático!)

## Referencias

- [Documentación oficial de Traefik](https://doc.traefik.io/traefik/)
- [Let's Encrypt Rate Limits](https://letsencrypt.org/docs/rate-limits/)
