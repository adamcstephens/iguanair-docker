# igauanair-docker

## build

**OPTIONS**
* target
  * flags: -t --target
  * type: string
  * desc: Which docker stage to target

```bash
TARGET=${target:-final}
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

docker build -t local/iguanair . --target $TARGET --build-arg S6_ARCH=$S6_ARCH --build-arg DEB_ARCH=$DEB_ARCH
```
