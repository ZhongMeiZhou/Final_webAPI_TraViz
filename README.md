#TraViz Webservice [ ![Codeship Status for ZhongMeiZhou/Final_webAPI_TraViz](https://codeship.com/projects/9ea65a20-81e3-0133-22f1-22940a7a47c6/status?branch=master)](https://codeship.com/projects/121399)

## Endpoint
  
 [https://dynamozmz.herokuapp.com/] (https://dynamozmz.herokuapp.com/)


## Description

A simple web service that scrapes Lonely Planet tours based on several parameters using the [lonely_planet_tours](https://github.com/ZhongMeiZhou/scraper_project) gem

## Recent Changes
 - Added functionality to generate the number of tours per country based on tour categories and price range which will be used to generate a visualization of tour results


## Usage and Examples

Handles:

- GET /
  - SAMPLE REQUEST => http://localhost:3000

- GET /api/v2/taiwan_tours (deprecated)
  - RETURNS => JSON
  - SAMPLE REQUEST => http://localhost:3000/api/v2/taiwan_tours

- GET /api/v2/tours/[:param].json
  - ACCEPTS => [:param] as the country of interest to get tour listings
  - RETURNS => JSON
  - SAMPLE REQUEST => http://localhost:3000/api/v2/tours/japan.json

- GET /api/v2/tours/[:id]
  - ACCEPTS => [:id] as the id of the country of interest to get tour listings
  - RETURNS => JSON
  - SAMPLE REQUEST => http://localhost:3000/api/v2/tours/12

- POST /api/v2/tours
  - ACCEPTS => country name in JSON format
  - RETURNS => JSON
  - SAMPLE REQUEST =>  curl -v -H "Accept: application/json" -H "Content-type: application/json" \ -X POST -d "{\"country\":\"Honduras\"}" http://localhost:3000/api/v2/tours

- POST /api/v2/tour_compare
  - ACCEPTS => multiple countries, categories and a price range
  - RETURNS => JSON
  - SAMPLE REQUEST =>  curl -v -H "Accept: application/json" -H "Content-type: application/json" \ -X POST -d 
  "{\"tour_countries\":[\"Honduras\", \"Belize\"],
  \"tour_categories\":[\"Cycling\", \"Small Group Tours\"],
  \"inputPriceRange\":\"200;800\"}" http://localhost:3000/api/v2/tour_compare
