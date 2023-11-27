# waitbox

`waitbox`, a busybox-based image, is an utility built for waiting for the other pod's readiness probe in a Kubernetes environment.

## Usage

`waitbox` is recommended for use with Kubernetes' initContainer feature.

```yaml
# ...

spec: # pod spec
  initContainers:
  - name: wait-for-other-pod
    image: freckie/waitbox
    args:
    - --url
    - http://other-pod.default.svc.cluster.local:8080/health
    - --max-attempt
    - "-1"
    - --interval
    - "3"
    restartPolicy: Never # with k8s 1.28+

# ...
```

## Options
- `-u, --url <string>`: Target URL
- `-i, --interval <integer>`: Interval between attempts in seconds (default 5)
- `-m, --max-attempt <integer>`: Maximum attempts. Set -1 for infinite attempts (default -1)
- `-h, --help`: Get help for options
- `-s, --silent`: Silent mode