#!/bin/bash
set -e

echo "Aguardando PostgreSQL..."
for i in $(seq 1 30); do
  pg_isready -h db -p 5432 -U postgres 2>/dev/null && break
  echo "  tentativa $i/30 — aguardando..."
  sleep 2
done

echo "Executando migrações..."
bundle exec rails db:prepare

echo "Iniciando servidor Rails..."
exec "$@"
