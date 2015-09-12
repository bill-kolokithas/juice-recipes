# Juice Recipes

##### A demo site to index and search juice recipes scrapped off the web.

It is using Elasticsearch as the (only) persistence layer and more specifically the ActiveRecord Pattern.  
Unfortunately this means losing some functionality of Elasticsearch::Model like import tasks, pagination etc.

##### What's inside

- Custom rake task for importing data from .json
- Custom pagination since neither kaminari nor will_paginate works
- Score using [Wilson lower bound](http://www.evanmiller.org/how-not-to-sort-by-average-rating.html) modified for a 5-star rating system
- 5-star rating using [Raty](http://wbotelhos.com/raty) and ajax to recalculate score instantly
- Sorting by combining relevancy and score using elastic's function_score
- Auto completion with fuzziness using jquery-ui-autocomplete module
- Search through ingredients using the english analyzer
- Filter by juice color
- Filter by ingredient using aggregations in the sidebar
- Custom analyzer using my own [token filter plugin](https://github.com/freestyl3r/elasticsearch-inflections-token-filter) to singularize and only keep ingredients from a whitelist in a subfield
- Identify juice color by using [opencv and scikit-learn's k-means algorithm](http://www.pyimagesearch.com/2014/05/26/opencv-python-k-means-color-clustering/) to find the main color in the picture and then calculate the color difference between juice colors using [delta e equations](http://python-colormath.readthedocs.org/en/latest/delta_e.html) (not yet integrated)

##### What's missing

- Integrate opencv in an admin panel that requires confirmation before applying found color
- Use session for ratings and highlighting
- Testing
- Better design
- More...
