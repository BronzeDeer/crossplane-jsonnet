{
  bindSubject: function(subject) {
    subjects: [{
      kind: subject.kind,
      name: subject.metadata.name,
      namespace: subject.metadata.namespace,
    }],
  },

  bindSubjectMixin: function(subject) {
    subjects+: self.bindSubject(subject).subjects,
  },


  subject: {
    local base = {
      apiGroup: 'rbac.authorization.k8s.io/v1',
    },

    withGroup(name):: base {
      kind: 'Group',
      name: name,
    },
  },
}
