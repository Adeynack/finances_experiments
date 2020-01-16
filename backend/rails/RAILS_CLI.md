Finances Backend in Ruby on Rails (Take 2)
===

## Create Project

This command was used to create the initial project.

```bash
rails new . --api --database=postgresql
```

## Create first resources

```bash
bin/rails g model User email:string display_name:string
bin/rails g model Book name:string user:references
```
