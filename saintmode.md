# Put varnish 4 in saintmode.



Setup a probe in varnish 4


```
vcl 4 :
  .probe = {
        .url = "/saintmode.php";
        .interval = 5s;
        .timeout = 2s;
        .window = 1;
        .threshold = 1;
  }
```

Set grace time to a high value. 

```
sub vcl_backend_response {
  set beresp.grace=2d;  
}
```
  

Php script

```
<?php

  $saintmode = 0;

  if ($saintmode) {
    header("HTTP/1.0 404 Not Found");
  } else {
    echo "no saintmode";
  }


?>
```

So when you want varnish 4 to run in saintmode, set saintmode to 1 in the php script. Set it to 0 when you are done.

Varnish will be running in saintmode until $saintmode is set back to 0 or gracetime is running out. So set it to a high number, and make sure varnish has been running for a few hours/days so there will be content to deliver.


