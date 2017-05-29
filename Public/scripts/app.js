var ivsaApp = angular.module('ivsaApp', ['ui.bootstrap']);


// ------------------------------------------------------------------
// Utility functions for parsing in getDateFromFormat()
// ------------------------------------------------------------------
function _isInteger(val) {
    var digits="1234567890";
    for (var i=0; i < val.length; i++) {
        if (digits.indexOf(val.charAt(i))==-1) { return false; }
    }
    return true;
}
function _getInt(str,i,minlength,maxlength) {
    for (var x=maxlength; x>=minlength; x--) {
        var token=str.substring(i,i+x);
        if (token.length < minlength) { return null; }
        if (_isInteger(token)) { return token; }
    }
    return null;
}

// ------------------------------------------------------------------
// getDateFromFormat( date_string , format_string )
//
// This function takes a date string and a format string. It matches
// If the date string matches the format string, it returns the
// getTime() of the date. If it does not match, it returns 0.
// ------------------------------------------------------------------
function getDateFromFormat(val,format) {
    val=val+"";
    format=format+"";
    var i_val=0;
    var i_format=0;
    var c="";
    var token="";
    var token2="";
    var x,y;
    var now=new Date();
    var year=now.getYear();
    var month=now.getMonth()+1;
    var date=1;
    var hh=now.getHours();
    var mm=now.getMinutes();
    var ss=now.getSeconds();
    var ampm="";
    
    while (i_format < format.length) {
        // Get next token from format string
        c=format.charAt(i_format);
        token="";
        while ((format.charAt(i_format)==c) && (i_format < format.length)) {
            token += format.charAt(i_format++);
        }
        // Extract contents of value based on format token
        if (token=="yyyy" || token=="yy" || token=="y") {
            if (token=="yyyy") { x=4;y=4; }
            if (token=="yy")   { x=2;y=2; }
            if (token=="y")    { x=2;y=4; }
            year=_getInt(val,i_val,x,y);
            if (year==null) { return 0; }
            i_val += year.length;
            if (year.length==2) {
                if (year > 70) { year=1900+(year-0); }
                else { year=2000+(year-0); }
            }
        }
        else if (token=="MMM"||token=="NNN"){
            month=0;
            for (var i=0; i<MONTH_NAMES.length; i++) {
                var month_name=MONTH_NAMES[i];
                if (val.substring(i_val,i_val+month_name.length).toLowerCase()==month_name.toLowerCase()) {
                    if (token=="MMM"||(token=="NNN"&&i>11)) {
                        month=i+1;
                        if (month>12) { month -= 12; }
                        i_val += month_name.length;
                        break;
                    }
                }
            }
            if ((month < 1)||(month>12)){return 0;}
        }
        else if (token=="EE"||token=="E"){
            for (var i=0; i<DAY_NAMES.length; i++) {
                var day_name=DAY_NAMES[i];
                if (val.substring(i_val,i_val+day_name.length).toLowerCase()==day_name.toLowerCase()) {
                    i_val += day_name.length;
                    break;
                }
            }
        }
        else if (token=="MM"||token=="M") {
            month=_getInt(val,i_val,token.length,2);
            if(month==null||(month<1)||(month>12)){return 0;}
            i_val+=month.length;}
        else if (token=="dd"||token=="d") {
            date=_getInt(val,i_val,token.length,2);
            if(date==null||(date<1)||(date>31)){return 0;}
            i_val+=date.length;}
        else if (token=="hh"||token=="h") {
            hh=_getInt(val,i_val,token.length,2);
            if(hh==null||(hh<1)||(hh>12)){return 0;}
            i_val+=hh.length;}
        else if (token=="HH"||token=="H") {
            hh=_getInt(val,i_val,token.length,2);
            if(hh==null||(hh<0)||(hh>23)){return 0;}
            i_val+=hh.length;}
        else if (token=="KK"||token=="K") {
            hh=_getInt(val,i_val,token.length,2);
            if(hh==null||(hh<0)||(hh>11)){return 0;}
            i_val+=hh.length;}
        else if (token=="kk"||token=="k") {
            hh=_getInt(val,i_val,token.length,2);
            if(hh==null||(hh<1)||(hh>24)){return 0;}
            i_val+=hh.length;hh--;}
        else if (token=="mm"||token=="m") {
            mm=_getInt(val,i_val,token.length,2);
            if(mm==null||(mm<0)||(mm>59)){return 0;}
            i_val+=mm.length;}
        else if (token=="ss"||token=="s") {
            ss=_getInt(val,i_val,token.length,2);
            if(ss==null||(ss<0)||(ss>59)){return 0;}
            i_val+=ss.length;}
        else if (token=="a") {
            if (val.substring(i_val,i_val+2).toLowerCase()=="am") {ampm="AM";}
            else if (val.substring(i_val,i_val+2).toLowerCase()=="pm") {ampm="PM";}
            else {return 0;}
            i_val+=2;}
        else {
            if (val.substring(i_val,i_val+token.length)!=token) {return 0;}
            else {i_val+=token.length;}
        }
    }
    // If there are any trailing characters left in the value, it doesn't match
    if (i_val != val.length) { return 0; }
    // Is date valid for month?
    if (month==2) {
        // Check for leap year
        if ( ( (year%4==0)&&(year%100 != 0) ) || (year%400==0) ) { // leap year
            if (date > 29){ return 0; }
        }
        else { if (date > 28) { return 0; } }
    }
    if ((month==4)||(month==6)||(month==9)||(month==11)) {
        if (date > 30) { return 0; }
    }
    // Correct hours value
    if (hh<12 && ampm=="PM") { hh=hh-0+12; }
    else if (hh>11 && ampm=="AM") { hh-=12; }
    var newdate=new Date(year,month-1,date,hh,mm,ss);
    return newdate;
}


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
    passport_number: "",
    student_id: ""
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

  $scope.editableJSON = {};

  $scope.setup = function(token) {

    // var decodedURI = decodeURI(jsonString);
//    var parts = jsonString.split(":");
//    parts.forEach(function(item, index, theArray) {
//			var newItem = decodeURI(item);
//			
//      theArray[index] = newItem;
//    });
//    console.log(parts);
//    parts = parts.join(":");
//    console.log(parts);
//    let json = JSON.parse(parts);
//    console.log(json);
//
//    let wee = eval(jsonString);
//    console.log(wee);
     $scope.isLoading = true;
                   
     $http.get("/api/me", { headers: { "Authorization": "Bearer " +  token} })
     .then(function success(object) {
          $scope.isLoading = false;
          console.log("got me ", object.data.registration_details);
           
           var regd = object.data.registration_details;
           regd.personal_information.sex = ((regd.personal_information.sex) ? 1 : 0);
           regd.event_info.vegetarian = ((regd.event_info.vegetarian) ? 1 : 0);
           regd.attending_postcongress = ((regd.attending_postcongress) ? 1 : 0);
           regd.personal_information.birth_date = getDateFromFormat(regd.personal_information.birth_date, "dd/MM/yyyy")
           
          $scope.vm = regd;
      }, function failed(error) {
          $scope.isLoading = false;
          console.log("failed: ", error);
      });
  }


});
