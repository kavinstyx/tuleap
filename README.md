# tuleap-docker

## Usage
```sh
docker run --detach --name tuleap \
  -p 80:80 -p 443:443 \
  --env DEFAULT_DOMAIN=127.0.0.1 \
  jariasl/tuleap
```

## Recover admin password
```sh
docker exec tuleap /bin/bash -c "cat /root/.tuleap_passwd"
```

## Saving data volumes
```sh
docker run --detach --name tuleap \
  -p 80:80 -p 443:443 \
  --env DEFAULT_DOMAIN=127.0.0.1 \
  -v tuleap-conf-tuleap:/etc/tuleap \
  -v tuleap-data-root:/root \
  -v tuleap-data-home:/home \
  -v tuleap-data-tuleap:/var/lib/tuleap \
  -v tuleap-data-gitolite:/var/lib/gitolite \
  -v tuleap-data-mailman:/var/lib/mailman \
  -v tuleap-data-mysql:/var/lib/mysql \
  jariasl/tuleap
```

OR

```sh
docker run --detach --name tuleap \
  -p 80:80 -p 443:443 \
  --env DEFAULT_DOMAIN=127.0.0.1 \
  -v tuleap-conf:/etc/tuleap \
  -v tuleap-data:/root \
  -v tuleap-data:/home \
  -v tuleap-data:/var/lib/tuleap \
  -v tuleap-data:/var/lib/gitolite \
  -v tuleap-data:/var/lib/mailman \
  -v tuleap-data:/var/lib/mysql \
  jariasl/tuleap
```

## Show logs
```sh
docker logs -f tuleap
```

