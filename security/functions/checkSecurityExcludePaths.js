"use strict";

/**
 * Custom Spectral function to validate OpenAPI security requirements with path exclusions.
 * This function ensures that API operations are properly secured while allowing specific paths
 * to be excluded from security requirements (e.g., public health check endpoints).
 */

/**
 * Helper function to check if a value is an object
 * @param {any} obj - Value to check
 * @returns {boolean} True if the value is a non-null object
 */
function isObject(obj) {
    return obj !== null && typeof obj === 'object';
}

// Standard HTTP methods that can be defined in OpenAPI operations
const httpMethods = ["get", "head", "post", "put", "patch", "delete", "options", "trace"];

/**
 * Generator function to iterate through all operations in an OpenAPI paths object
 * @param {Object} paths - The OpenAPI paths object
 * @yields {Object} Object containing path and operation method for each API operation
 */
function* getAllOperations(paths) {
    if (!isObject(paths)) {
        return;
    }

    // Reuse the same result object for performance
    const result = {path: "", operation: ""};

    // Iterate through each path in the OpenAPI spec
    for (const pathKey of Object.keys(paths)) {
        const pathItem = paths[pathKey];
        if (isObject(pathItem)) {
            result.path = pathKey;

            // Check each HTTP method for this path
            for (const method of Object.keys(pathItem)) {
                // Only process valid HTTP methods that have operation objects
                if (isObject(pathItem[method]) && httpMethods.includes(method)) {
                    result.operation = method;
                    yield result;
                }
            }
        }
    }
}

/**
 * Main validation function that checks security requirements for OpenAPI operations
 * @param {Object} globalSecurity - The complete OpenAPI document with global security settings
 * @param {Object} options - Configuration options for the security check
 * @param {string[]} options.excludePaths - Array of paths to exclude from security validation
 * @param {string[]} options.methods - Array of HTTP methods to validate (if empty, validates all)
 * @param {boolean} options.nullable - Whether empty security arrays are allowed
 * @param {string[]} options.schemesPath - Path to security schemes in the document
 * @returns {Array} Array of error objects for operations that violate security requirements
 */
function checkSecurityExcludePaths(globalSecurity, options) {
    const errorList = [];
    const {schemesPath: s, nullable, methods, excludePaths = []} = options;
    const {paths} = globalSecurity;

    // Check each operation in the API
    for (const {path, operation: httpMethod} of getAllOperations(paths)) {
        // Skip paths that are explicitly excluded (e.g., /status endpoint)
        if (excludePaths.includes(path)) {
            continue;
        }

        // Skip HTTP methods not specified in the validation configuration
        if (methods && Array.isArray(methods) && !methods.includes(httpMethod)) {
            continue;
        }

        // Get the security configuration for this specific operation
        let {security: operationSecurity} = paths[path][httpMethod];
        let securityRef = [path, httpMethod];

        // If operation doesn't define security, inherit from global security
        if (operationSecurity === undefined) {
            operationSecurity = globalSecurity.security;
            securityRef = ["$.security"];
        }

        // Check if operation has no security defined at all
        if (!operationSecurity || operationSecurity.length === 0) {
            errorList.push({
                message: `Operation has undefined security scheme in ${securityRef}.`,
                path: ["paths", path, httpMethod, "security", s]
            });
        }

        // Validate each security requirement in the security array
        if (Array.isArray(operationSecurity)) {
            for (const [idx, securityEntry] of operationSecurity.entries()) {
                if (!isObject(securityEntry)) {
                    continue;
                }

                // Get the security scheme names referenced in this requirement
                const securitySchemeIds = Object.keys(securityEntry);

                // Check for empty security objects when nullable is false
                // Empty security object {} means "no authentication required"
                if (securitySchemeIds.length === 0 && nullable === false) {
                    errorList.push({
                        message: `Operation referencing empty security scheme in ${securityRef}.`,
                        path: ["paths", path, httpMethod, "security", idx]
                    });
                }
            }
        }
    }

    return errorList;
}

// Export the function for use in Spectral rulesets
exports.default = checkSecurityExcludePaths;