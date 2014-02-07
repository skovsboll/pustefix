"use strict";

angular
    .module("pustefix", [
        "ui.codemirror",
        "pustefix.api"
    ])
    .controller("PustefixMainController", ["$tree", function ($tree) {

        var pustefix = this,
            successHandler = function (response) {
                pustefix.model = response;
            };

        $tree
            .get()
            .then(successHandler);
    }]);