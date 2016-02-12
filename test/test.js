/*eslint-env es6*/
// ES6 generator function

var anonymousGeneratorFunctionExpression = function* (arg1, arg2) {

};

var namedGeneratorFunctionExpression = function* namedGenerator(arg1, arg2) {

};

var namedGeneratorFunctionExpressionWeirdSpacing = function    * namedGenerator(arg1, arg2) {

};


var anonymousFunctionExpression = function (arg1, arg2) {

};

var namedFunctionExpression = function namedExpression(el, $jq) {

}

function namedFunctionDeclaration(_a2, err) {

}

function* namedGeneratorFunc(data) {

}

const namespace = {

  toString() { // ES6 style dec

  },

};

namespace.x0 = function (e) {

}; // anonymous method

namespace.x1 = (e) => {

}; // anonymous arrow method

namespace.x2 = function* (e) {

}; // anonymous method generator


namespace.weirdx2 = function *(e) {

}; // anonymous method generator with weird spacing

namespace.x3 = function testing(e) {

}; // named method

namespace.x4 = function* testgen(description) {

}; // named method generator

namespace.x5 = () => 'hi'; // arrow function with auto returning body

// arrow function, spread, with function body
const xxx = (...args) => {
  return 'bye';
} 

// arrow function, spread, with auto returning body
const yyy = (...args) => 'hello';

// arrow function, spread, with auto returning object
const zzz = (...args) => ({ key: 'value' });

// arrow function with no arg parens
const aaa = v => 'vvv';

const bbb = v => ({ item: 'vvv' });

const ccc = v => {
  return v || false;
};

function setnotasetter(x) {

}

var setnotasetter = function setnotasetter(x) {

};

class ExampleClass {
  somefunc(somearg) {

  }

  get getterfunc() {

  }

  setnotasetter(x) {

  }

  set setter(value) {

  }

  static staticfunc(staticarg) {

  }
}

