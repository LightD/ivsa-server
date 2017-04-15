angular.module('ivsaAdmin').controller('WaitlistController', function ApplicantsController($scope, $http, $window, $filter, modalService) {

	  var $ctrl = this;

	  $scope.isLoading = false;
	  $scope.accept = function(userID, index) {
	    console.log("accepting " + userID + " at index " + index);

	    var modalOptions = {
	      closeButtonText: 'Cancel',
	      actionButtonText: 'Accept',
	      headerText: 'Confirm',
	      bodyText: 'Are you sure you want to accept this applicant?'
	    };

	    modalService.showModal({}, modalOptions)
	    .then(function (result) {
	      $scope.isLoading = true;
	      $http.post("/api/admin/accept/" + userID, null, { headers: { "Authorization": "Bearer " +  $scope.token} })
	      .then(function success(data) {
	        $scope.isLoading = false;
	        $scope.applicants.splice(index, 1);

	      }, function failed(error) {
	        $scope.isLoading = false;
	        console.log("failed: ", error);
	      });
	    });

	  }

	  $scope.reject = function(userID, index) {
	    console.log("rejecting " + userID + " at index " + index);

	    var modalOptions = {
	      closeButtonText: 'Cancel',
	      actionButtonText: 'Reject',
	      headerText: 'Confirm',
	      bodyText: 'Are you sure you want to reject this applicant?'
	    };

	    modalService.showModal({}, modalOptions)
	    .then(function (result) {
	      $scope.isLoading = true;
	      $http.post("/api/admin/reject/" + userID, null, { headers: { "Authorization": "Bearer " +  $scope.token } })
	      .then(function success(data) {
	        $scope.isLoading = false;
	        $scope.applicants.splice(index, 1);

	      }, function failed(error) {
	        $scope.isLoading = false;
	        console.log("failed: ", error);
	      });
	    });

	  }

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

	  $scope.applicants = [];
	  $scope.token = "";

	  $scope.setup = function(token) {
	     $scope.isLoading = true;
	     $scope.token = token;

	     $http.get("/api/admin/delegates/accepted", { headers: { "Authorization": "Bearer " +  token} })
	     .then(function success(object) {
	          $scope.isLoading = false;
	          console.log("got users ", object.data);

	          $scope.applicants = $scope.applicants.concat(object.data);
	          console.log("applicants ", $scope.applicants);
	      }, function failed(error) {
	          $scope.isLoading = false;
	          console.log("failed: ", error);
	      });

	     $http.get("/api/admin/delegates/rejected", { headers: { "Authorization": "Bearer " +  token} })
	     .then(function success(object) {
	           $scope.isLoading = false;
	           console.log("got users ", object.data);

	           $scope.applicants = $scope.applicants.concat(object.data);
	           console.log("applicants ", $scope.applicants);
	           }, function failed(error) {
	           $scope.isLoading = false;
	           console.log("failed: ", error);
	        });
	  }


	});
