# igauanair-docker

## build

**OPTIONS**
* target
    * flags: -t --target
    * type: string
    * desc: Which docker stage to target

```bash
TARGET=${target:-final}

docker build -t local/iguanair . --target $TARGET
```
