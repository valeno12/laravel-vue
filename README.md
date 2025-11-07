# Laravel 12 + Vue + Docker + PostgreSQL Starter

Esta es una plantilla lista para usar para desarrollar proyectos **Laravel 12 con Vue (Inertia + Vite)** utilizando solo Docker.  
El objetivo es que puedas trabajar sin instalar **PHP, Composer, Node ni PostgreSQL** en tu máquina:  
solo necesitás **Docker y Git**.

---

## 🧱 Tecnologías incluidas

- **Laravel 12** con Vue + Inertia + Vite
- **PHP 8.2‑FPM** con extensiones:
  - `pdo_pgsql`, `pgsql`, `mbstring`, `exif`, `pcntl`, `bcmath`, `gd`, `zip`
- **Composer 2.6** (dentro del contenedor)
- **Node.js 22 + npm** (dentro del contenedor)
- **Nginx** como servidor web frontal
- **PostgreSQL 16** como base de datos
- **Volúmenes persistentes** para la base de datos (con nombre dinámico `db-data-${APP_NAME}`)

---

## ⚙️ Arquitectura de contenedores

| Servicio | Rol | Puerto host |
|-----------|-----|-------------|
| **app** | PHP‑FPM + Composer + Node (Vite, Artisan, etc.) | 5173 (Vite) |
| **web** | Nginx sirviendo `public/` y reenviando peticiones PHP al app | 8081 |
| **db** | PostgreSQL 16 con almacenamiento persistente | 5433 |

---

## ✅ Requisitos previos

- Docker  
- Docker Compose  
- Git  

> No hace falta tener PHP, Node ni PostgreSQL instalados localmente.

---

## 🪜 Flujo paso a paso (primer uso)

### 1️⃣ Crear un proyecto nuevo desde esta plantilla

En GitHub → “Use this template” → “Create a new repository”  
Luego cloná tu nuevo repo:

```bash
git clone https://github.com/TU_USUARIO/mi-nueva-app.git
cd mi-nueva-app
```

---

### 2️⃣ Preparar el entorno de Laravel y Docker

Copiá el archivo de entorno de ejemplo:

```bash
cp .env.example .env
```

**IMPORTANTE:**  
Abrí el nuevo archivo `.env` y asegurate de que la variable `APP_NAME` esté definida con el nombre de tu proyecto. Docker Compose la usará para nombrar tus contenedores, redes y el volumen de la base de datos.

El bloque de base de datos está preparado para conectarse con docker:

- `DB_DATABASE` se puede modificar a gusto  
- `DB_USERNAME` se puede modificar a gusto  
- `DB_PASSWORD` se puede modificar a gusto  
- Ni `DB_CONNECTION` ni `DB_HOST` se deben modificar

```env
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
```

---

### 3️⃣ Levantar los contenedores (primera vez)

```bash
docker compose up -d --build
```

Esto:

- Construye las imágenes (PHP, Node, etc.)
- Crea los tres contenedores (`app`, `web`, `db`)
- Crea el volumen persistente para PostgreSQL (usando el nombre dinámico definido con `APP_NAME`)

Verificá que estén corriendo:

```bash
docker compose ps
```

---

### 4️⃣ Instalar dependencias y preparar la app

Entrá al contenedor `app`:

```bash
docker compose exec app bash
```

Dentro del contenedor:

```bash
# dependencias PHP
composer install

# dependencias JS (Vue / Inertia / Vite)
npm install

# generar clave de aplicación
php artisan key:generate

# migraciones iniciales
php artisan migrate
```

---

### 5️⃣ Levantar el entorno de desarrollo (Vite + Laravel)

Dentro del contenedor `app`:

```bash
composer run dev
```

Este comando ejecuta simultáneamente:

- `npm run dev -- --host 0.0.0.0` → Vite con hot‑reload  
- `php artisan queue:listen` → procesamiento de colas  
- `php artisan pail` → visor de logs en tiempo real

Abrí en el navegador:

