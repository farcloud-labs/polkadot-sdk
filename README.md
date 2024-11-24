## SMT Test Node

### build docker
```bash
docker buildx build --platform linux/arm64,linux/amd64 -t yanoctavian/smt-node:latest . --push 
```

### build local

```bash
cargo build --release -p staging-node-cli
```