var ivsaApp = angular.module('ivsaApp', ['ui.bootstrap']);


// Define the `PhoneListController` controller on the `phonecatApp` module
ivsaApp.controller('ApplicationRegistrationController', function ApplicationRegistrationController($scope, $http, $window, $filter) {
   
                   
       $scope.vm = {};
//       $scope.birthday = { opened: false };
       $scope.isLoading = false;
    
       
       $scope.submit = function() {
            var data = {  registration_data:  $scope.vm };
//            $scope.isLoading = true;
                   var bday = data.registration_data.personal_information.birth_date;
                   var formattedBday = $filter('date')(bday, "dd/MM/yyyy");
                   data.registration_data.personal_information.birth_date = formattedBday;
            console.log(JSON.stringify(data));
//            $http.post("/register", JSON.stringify(data))
//            .then(function success(data) {
//                    $scope.isLoading = false;
//                    $window.location.href = "/register";
//                    console.log("success registration: ", data);
//                  
//            }, function failed(error) {
//                  $scope.isLoading = false;
//                  console.log("failed: ", error);
//            });
       }
});
