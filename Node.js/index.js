const _ = require('lodash');

console.log("Starting the application...");

// Simple usage of lodash to prove it's loaded
const object = { 'a': 1 };
const other = { 'b': 2 };
const result = _.merge(object, other);

console.log("Lodash merge result:", result);
console.log("App finished successfully.");
