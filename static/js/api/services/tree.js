angular
    .module("pustefix.api")
    .factory("$tree", ["$http", "$q", "API_PATH", function ($http, $q, API_PATH) {

        return {
            get: function () {

                var deferred = $q.defer();

                $http
                    .get(API_PATH)
                    .success(function (response) {
                        deferred.resolve(response);
                    })
                    .error(function (response) {
                        deferred.reject(response);
                    });

                return deferred.promise;
            }
        };
    }]);