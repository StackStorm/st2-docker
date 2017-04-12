'use strict';
angular.module('main')
  .constant('st2Config', {

    hosts: [{
      name: 'StackStorm',
      url: 'https://localhost/api',
      auth: 'https://localhost/auth',
    }]

  });
