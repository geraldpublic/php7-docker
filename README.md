# php7-docker

PHP 7 FPM on Alpine Linux with the PHP extensions needed by web applications such as [Piwigo](https://piwigo.org/): MySQL support, EXIF and GD with JPEG and FreeType.

Based on the official [`php:7-fpm-alpine`](https://hub.docker.com/_/php) image and rebuilt regularly with current security patches.

> **PHP 7 has reached end of life** and no longer receives security fixes from the PHP project. Use this image only for legacy applications that cannot run on PHP 8 yet, and do not expose it directly to untrusted networks. For new setups use [`gerald77/php8-docker`](https://hub.docker.com/r/gerald77/php8-docker).

- **Image:** `gerald77/php7-docker`
- **Tags:** `latest`
- **Source:** https://github.com/geraldpublic/php7-docker
- **Base:** `php:7-fpm-alpine`
- **Port:** `9000` (PHP-FPM / FastCGI)

## Included PHP extensions

| Extension | Purpose |
| :-- | :-- |
| `mysqli`, `pdo`, `pdo_mysql` | MySQL / MariaDB access |
| `exif` | Read photo metadata |
| `gd` (with JPEG and FreeType) | Image processing, thumbnails, text rendering |

All other extensions are those of the official PHP image, unchanged. ImageMagick (`imagick`) is **not** included. If you need more extensions, build your own image with `FROM gerald77/php7-docker`.

## Quick start

PHP-FPM speaks FastCGI, so you need a web server such as Nginx in front of it.

```shell
docker network create web

docker run -d --name php --network web \
    -v /path/to/your/site:/var/www/html \
    gerald77/php7-docker:latest
```

## Docker Compose with Nginx

```yaml
services:
  php:
    image: gerald77/php7-docker:latest
    container_name: php7-docker
    restart: unless-stopped
    environment:
      - TZ=Europe/Vienna
    volumes:
      - ./site:/var/www/html

  nginx:
    image: nginx:stable-alpine
    container_name: nginx
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./site:/var/www/html:ro
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - php
```

Minimal `nginx.conf`:

```nginx
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

The web root must be mounted at the **same path** in both containers so that `SCRIPT_FILENAME` resolves correctly.

## Configuration

Use the standard mechanisms of the official PHP image: mount a `.ini` file to `/usr/local/etc/php/conf.d/` (e.g. `upload_max_filesize`, `memory_limit`) or a pool file to `/usr/local/etc/php-fpm.d/`.

```yaml
    volumes:
      - ./custom.ini:/usr/local/etc/php/conf.d/custom.ini:ro
```

## Notes

- Do not publish port 9000 to the internet; PHP-FPM has no authentication. Keep it on an internal Docker network.
- The image is rebuilt automatically on every push to the source repository; pull regularly to get security updates.

## License

The Dockerfile and related files of this project are licensed under the **GNU General Public License v3.0** (GPL-3.0). See the [LICENSE](https://github.com/geraldpublic/php7-docker/blob/main/LICENSE) file in the source repository.

PHP is licensed under the [PHP License](https://www.php.net/license/). Alpine Linux and other included software are under their respective licenses; see the files in `/usr/share/licenses` and `/usr/share/doc` inside the container.

## Disclaimer

THIS IMAGE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR MAINTAINERS BE LIABLE FOR ANY CLAIM, DAMAGES, DATA LOSS OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE IMAGE OR ITS USE.

Use at your own risk. You are responsible for securing your deployment (network access, updates, application code) and for backing up your data.
