# plugin initialization
t = Tab.new("pooling", "drive pooling", "/tab/pooling")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "partitions")
t.add("shares", "shares",true)
t.add("status","status",true)