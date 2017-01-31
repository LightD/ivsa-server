var ivsaApp = angular.module('ivsaApp', ['ui.bootstrap']);


// Define the `PhoneListController` controller on the `phonecatApp` module
ivsaApp.controller('ApplicationRegistrationController', function ApplicationRegistrationController($scope, $http, $window, $filter) {


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
              passport_number: ""},
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
            var data = {  registration_data:  $scope.vm };
//            $scope.isLoading = true;
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
       }
});
