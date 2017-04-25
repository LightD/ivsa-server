angular.module('ivsaAdmin').controller('WaitlistController', function WaitlistController($scope, $http, $window, $filter, modalService) {

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
	      $http.post("/api/admin/confirmReject/" + userID, null, { headers: { "Authorization": "Bearer " +  $scope.token } })
	      .then(function success(data) {
	        $scope.isLoading = false;
	        $scope.applicants.splice(index, 1);

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
