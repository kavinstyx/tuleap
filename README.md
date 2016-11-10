# tuleap-docker

## Usage
```sh
docker run --detach --name tuleap \
  -p 80:80 -p 443:443 \
  --env DEFAULT_DOMAIN=localhost \
  jariasl/tuleap
```

## Recover admin password
```sh
docker exec tuleap /bin/bash -c "cat /root/todo_tuleap.txt"
```

## Show logs
```sh
docker logs -f tuleap
```

