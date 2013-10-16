angular.module("ourApp").controller("SlideCtrl", [
    "$rootScope",
    "$location",
    "SLIDE_COUNT",
function (
    $rootScope,
    $location,
    SLIDE_COUNT
) {
    "use strict";

    $rootScope.slideCtrl = {
        next: function () {
            this.setIndex(this.getCurrent() + 1);
        },

        previous: function () {
            this.setIndex(this.getCurrent() - 1);
        },

        getCurrent: function () {
            return parseInt(/\d+$/.exec($location.path())[0], 10);
        },

        setIndex: function (slideIndex) {
            if ( !this.isIndexValid(slideIndex) ) return;

            $location.path("/slides/" + slideIndex);
            $rootScope.$apply();
        },

        isIndexValid: function (slideIndex) {
            return slideIndex >= 0 && slideIndex < SLIDE_COUNT;
        }
    };

}]);
