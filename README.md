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
└── <category>/
  └── <module>/
    ├── service.yml
    ├── env.example
    ├── files/
    │   ├── config/
    │   └── scripts/
    └── README.md
```

Each module contains the files, configuration, and documentation required to reuse it.

## Usage

Add a module to the current project:

```bash
forge add postgis
```

Remove a module from the current project:

```bash
forge remove postgis
```

List available modules:

```bash
forge list
```

This copies the module files into the project's `ops/` directory.

Example:

```bash
forge add powersync
```

Result:

```text
ops/
├── config/
├── env/
│   └── powersync.env.example
├── scripts/
└── services/
  └── powersync.yml
```

Generate a root Docker Compose file from the copied module manifests:

```bash
forge compose
```

This writes `docker-compose.yml` in the current project root.

Generate a root `.env.example` by combining module environment templates:

```bash
forge env
```

This reads `ops/env/*.env.example` and writes a project-level `.env.example`.

Optional shortcut:

```bash
forge bootstrap
```

This runs `forge compose` and `forge env`.

## Example

Add reusable services from Forge:

```bash
forge add web
forge add postgres
forge add redis
forge add powersync
forge add pgadmin
```

Project structure after `forge compose`:

```text
my-app/
├── docker-compose.yml
└── ops/
  ├── config/
  ├── env/
  │   ├── pgadmin.env.example
  │   ├── postgres.env.example
  │   └── redis.env.example
  ├── scripts/
  └── services/
    ├── pgadmin.yml
    ├── postgres.yml
    ├── powersync.yml
    └── redis.yml
```

Generated `docker-compose.yml`:

```yaml
services:
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
