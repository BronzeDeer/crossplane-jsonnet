local test = import "./vendor/github.com/yugui/jsonnetunit/jsonnetunit/test.libsonnet";

local cp = import "../../main.libsonnet";

local enumerate(arr) = [
  {key: i, value:arr[i]}
  for i in std.range(0,std.length(arr)-1)
];

local nsTests = {
      local this = self,
      local ns = self.sut._config.namespace,
      sut:: cp.new("test"),
      baseName::"testDefaultNamespace",
      tests: {
        [ this.baseName+"_"+ x.key]: {
          actual: x.value,
          expectThat: {
              actual: error "should be overriden",
              # Sadly, we have no way of distinguishing which kinds are namespace scoped
              # So we might miss some namespaced resources not having a namespace set at all
              result: !std.objectHas(self.actual.metadata,"namespace") || self.actual.metadata.namespace == ns,
              description: 'expect manifest to have no namespace or namespace="%s"' % ns,
            }
        }
        for x in enumerate(self.sut.flatten())
      }
};

test.suite(
    nsTests.tests
    + (
      nsTests {
        sut +:: cp.withNamespace("foo"),
        baseName:: "testWithNamespace",
      }
    ).tests
) {
  //Patch thatMatcher to format complex failing values better
  matchers+:: {
    expectThat +:{
      matcher: function(actual,expected) super.matcher(actual,expected){
        positiveMessage: 'Expected ' + std.manifestJson(actual) + ' to satisfy ' + self.description,
      }
    }
  }
}
