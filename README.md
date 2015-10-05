# Juice Recipes

##### A demo site to index and search juice recipes scrapped off the web.

It is using Elasticsearch as the (only) persistence layer and more specifically the ActiveRecord Pattern.  
Unfortunately this means losing some functionality of Elasticsearch::Model like import tasks, pagination etc.

##### What's inside

- Custom rake task for importing data from .json
- Custom pagination since neither kaminari nor will_paginate works
- Score using [Wilson lower bound](http://www.evanmiller.org/how-not-to-sort-by-average-rating.html) modified for a 5-star rating system
- 5-star rating using [Raty](http://wbotelhos.com/raty) and ajax to recalculate score instantly
- 4 different sorting methods depending if there is a query or not
  - Randomly to improve juice discoverability
  - By the custom score calculated using Wilson lower bound
  - By elastic's relevance
  - By combining the two above plus some extra boosts & factors
- Auto complete juice titles with fuzziness using jquery-ui-autocomplete module
- Search through titles, ingredients & tags using the english analyzer
- Filter by juice color
- Filter by ingredient using aggregations in the sidebar
- Combine juice color, ingredient filter, query and sort at the same time
- Use sessions to uniquely seed the random sorting for each user, keep track of his votes and highlight juice ingredients & tags that matched the query
- Sessions auto-expire after a few minutes of not using the site but highlighting also resets when the juice listing changes (visiting any other page than a juice view)
- Sessions use [redis](https://github.com/roidrage/redis-session-store) for storage in order for the highlighting feature to work, since it was exceeding the 4kb limit of cookies.  
- Custom analyzer using my own [token filter plugin](https://github.com/freestyl3r/elasticsearch-inflections-token-filter) to singularize and only keep whitelisted ingredients in a subfield
- Identify juice color by using [opencv and scikit-learn's k-means algorithm](http://www.pyimagesearch.com/2014/05/26/opencv-python-k-means-color-clustering/) to find the main color in the picture and then calculate the color difference between juice colors using [delta e equations](http://python-colormath.readthedocs.org/en/latest/delta_e.html) (not yet integrated)

##### What's missing

- Integrate opencv in an admin panel that requires confirmation before applying found color
- Design not responsive enough for smaller screens and tablets
- Testing
- More...
