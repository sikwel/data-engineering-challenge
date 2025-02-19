# Ich versteh's so, dass wir mit Longitude und Latitude die Daten abfragen wollen.
# Eine Abfrage mit dem Regions-Namen ist nicht gewünscht.
# Daher würd ich jetzt ein Mapping anlegen, dass die gewünschten Regionen mit Koordinaten verknüpft

# Das hier kann dann als kleiner Helfer dafür fungieren:

import pandas as pd
import requests

regions = pd.read_csv(
    r"M:\Code\sikwel_codingchallenge\data-engineering-challenge\data\AdventureWorks2022\Region.csv",
    sep="\t"
    )


for index, row in regions.iterrows():

    key = row["SalesTerritoryKey"]
    region_name = row["Region"]
    country_name = row["Country"]

    url_search_region = rf"https://geocoding-api.open-meteo.com/v1/search?name={region_name}"
    response = requests.get(url_search_region)
    data = pd.json_normalize(response.json(), record_path="results").loc[0]
    
    if data["country"] == country_name:
        print(f"{key}", data["latitude"], data["longitude"]    )
    else:
        print(f"{region_name} does not have a matching country name: {country_name}", data["country"])
    
# Now this could be written into csv automatically, but i will just copy paste it and fix one value by hand,
# searching lat and long by open-meteo text search 
# https://open-meteo.com/en/docs


