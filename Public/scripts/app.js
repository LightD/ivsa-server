var ivsaApp = angular.module('ivsaApp', ['ui.bootstrap']);

ivsaApp.directive("autoOpen", ["$parse", function($parse) {
                           return {
                           link: function(scope, iElement, iAttrs) {
                           var isolatedScope = iElement.isolateScope();
                           iElement.on("focus", function() {
                                       isolatedScope.$apply(function() {
                                                            $parse("isOpen").assign(isolatedScope, "true");
                                                            });
                                       });
                           }
                           };
                           }]);

ivsaApp.service('modalService', ['$uibModal',
// NB: For Angular-bootstrap 0.14.0 or later, use $uibModal above instead of $uibModal
function ($uibModal) {

    var modalDefaults = {
        backdrop: true,
        keyboard: true,
        modalFade: true,
        templateUrl: '/scripts/partials/confirmation_modal.html'
    };

    var modalOptions = {
        closeButtonText: 'Close',
        actionButtonText: 'OK',
        headerText: 'Proceed?',
        bodyText: 'Perform this action?'
    };

    this.showModal = function (customModalDefaults, customModalOptions) {
        if (!customModalDefaults) customModalDefaults = {};
        customModalDefaults.backdrop = 'static';
        return this.show(customModalDefaults, customModalOptions);
    };

    this.show = function (customModalDefaults, customModalOptions) {
        //Create temp objects to work with since we're in a singleton service
        var tempModalDefaults = {};
        var tempModalOptions = {};

        //Map angular-ui modal custom defaults to modal defaults defined in service
        angular.extend(tempModalDefaults, modalDefaults, customModalDefaults);

        //Map modal.html $scope custom properties to defaults defined in service
        angular.extend(tempModalOptions, modalOptions, customModalOptions);

        if (!tempModalDefaults.controller) {
            tempModalDefaults.controller = function ($scope, $uibModalInstance) {
                $scope.modalOptions = tempModalOptions;
                $scope.modalOptions.ok = function (result) {
                    $uibModalInstance.close(result);
                };
                $scope.modalOptions.close = function (result) {
                    $uibModalInstance.dismiss('cancel');
                };
            };
        }
        
        tempModalDefaults["size"] = 'sm';
        return $uibModal.open(tempModalDefaults).result;
    };

}]);

// Define the `PhoneListController` controller on the `phonecatApp` module
ivsaApp.controller('ApplicationRegistrationController', function ApplicationRegistrationController($scope, $http, $window, $filter, modalService) {

  var $ctrl = this;
                   
                   
                   $scope.dateOptions = {
                   datepickerMode: 'year'
                   
                   
                   };
                   
  $scope.vm = { personal_information: {
    first_name: "",
    middle_name: "",
    surname: "",
    name_tag: "",
    birth_date: "13/4/1993",
    sex: 1,
    study_year: "",
    nationality: "",
    residency_country: "",
    passport_number: ""
    },
    contact_details: {
      address: "",
      city: "",
      post_code: "",
      state: "",
      country: "",
      phone_num: ""
    },
    emergency_contact: {
      name: "",
      association: "",
      phone_num: "",
      email: ""
    },
    ivsa_chapter: {
      name: "",
      faculty: "",
      university_address: "",
      city: "",
      post_code: "",
      state: "",
      country: "",
      position: ""
    },
    event_info: {
      vegetarian: 0,
      comments: "",
      food_allergies: "",
      chronic_disease: "",
      medicine_allergies: "",
      medical_needs: "",
      tshirt_size: "M (medium)"
    },
    attending_postcongress: 0,
    why_you: ""};

    $scope.isLoading = false;


    $scope.submit = function() {

      var modalOptions = {
       closeButtonText: 'Cancel',
       actionButtonText: 'Submit',
       headerText: 'Confirm',
       bodyText: 'Are you sure you want to submit this form?'
     };

     modalService.showModal({}, modalOptions)
     .then(function (result) {
           var data = {  registration_data:  $scope.vm };
           $scope.isLoading = true;
           var bday = data.registration_data.personal_information.birth_date;
           var formattedBday = $filter('date')(bday, "dd/MM/yyyy");
           data.registration_data.personal_information.birth_date = formattedBday;
           console.log(JSON.stringify(data));
           $http.post("/register", JSON.stringify(data))
           .then(function success(data) {
             $scope.isLoading = false;
             $window.location.href = "/register";
             console.log("success registration: ", data);
          
           }, function failed(error) {
             $scope.isLoading = false;
             console.log("failed: ", error);
           });
     });


    }
  });
