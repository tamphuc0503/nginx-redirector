# nginx
- A nginx combined with ngx-geoip module to detect region and redirect to correct domain or subpath.

# build
- docker build -f Dockerfile -t aprilsea/as:nginx .

# testing:
## Directly:

## Loadbalancer:
- In LB nginx, we will have the variable $http_x_real_ip so in upstream, we will check this $http_x_real_ip to get client IP and lookup in geoip

# References:
- https://www.digitalocean.com/community/tutorials/how-to-use-nginx-as-a-global-traffic-director-on-debian-or-ubuntu