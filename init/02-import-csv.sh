#!/bin/bash
echo "=== Начало импорта CSV файлов ==="

cd /mock_data

for file in *.csv; do
    echo "Импортируем: $file"
    psql -U postgres -d petstore -c "\copy mock_data FROM '/mock_data/$file' DELIMITER ',' CSV HEADER;"
done

echo "=== Импорт завершён! ==="
psql -U postgres -d petstore -c "SELECT COUNT(*) as total_rows FROM mock_data;"
psql -U postgres -d petstore -c "SELECT * FROM mock_data LIMIT 3;"