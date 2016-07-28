# Magnum

![alt text][logo]
[logo]: http://24.media.tumblr.com/46cca2c3564782c411b4ac3620bde749/tumblr_ml8vskRKRd1rttchvo1_400.jpg "Magnum"
 
Magnum is the ultimate model look.  It provides general approach to dealing with Route Sets represented in JSON format


##### SuperProfile Package in json
```json
{
  "allocations": [
    { "id":"allocation_1", 
      "percentage":"100",
      "destinations": [
        "type": "Destination",
        "destination_id", 2
      ]
    { "id":"allocation_2", 
      "percentage":"100",
      "destinations: [
        "type": "Destination",
        "destination_id", 1
      ]
    }
  ],
  "labels": [
    {"id":"label_1"}, 
    {"id":"label_2"}
  ],
  "segments: [
    {"id":"segment_1", "days":"1111111", "start_time":"0","end_time":"1439"}
  ],
  "tree": {
    "segment_1": {
      "label_1": ["allocation_1"]
      "label_2": ["allocation_2"]
     }
  }
}
```

##### Current RACC Package in json
  Identical to the SuperProfile Package above but with only one label defined in a tree.

## Overview

#### Tools to interact with a tree
  - adding/removing elements of tree
  - convert to ruby object from json
  - convert to json from ruby object
  - validations
  - activation
  - conversion to package representation
  

## Installation

```ruby
gem install 'magnum-vail'
```
## Usage

A Magnum object can be created from passing in a the json string.  This will return a Magnum::SP object.  The json_string can be empty and will allow you to create a package from scratch.
A JSON RouteSet can contain One Label or Many Labels and shares TimeSegment values among Labels contained within its RouteSet.

```ruby

json_string = {}

sp = Magnum::build(json_string)
```

The Magnum::SP object can convert its segments to a different timezone
with newly created segments

```ruby

sp.convertTimeZone("Central Time(US & Canada)")
```

It can also merge into an existing Racc:Package object into the
Magnum::SP object provided the TimeSegments are matching.  The passed in
package will have its label merged into the SuperProfile by Magnum

```ruby

package = Package.first

sp.mergePackage(package)
```

A Racc VlabelMap can be moved out of the Magnum::SP object.  It will
return back a Racc Package based on the passed in label_id. 

```ruby

package = sp.extractPackage("1")
```


## Testing
### Prerequisites
* Postgres/Mysql
* Mongo

Make sure to adjust database.yml settings to your machine prior to your testing

### Initial Setup
```
$ git clone git clone https://github.com/wallywest/magnum.git
$ cd magnum
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:test:prepare
```

### Running the tests
```
$ bundle exec rake
```
