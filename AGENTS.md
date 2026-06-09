# AGENTS.md

## Stack

Rails 8 Todo application using SQLite in development and PostgreSQL in production. Uses ERB views and Hotwire/Turbo. Tests use the default Rails testing framework.

## Commands

Setup:

```bash
bundle install
bin/rails db:migrate
```

Run:

```bash
bin/rails server
```

Test:

```bash
bin/rails test
```

Generate resources:

```bash
bin/rails generate
```

## Conventions

Use Rails generators when creating models, controllers, and migrations. Use strong parameters in controllers. Keep reusable UI in partials. Follow Rails naming conventions.

## Don'ts

* Do not add gems without approval.
* Do not disable CSRF protection.
* Do not use html_safe on untrusted input.
* Do not commit secrets or credentials.
