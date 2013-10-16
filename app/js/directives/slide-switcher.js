angular.module("ourApp").directive("slideSwitcher", [
function (
) {
    "use strict";

    return {
        restrict: "A",
        link: function (scope, element, attributes) {
            element.bind("keyup", function (event) {
                // left arrow
                if ( event.which === 37 ) {
                    scope.slideCtrl.previous();
                }

                // right arrow
                if ( event.which === 39 ) {
                    scope.slideCtrl.next();
                }
            });
        }
    };
}]);
