# How to upgrade varnish3 to 4, with minimum downtime on redhat/centos 6

Make sure you have a tested vcl file that works with varnish 4

requires stuff from epel repo

Remove old version

```
yum erase varnish-release-3.0-1.noarch
yum erase varnish
```

install new varnish

```
rpm --nosignature -i https://repo.varnish-cache.org/redhat/varnish-4.0.el6.rpm
```


```
yum install varnish
```

setup configfiles
```
mv -n /etc/sysconfig/varnish /etc/sysconfig/varnish_org
```

edit /etc/sysconfig/varnish to point to your vcl file


stop current varnish. It should still run in memory, even if it is erased
```
killall varnishd
```

start varnish
```
service varnish start
chkconfig varnish on
```
