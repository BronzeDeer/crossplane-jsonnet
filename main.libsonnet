local k = import './vendor/github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

local d = import 'doc-util/main.libsonnet';

local deploy = k.apps.v1.deployment;
local deploy_sts = deploy.spec.template.spec;
local container = k.core.v1.container;
local vol = k.core.v1.volume;
local vol_mnt = k.core.v1.volumeMount;
local sa = k.core.v1.serviceAccount;

local envVar = k.core.v1.envVar;

{
  '#':: d.pkg(
    name='crossplane',
    url='github.com/BronzeDeer/crossplane-jsonnet/main.libsonet',
    help='`crossplane-jsonnet` implements manifests necessary to deploy crossplane to your cluster. It is intended to roughly mirror the capabilities of the official helm chart',
  ),

  '#new':: d.fn('Create a new deployment of crossplane in namespace `crossplane-system`. Use bound method `flatten()` to surface manifests for GitOps deployment',
                [d.arg('name', d.T.string)]),
  new(name):: {
    local this = self,

    _config:: {
      name: name,
      replicas: 1,
      // Explicitly set namespace to ensure crb gets subject set correctly
      namespace: 'crossplane-system',

      packageCacheVolume: vol.fromEmptyDir('package-cache'),
    },

    _images:: {
      crossplane: 'crossplane/crossplane:v1.6.3-4.gfb713126',
      crossplane_init: self.crossplane,
    },

    serviceAccount: sa.new(this._config.name)
                    + sa.metadata.withNamespace(this._config.namespace),

    deployment: deploy.new(
                  name=this._config.name,
                  replicas=this._config.replicas,
                  containers=[
                    container.new(
                      name='crossplane',
                      image=this._images.crossplane,
                    )
                    + container.withArgs(['core', 'start'])
                    + container.withEnv(envVar.fromFieldPath('POD_NAMESPACE', 'metadata.namespace'))
                    + container.withVolumeMounts(
                      vol_mnt.new(
                        name=this._config.packageCacheVolume.name,
                        mountPath='/cache',
                        readOnly=false,
                      )
                    ),
                  ],
                )
                + deploy.metadata.withNamespace(this._config.namespace)
                + deploy_sts.withInitContainers([
                  container.new(
                    name='crossplane-init',
                    image=this._images.crossplane_init,
                  )
                  + container.withArgs(['core', 'init']),
                ])
                + deploy_sts.withServiceAccountName(this.serviceAccount.metadata.name)
                + deploy_sts.withVolumes(this._config.packageCacheVolume),

    '#flatten':: d.fn('Surface the contained manifests in a list so that they can be turned into a yaml or json stream for deployment'),
    flatten():: this.manifests,

    manifests:: [
      this.deployment,
      this.serviceAccount,
    ],
  } + (import './clusterrole.libsonnet')
  ,

  '#withName':: d.fn('Base name of the crossplane deployment. Useful to deconflict deployments to the same cluster',
                     [d.arg('name', d.T.string)]),
  withName(name):: {
    _config+:: {
      name: name,
    },
  },

  '#withNamespace':: d.fn('Namespace to deploy to, default is `crossplane-system`',
                          [d.arg('namespace', d.T.string)]),
  withNamespace(namespace):: {
    _config+:: {
      namespace: namespace,
    },
  },

  '#withCrossplaneImage':: d.fn('Container Image that provides both main and init functionality',
                                [d.arg('image', d.T.string)]),
  withCrossplaneImage(image):: {
    _images+:: {
      crossplane: image,
    },
  },

  '#withPackageCacheVolume':: d.fn('Volume to use as package cache, type is core.v1.volume. Default is an emptyDir',
                                   [d.arg('volume', d.T.object)]),
  withPackageCacheVolume(vol):: {
    config+:: {
      packageCacheVolume: vol,
    },
  },
}
