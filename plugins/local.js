const jsonmergepatch = require('json-merge-patch');

module.exports = {

  id: 'local',

  preprocessors: {
    oas3: {
      'merge-schemas': MergeSchemas
    }
  }

};

function MergeSchemas() {
  const trigger = 'x-mergeSchemas';
  return {
    Schema: {
      leave(node, ctx) {
        if (!node[trigger]) {
          return;
        }
        var schemas = node[trigger];
        if (!Array.isArray(schemas)) {
          return ctx.report({
            message: "Argument should be an array of schemas",
            location: ctx.location.child(trigger)
          });
        }
        let merged = null;
        for (index = schemas.length - 1; index >= 0; --index) {
          let schema = schemas[index];
          if (typeof schema !== 'object') {
            return ctx.report({
              message: "Non-object value",
              location: ctx.location.child(trigger).child(index)
            });
          }
          if (schema.$ref && typeof schema.$ref === 'string') {
            schema = ctx.resolve(schema).node;
          }
          merged = jsonmergepatch.apply(merged, schema);
          console.log(merged);
        };
        Object.assign(node, merged);
        delete node[trigger];
      }
    }
  }
}