- **App Laravel:** [http://localhost:8081](http://localhost:8081)  
- **Vite (HMR):** [http://localhost:5173](http://localhost:5173)

Dentro de este contenedor se deben ejecutar todos los comandos de artisan (`make`, `tinker`, etc).

---

## 🧠 Uso diario (día a día)

Una vez hecho el setup inicial, no tenés que volver a hacer el build ni reinstalar dependencias.  
Solo seguí este flujo cada vez que reinicies tu PC o cierres Docker:

### 1️⃣ Encender

Abrí Docker o asegurate de que el daemon esté corriendo.

### 2️⃣ Arrancar tus contenedores existentes

No hace falta reconstruir: los contenedores ya existen.

Podés usar cualquiera de estas formas:

```bash
# desde la carpeta del proyecto
docker compose up -d
```

O si querés desde cualquier ruta:

```bash
docker start laravel-vue-app-1 laravel-vue-web-1 laravel-vue-db-1
```

(los nombres exactos los podés ver con `docker ps -a`)

Esto prende todo el stack en segundos, con tu base y datos tal como los dejaste.

### 3️⃣ Entrar al contenedor app y correr el dev server

```bash
docker compose exec app bash
composer run dev
```

Y listo ✅  
Tu entorno queda igual que el día anterior, con todas las dependencias ya instaladas.

En caso de tener problemas a la hora de guardar (pide permisos sudo) se puede ejecutar este comando:
```sudo chown -R $USER:$USER /ruta/a/tu/proyecto```
---

## 🧩 Cuándo volver a hacer `docker compose up -d --build`

Solo si:

- Cambiás el `Dockerfile` (por ejemplo, actualizás PHP o Node).  
- Cambiás dependencias globales que requieren rebuild.  
- Borrás los contenedores con `docker compose down`.  
- Clonás el proyecto en otra máquina.

Fuera de eso, no es necesario rebuild diario.

---

## 🧰 Gestión de contenedores

| Acción | Comando | Descripción |
|--------|----------|-------------|
| Ver estado | `docker compose ps` | Muestra los contenedores y puertos activos |
| Detener todo | `docker compose down` | Apaga los contenedores pero mantiene el volumen de DB |
| Reiniciar rápido | `docker compose restart` | Reinicia los servicios sin rebuild |
| Borrar todo (incluye base) | `docker compose down -v` | Elimina contenedores y volúmenes |
| Acceder a la consola del app | `docker compose exec app bash` | Entrar a PHP + Node + Composer |

---

## 🧱 Git y versión del código

Git se usa siempre fuera del contenedor.  
Trabajá en tu proyecto normalmente desde la carpeta en tu máquina (`/home/usuario/mi-nueva-app`).

Todo el código del proyecto está montado dentro del contenedor `app` como volumen:  
cualquier cambio que hagas en tu editor local se refleja automáticamente adentro.

No es necesario ejecutar comandos de Git dentro del contenedor.

Ejemplo de flujo:

```bash
# fuera del contenedor
git status
git add .
git commit -m "nueva funcionalidad"
git push origin main
```

---

## 🔌 Acceso a PostgreSQL desde el host

| Recurso | Nombre real |
|----------|--------------|
| **Host** | 127.0.0.1 |
| **Puerto** | 5433 |
| **Usuario** | El definido en DB_USERNAME |
| **Contraseña** | La definida en DB_PASSWORD |
| **Base de datos** | La definida en DB_DATABASE |

Podés conectar un cliente como **DBeaver**, **TablePlus** o **DataGrip** con esos datos.

---

## 🧹 Limpieza opcional

Si querés reiniciar todo desde cero (por ejemplo, para probar la plantilla limpia):

```bash
docker compose down -v
docker compose up -d --build
```

Eso borra los datos de la base y reconstruye el entorno completo.

---

## 🧾 Resumen rápido del flujo diario

| Paso | Acción | Comando |
|------|---------|----------|
| 1 | Encender Docker | (abrir Docker Desktop) |
| 2 | Levantar contenedores existentes | `docker compose up -d` |
| 3 | Entrar al contenedor app | `docker compose exec app bash` |
| 4 | Levantar entorno dev | `composer run dev` |
| 5 | Empezar a trabajar 🎯 | Abrir [http://localhost:8081](http://localhost:8081) |

---

Con este flujo tenés un entorno **profesional, portable y reproducible**, idéntico a producción,  
pero con la comodidad de desarrollo local.  
Tu máquina solo necesita **Docker + Git — nada más.**


# Flujo de Producción - Laravel 12 + Vue + Docker + PostgreSQL

Esta sección describe cómo desplegar tu proyecto en un entorno de **producción**, usando la misma plantilla de desarrollo pero con configuración optimizada para VPS.

---

## Requisitos previos en el VPS

* Docker
* Docker Compose
* Acceso SSH al servidor
* Dominio o IP pública (para APP_URL y Nginx)

> No hace falta instalar PHP, Node ni PostgreSQL en el VPS; todo corre en contenedores.

---

## Flujo paso a paso para producción

### 1️⃣ Clonar el proyecto en el VPS

```bash
git clone https://github.com/TU_USUARIO/mi-nueva-app.git
cd mi-nueva-app
```

### 2️⃣ Crear el archivo de entorno

```bash
cp .env.example .env
```

Editar `.env` con los valores de **producción**:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://midominio.com
APP_KEY=

DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=clave_segura
```

> Ajustar otros secretos según Redis, AWS, mail, etc.

### 3️⃣ Levantar contenedores en modo producción

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

Verificar que estén corriendo:

```bash
docker compose -f docker-compose.prod.yml ps
```

### 4️⃣ Instalar dependencias y preparar la app

Entrar al contenedor `app`:

```bash
docker compose -f docker-compose.prod.yml exec app bash
```

Dentro del contenedor:

```bash
composer install --optimize-autoloader --no-dev
npm ci
npm run build
php artisan key:generate --no-interaction
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

> ⚠️ `--force` es necesario para migraciones en producción.

### 5️⃣ Verificar la app en el navegador

* App Laravel: `https://midominio.com`
* Logs: `docker compose -f docker-compose.prod.yml exec app tail -f storage/logs/laravel.log`

---

## Gestión de contenedores en producción

| Acción              | Comando                                                   | Descripción                                    |
| ------------------- | --------------------------------------------------------- | ---------------------------------------------- |
| Ver estado          | `docker compose -f docker-compose.prod.yml ps`            | Muestra contenedores y puertos activos         |
| Reiniciar servicios | `docker compose -f docker-compose.prod.yml restart`       | Reinicia contenedores sin rebuild              |
| Detener todo        | `docker compose -f docker-compose.prod.yml down`          | Apaga contenedores pero mantiene volumen de DB |
| Borrar todo         | `docker compose -f docker-compose.prod.yml down -v`       | Elimina contenedores y volúmenes               |
| Acceder a consola   | `docker compose -f docker-compose.prod.yml exec app bash` | Entrar al contenedor app                       |

---

## Nota

* Se mantiene el flujo de desarrollo `cp .env.example .env`; solo cambian los valores.
* Los contenedores de producción **no montan el código como volumen**, se trabaja sobre la copia incluida en la imagen.
* Las dependencias y compilaciones frontend se hacen **una sola vez** durante el build y la instalación dentro del contenedor.

Con esto, tu proyecto queda listo para producción en un VPS usando la misma plantilla que usás para desarrollo.
