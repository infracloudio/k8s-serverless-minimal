# Serverless
Minimal serverless platform on top of Kubernetes

## How to install
Copy deploy folder to `~/.kube/plugin`. Once copied, plugin commands are available as `kubectl plugin deploy`.

## Usage
```
kubectl plugin deploy -h
Deploys given app

Options:
  -u, --undeploy='false': Delete the app

Usage:
  kubectl plugin deploy [flags] [options]

```
