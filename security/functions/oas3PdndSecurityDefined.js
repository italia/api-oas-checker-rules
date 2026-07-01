const HTTP_METHODS = ["get", "put", "post", "delete", "options", "head", "patch", "trace"];

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function hasOwnSecurityRequirement(node) {
  if (!isObject(node) || !Object.prototype.hasOwnProperty.call(node, "security")) {
    return false;
  }

  const security = node.security;

  // In OpenAPI, security: [] explicitly removes inherited security. Also, an
  // empty Security Requirement Object ({}) means anonymous access is supported,
  // so it is not counted here as an effective security requirement.
  if (!Array.isArray(security) || security.length === 0) {
    return false;
  }

  return security.some((requirement) => isObject(requirement) && Object.keys(requirement).length > 0);
}

function getOperations(document) {
  const operations = [];

  if (!isObject(document.paths)) {
    return operations;
  }

  for (const [pathName, pathItem] of Object.entries(document.paths)) {
    if (!isObject(pathItem)) {
      continue;
    }

    for (const method of HTTP_METHODS) {
      const operation = pathItem[method];
      if (!isObject(operation)) {
        continue;
      }

      operations.push({
        pathName,
        method,
        operation,
      });
    }
  }

  return operations;
}

export default function oas3PdndSecurityDefined(document) {
  if (!isObject(document)) {
    return;
  }

  // If root-level security exists, every operation inherits it unless it
  // explicitly overrides it. This rule only covers the requested missing-root
  // and missing-operation cases.
  if (hasOwnSecurityRequirement(document)) {
    return;
  }

  const operations = getOperations(document);
  const unsecuredOperations = operations.filter(({ operation }) => !hasOwnSecurityRequirement(operation));
  const securedOperationCount = operations.length - unsecuredOperations.length;

  // Global case: no root-level security and no operation-level security.
  if (operations.length === 0 || securedOperationCount === 0) {
    return [
      {
        message:
          "No `security` requirement was found at the root level and no operation declares its own. All endpoints are effectively exposed as public.",
        path: ["security"],
      },
    ];
  }

  // Local case: at least one operation has security, but some operations do not.
  return unsecuredOperations.map(({ pathName, method }) => ({
    message: `No \`security\` requirement was found at the root level and operation "${method.toUpperCase()} ${pathName}" does not declare its own.`,
    path: ["paths", pathName, method, "security"],
  }));
}
