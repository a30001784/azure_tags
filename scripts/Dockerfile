FROM buildkite/puppeteer:latest

WORKDIR /usr/src/app

COPY ./generator.js ./package.json /usr/src/app/

RUN npm install

ENV PATH="${PATH}:/node_modules/.bin"

CMD [ "npm", "start" ]