'use strict';

export const classConst = (cls, name, value) => {
  return Object.defineProperty(cls, name, {value: value, writable : false, enumerable : true, configurable : false});
}
