local cp = import "../main.libsonnet";

local tests = {
  "namespace set correctly": {
    sut:: cp.new("test"),
    local ns = self.sut._config.namespace,
    expected: [true for _ in self.actual],
    actual: [
      # Sadly, we have no way of distinguishing which kinds are namespace scoped
      # So some namespaced resources might not have a namespace set explicitly at all
      !std.objectHas(m.metadata,"namespace") || m.metadata.namespace == ns
      for m in self.sut.flatten()
    ] + [
      sub.namespace == ns
      for sub in self.sut.clusterRoleBinding.subjects
    ]
  },
  "withNamespace": self["namespace set correctly"] {
    sut+:: cp.withNamespace("foobar")
  }
};

{
  [f]: (tests[f].actual == tests[f].expected)
  for f in std.objectFields(tests)
}
