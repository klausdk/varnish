# VCL script for varnish 4

vcl 4.0;

backend default {
  .host = "127.0.0.1";
  .port = "80";
}


backend a_tile {
  .host = "151.101.2.217";
  .port = "80";
}

backend b_tile {
  .host = "151.101.66.217";
  .port = "80";
}

backend c_tile {
  .host = "151.101.130.217";
  .port = "80";
}

sub vcl_recv {

  if (req.http.host ~ "^a.tile") {
    set req.http.host = "a.tile.openstreetmap.org";
    set req.backend_hint = a_tile;
  } else if (req.http.host ~ "^b.tile") {
    set req.http.host = "b.tile.openstreetmap.org";
    set req.backend_hint = b_tile;
  } else if (req.http.host ~ "^c.tile") {
    set req.http.host = "c.tile.openstreetmap.org";
    set req.backend_hint = c_tile;
  } else if (req.http.host ~ "^a.map") {
    set req.backend_hint = a_tile;
  } else if (req.http.host ~ "^b.map") {
    set req.backend_hint = b_tile;
  } else if (req.http.host ~ "^c.map") {
    set req.backend_hint = c_tile;
  }

  unset req.http.cookie;

  // Cache everything
  if (req.method == "GET") {
    return (hash);
  }


}

sub vcl_backend_response {

  // Cache tiles for 3 weeks
  set beresp.ttl = 3w;

  // Remove all cookies
  unset beresp.http.set-cookie;
  unset beresp.http.cookie;

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
  return (lookup);
}

