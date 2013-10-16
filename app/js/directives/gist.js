angular.module("ourApp").directive("gist", [
function (
) {
    "use strict";

    return {
        restrict: "A",
        replace: true,
        templateUrl: "gist.html",
        scope: {
            gist: "@"
        }
    };
}]);
