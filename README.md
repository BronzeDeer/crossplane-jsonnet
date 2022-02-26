# Crossplane

NOTE: not to be confused with [jsonnet-libs/crossplane-libsonnet](https://github.com/jsonnet-libs/crossplane-libsonnet), which allows configuring the crossplane specific CRDs (e.g. Provider). For a fully jsonnet-based workflow, you would first use this to deploy an instance of crossplane to a cluster and then use jsonnet-libs/crossplane-libsonnet to configure additional Providers, Packages etc.

This repo contains a small library of jsonent files that can be used to deploy the crossplane controller to a kubernetes cluster. It is intended to present an alternative to the [official helm chart](https://github.com/crossplane/crossplane/tree/master/cluster/charts/crossplane).

## Quickstart

```jsonnet
local crossplane = import "github.com/BronzeDeer/crossplane-jsonnet/main.libsonnet";

(
  crossplane.new("crossplane")
  + crossplane.withNamespace("custom-namespace") //optional, default ns is "crossplane-system"
).flatten() // Turn into list of manifests
```

## Dependencies

This repository can be used directly as a git submodule, without requiring the use of jsonnet-bundler or other tools. This is achieved by vendoring all but two (see below) dependencies and using only relative imports. The files `jsonnetfile.json` and `jsonnetfile.lock.json` are included in the repository to aid in tracking and updating said vendored dependencies.

Two dependencies are not vendored:

- k.libsonnet/k8s-libsonnet: The exact variant of the base kubernetes library is historically expected to be on the jpath as 'k.libsonnet'. It is expected that deployment tool or pipeline will configure the correct version for each targeted cluster. If you use [Tanka](https://tanka.dev), this will be done for you automatically, for local development without Tanka, you can use [k8s-libsonnet-helper](https://github.com/BronzeDeer/k8s-libsonnet-helper).

- doc-util: As the [docsonnet FAQ](https://github.com/jsonnet-libs/docsonnet) states, during normal evaluation, the docsonnet specific keys will never be touched, making `doc-util` an optional dependency, however linters and similar tools will typically try to evaluate every key, necessitating the presence of `doc-util` on the jpath.

## Development

Some rudimentary tests are included in `tests/`. When evaluating a test file make sure the correct `k.libsonnet` for your specific kubernetes version is on the jpath
