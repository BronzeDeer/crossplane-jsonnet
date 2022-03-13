local k = import "./vendor/github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local util = import"./cr_util.libsonnet";

local cr = k.rbac.v1.clusterRole;
local crb = k.rbac.v1.clusterRoleBinding;
local rule = k.rbac.v1.policyRule;

local crLabel = {'rbac.crossplane.io/aggregate-to-crossplane': "true"};

{

  clusterRole: cr.new(self._config.name)
  + cr.aggregationRule.withClusterRoleSelectors([
    {matchLabels: crLabel}
  ]),

  clusterRoleAggregate: cr.new(self._config.name + ":system:aggregate-to-crossplane")
  + cr.metadata.withLabelsMixin(crLabel)
  + cr.metadata.withLabelsMixin({'crossplane.io/scope':"system"})
  + cr.withRules([
      rule.withApiGroups("")
      + rule.withResources("events")
      + rule.withVerbs(["create","delete","patch","update",]),

      rule.withApiGroups("apiextensions.k8s.io")
      + rule.withResources("customresourcedefinitions")
      + rule.withVerbs(["*"]),

      rule.withApiGroups("")
      + rule.withResources("secrets")
      + rule.withVerbs(["create","get","list","patch","update","watch",]),

      rule.withApiGroups("")
      + rule.withResources("serviceaccounts")
      + rule.withVerbs(["*"]),

      rule.withApiGroups(["extensions","apps"])
      + rule.withResources("deployments")
      + rule.withVerbs(["create","delete","get","list","patch","update","watch",]),

      rule.withApiGroups(["","coordination.k8s.io"])
      + rule.withResources(["configmaps","leases"])
      + rule.withVerbs(["create","delete","get","list","patch","update","watch",]),
  ]),

  clusterRoleBinding: crb.new(self._config.name)
  + crb.bindRole(self.clusterRole)
  + util.bindSubject(self.serviceAccount),

  manifests+:: [
    self.clusterRole,
    self.clusterRoleAggregate,
    self.clusterRoleBinding,
  ]
}
