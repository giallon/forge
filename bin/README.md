# Forge

Forge is a personal engineering catalog of reusable technologies, configurations, infrastructure, and project building blocks.

Instead of solving the same setup problems repeatedly, Forge lets you capture proven solutions and reuse them across projects.

## Philosophy

When a technology becomes stable and reusable:

1. Document it
2. Extract it into a module
3. Store it in Forge
4. Reuse it in future projects

Examples:

* PostGIS
* Redis
* PowerSync
* Rails
* Flutter
* DevContainers

## Catalog Structure

```text
catalog/
├── postgis/
├── redis-sidekiq/
├── powersync/
└── rails-api/
```

Each module contains the files, configuration, and documentation required to reuse it.

## Usage

Add a module to the current project:

```bash
forge add postgis
```

This copies the module files into the project's `ops/` directory.

Example:

```bash
forge add powersync
```

Result:

```text
ops/
├── postgis/
└── powersync/
```

## Example

Add reusable services from Forge:

```bash
forge add web
forge add postgres
forge add redis
forge add powersync
forge add pgadmin
```

Project structure:

```text
my-app/
├── docker-compose.yml
└── ops/
    └── services/
        ├── web.yml
        ├── postgres.yml
        ├── redis.yml
        ├── powersync.yml
        └── pg_admin.yml
```

Compose services using Docker Compose `extends`:

```yaml
services:
  web:
    extends:
      file: ops/services/web.yml
      service: web

    container_name: my_app_web

    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  postgres:
    extends:
      file: ops/services/postgres.yml
      service: postgres

  redis:
    extends:
      file: ops/services/redis.yml
      service: redis

  powersync:
    extends:
      file: ops/services/powersync.yml
      service: powersync

    depends_on:
      postgres:
        condition: service_healthy
```

Start the stack:

```bash
docker compose up -d
```

Forge provides reusable service definitions while the application remains responsible for orchestration and customization.

## Goals

* Build a reusable engineering catalog
* Standardize project setup
* Capture lessons learned
* Accelerate project creation
* Reduce duplicated work

## Status

Forge is currently experimental and focused on cataloging reusable infrastructure and application modules.
