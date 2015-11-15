#LPTours Webservice [ ![Codeship Status for ZhongMeiZhou/scraper_webAPI](https://codeship.com/projects/5a3f7fb0-62aa-0133-fec9-1af77e49650b/status?branch=master)](https://codeship.com/projects/112659)

## Endpoint
  
  ```sh
 http://zmztours.herokuapp.com/
 ```


## Description

A simple web service that scrapes Lonely Planet tours by country using the [lonely_planet_tours](https://github.com/ZhongMeiZhou/scraper_project) gem


## Usage and Examples

Handles:

- GET /
  - SAMPLE REQUEST => http://localhost:3000

- GET /api/v1/taiwan_tours (deprecated)
  - RETURNS => JSON
  - SAMPLE REQUEST => http://localhost:3000/api/v1/taiwan_tours

- GET /api/v1/tours/[:param].json
  - ACCEPTS => [:param] as the country of interest to get tour listings
  - RETURNS => JSON
  - SAMPLE REQUEST => http://localhost:3000/api/v1/tours/japan.json

- POST /api/v1/tours
  - ACCEPTS => country name in JSON format
  - RETURNS => JSON
  - SAMPLE REQUEST =>  curl -v -H "Accept: application/json" -H "Content-type: application/json" \ -X POST -d "{\"country\":\"Honduras\"}" http://localhost:3000/api/v1/tours
