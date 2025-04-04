# Базовый образ PHP с поддержкой FPM
FROM php:7.4-fpm

# Установим Nginx
RUN apt-get update && apt-get install -y nginx

# Скопируем файлы приложения в контейнер
COPY . /var/www/html/

# Установим права доступа для веб-сервера
RUN chown -R www-data:www-data /var/www/html

# Скопируем конфигурационный файл Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Запустим PHP-FPM и Nginx
CMD service php7.4-fpm start && nginx -g "daemon off;"

# Откроем порт 80
EXPOSE 80
