'use strict';

export const error   = (text) => $.toast({text: text, heading: 'Oh snap!',        position: 'top-right', loaderBg: '#bf441d', icon: 'error',   hideAfter: 3000, stack: 10});
export const info    = (text) => $.toast({text: text, heading: 'Heads up!',       position: 'top-right', loaderBg: '#3b98b5', icon: 'info',    hideAfter: 3000, stack: 10});
export const warn    = (text) => $.toast({text: text, heading: 'Holy guacamole!', position: 'top-right', loaderBg: '#da8609', icon: 'warning', hideAfter: 3000, stack: 10});
export const success = (text) => $.toast({text: text, heading: 'Well done!',      position: 'top-right', loaderBg: '#5ba035', icon: 'success', hideAfter: 3000, stack: 10});
