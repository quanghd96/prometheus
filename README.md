## Create container:
- docker run -p 9090:9090 -v <config dir>:/opt/prometheus -it quanghd96/prometheus /bin/bash
## Exposed ports:
- 9090

## Volumes
- log directory: `/var/log/supervisor`
- data directory: `/var/lib/prometheus`
- config directory: `/opt/prometheus`
