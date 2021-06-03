# igauanair-docker

## build

**OPTIONS**
* target
  * flags: --target
  * type: string
  * desc: Which docker stage to target
* tag
  * flags: -t --tag
  * type: string
  * desc: Docker image tag
* force
  * flags: -f --force
  * desc: No cache


```bash
TAG=${tag:-local/iguanair}
TARGET=${target:-final}
if [[ -n $force ]]; then
  FORCE="--no-cache"
fi

if [[ "$(uname -m)" == "x86_64" ]]; then
  S6_ARCH=amd64
  DEB_ARCH=amd64
elif [[ "$(uname -m)" == "x86_64" ]]; then
  S6_ARCH=aarch64
  DEB_ARCH=arm64
else
  echo "unsupported arch"
  exit 1
fi

export DOCKER_BUILDKIT=1

set -x
buildah bud -f Dockerfile --tag $TAG --target $TARGET --build-arg S6_ARCH=$S6_ARCH --build-arg DEB_ARCH=$DEB_ARCH $FORCE .
```

### build build

```bash
$MASK build  --tag local/iguanair-build --target build
```
