# tuleap-docker

## Usage
```sh
docker run --detach --name tuleap \
  -p 80:80 -p 443:443 \
  --env DEFAULT_DOMAIN=localhost \
  --env ORG_NAME="Tuleap" \
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
  --env DEFAULT_DOMAIN=localhost \
  --env ORG_NAME="Tuleap" \
  -v tuleap-data:/data \
  jariasl/tuleap
```

## Show logs
```sh
docker logs -f tuleap
```

