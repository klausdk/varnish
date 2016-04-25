# VCL script for Varnish 3


backend default {
  .host = "127.0.0.1";
  .port = "80";
}


backend a_tile {
  .host = "a.tile.openstreetmap.org";
  .port = "80";
}

backend b_tile {
  .host = "b.tile.openstreetmap.org";
  .port = "80";
}

backend c_tile {
  .host = "c.tile.openstreetmap.org";
  .port = "80";
}

sub vcl_recv {

  if (req.http.host ~ "^a.tile") {
    set req.backend = a_tile;
  } else if (req.http.host ~ "^b.tile") {
    set req.backend = b_tile;
  } else if (req.http.host ~ "^c.tile") {
    set req.backend = c_tile;
  } else if (req.http.host ~ "^a.map") {
    set req.backend = a_tile;
  } else if (req.http.host ~ "^b.map") {
    set req.backend = b_tile;
  } else if (req.http.host ~ "^c.map") {
    set req.backend = c_tile;
  }

  remove req.http.cookie;

  // Cache everything
  if (req.request == "GET") {
    return (lookup);
  }


}

sub vcl_fetch {

  // Cache tiles for 3 weeks
  set beresp.ttl = 3w;

  // Remove all cookies
  remove beresp.http.set-cookie;
  remove beresp.http.cookie;

}

sub vcl_deliver {

        
  if (obj.hits > 0) {
    set resp.http.X-Cache_v = "HIT";
  } else {
    set resp.http.X-Cache_v = "MISS";
  }
}

sub vcl_hash {

  // Cache using only url as a hash.  
  // This means if a.tile/1/1/1/tile.png is accessed, b.tile/1/1/1/tile.png will also be fetch from cache
  hash_data(req.url);
  return (hash);
}


