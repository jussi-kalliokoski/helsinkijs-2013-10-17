angular.module("ourApp").config([
    "$routeProvider",
    "SLIDE_COUNT",
function (
    $routeProvider,
    SLIDE_COUNT
) {
    "use strict";

    _.forEach(_.range(SLIDE_COUNT), function (slideIndex) {
        $routeProvider.when("/slides/" + slideIndex, {
            controller: "SlideCtrl",
            templateUrl: slideIndex + ".html"
        });
    });

    $routeProvider.otherwise({
        redirectTo: "/slides/0"
    });
}]);
