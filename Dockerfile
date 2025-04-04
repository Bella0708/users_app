# Базовый образ PHP с поддержкой FPM
FROM php:7.4-fpm

# Скопируем файлы приложения в контейнер
COPY . /var/www/html/

# Установим права доступа для веб-сервера
RUN chown -R www-data:www-data /var/www/html

# Скопируем конфигурационный файл Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Запустим PHP-FPM
CMD ["php-fpm"]
