# shiny_deploy
A deployment repo for a Shiny server

## Building it

```
docker build -t jakelever/shiny_deploy .
docker push jakelever/shiny_deploy
```

## Running it locally

```
docker run -p 80:80 jakelever/shiny_deploy
```

## Deploying on a DigitalOcean droplet

- Create the 1GB RAM droplet (with a Docker image)
  - Create through Droplets and **not** through the App Platform
- Open a terminal and run:
  - `docker run -d -p 80:80 --name deploy_container jakelever/shiny_deploy`
- Redeploy with the below before running above:
  - `docker stop deploy_container && docker rm deploy_container`
  - `docker pull jakelever/shiny_deploy`
- Update DNS records accordingly
