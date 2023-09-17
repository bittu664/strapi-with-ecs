# strapi-with-ecs

**HERE IS YOUR WORKING URL FOR PROD AND STAGE**

**FOR PROD** https://strapi.axceskart.com/admin/

**FOR STAGE** https://staging-strapi.axceskart.com/admin/



**STEPS TO CREATE THIS WHOLE PROJECT**


**NOTE** HERE I AM USING MY OWN EC2 SERVER TO PERFORM THIS TASK (for example creating the apps, build the apps and push the apps...)


**Step-1:** First of all you need to create strapi project with customs settings and choose postgres-client, below you can find commands & screen shots...

```
npx create-strapi-app@latest strapi-with-pg
```

![Screenshot](initial.png)

**Step-2:** After that go to this folder and create Dockerfile for containerize this strapi applications and create database.js file and .dockerignore file in here the content of database.js and .dockerignore file.

**for database.js**

```
module.exports = ({ env }) => ({
    connection: {
      client: 'postgres',
      connection: {
        host: env("DATABASE_HOST"),
        port: env.int("DATABASE_PORT"),
        database: env("DATABASE_NAME"),
        user: env("DATABASE_USERNAME"),
        password: env("DATABASE_PASSWORD"),
        ssl: {
          rejectUnauthorized: env.bool('DATABASE_SSL_SELF', false), // For self-signed certificates
        },
      },
      debug: false,
    },
  });

```
**for .dockerignore** 

```
node_modules/
.tmp/
.cache/
.git/
build/
```

**Step-3:** Now build the dockerfile for both prod and stage and push into ECR repository... 

**Here is the command for build**

```
docker build -t mystrapiopss:latest  --build-arg NODE_ENV=production .
```
Here ECR gives me how to push this image on ECR so i will not show here due to personal data informations...

**NOTE** one more thing is during the build it gives me lots of dependencies error, but after debugging and researching i found that the problem is in the node alpine base image so i changed from to official node:18.17.1-buster.

