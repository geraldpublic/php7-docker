FROM php:7-fpm-alpine

LABEL version="2023-12-28"
LABEL description="PHP + Extensions - mysqli/imagick"

RUN docker-php-ext-install mysqli pdo pdo_mysql exif && \
  apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
   docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j$(nproc) gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

EXPOSE 9000
