/*
SCORM API wrapper (v1.1.3) by Philip Hutchison, February 2008 (http://pipwerks.com).
This wrapper is designed to work with both SCORM 1.2 and SCORM 2004.

Based on APIWrapper.js, created by the ADL and Concurrent Technologies
Corporation, distributed by the ADL (http://www.adlnet.gov/scorm).

SCORM.API.find() and SCORM.API.get() functions based on ADL code,
modified by Mike Rustici (http://www.scorm.com/resources/apifinder/SCORMAPIFinder.htm),
further modified by Philip Hutchison
*/


//Define the SCORM object
var SCORM = {
    version:    "",                //Store SCORM version. This is auto-populated by SCORM.API.find
    API:        {                  //Create API child object
					handle:   null,
					isFound:  false
                },
    connection: {                  //Create connection child object
					isActive: false
                },
    data:       {},                //Create data child object
    debug:      {
					isActive: true //Enable (true) or disable (false) for debug mode
                },                 //Create debug child object
    UTILS:      {}                 //Create utility object for 'helper' functions
};


/*
SCORM.isAvailable is a simple function to allow Flash ExternalInterface
to confirm presence of JS wrapper before attempting any LMS communication.

Parameters: none
Returns:    Boolean (true)
*/
SCORM.isAvailable = function(){
	return true;     
};

// ------------------------------------------------------------------------- //
// --- SCORM.API functions ------------------------------------------------- //
// ------------------------------------------------------------------------- //

/*
SCORM.API.find(window) looks for an object named API in parent and opener windows

Parameters: window (the browser window object).
Returns:    Object if API is found, null if no API found
*/

SCORM.API.find = function(win){

    var findAttempts = 0,
        findAttemptLimit = 500;

    while ((!win.API && !win.API_1484_11) &&
           (win.parent) &&
           (win.parent != win) &&
           (findAttempts <= findAttemptLimit) ){

                findAttempts++; 
                win = win.parent;

    }

    if(win.API_1484_11) {

        SCORM.version = "2004";
        SCORM.debug.displayInfo("SCORM.API.version: " +SCORM.version);
        return win.API_1484_11;
     
    } else if(win.API){
          
        SCORM.version = "1.2";
        SCORM.debug.displayInfo("SCORM.API.version: " +SCORM.version);
        return win.API;
     
    }
     
          
    SCORM.debug.displayInfo("SCORM.API.find: Error finding API. \n"
                           +"Find attempts: " +findAttempts +". \n"
                           +"Find attempt limit: " +findAttemptLimit);
     
    return null;

};


/*
SCORM.API.get() looks for an object named API, first in the current window's
frame hierarchy and then, if necessary, in the current window's opener window
hierarchy (if there is an opener window).

Parameters:  None. 
Returns:     Object if API found, null if no API found
*/

SCORM.API.get = function(){

    var API = null; 
     
    if (window.parent && window.parent != window){ 
    
        API = SCORM.API.find(window.parent); 
        
    } 
     
    if (!API && window.top.opener){ 
    
        API = SCORM.API.find(window.top.opener); 
        
    } 
     
    if(API){  
    
        SCORM.API.isFound = true;
        
    } else {
    
        SCORM.debug.displayInfo("SCORM.API.get failed: Can't find the API!");
                               
    }
     
    return API;

};
          

/*
SCORM.API.getHandle() returns the handle to API object if it was previously set

Parameters:  None.
Returns:     Object (value contained by the SCORM.API.handle variable).
*/

SCORM.API.getHandle = function() {
     
    if (!SCORM.API.handle && !SCORM.API.isFound){
     
        SCORM.API.handle = SCORM.API.get();
     
    }
     
    return SCORM.API.handle;

};
     
     
// ------------------------------------------------------------------------- //
// --- SCORM.connection functions ------------------------------------------ //
// ------------------------------------------------------------------------- //

/*
SCORM.connection.initialize() is used to tell the LMS to initiate the communication session.

Parameters:  None
Returns:     Boolean
*/

SCORM.connection.initialize = function(){
               
    SCORM.debug.displayInfo("SCORM.connection.initialize called.");

    var result = false;

    if(!SCORM.connection.isActive){

        var API = SCORM.API.getHandle(),
            errorCode = 0;
          
        if(API){
               
            if(SCORM.version == "1.2"){
  
            	result = SCORM.UTILS.StringToBoolean(API.LMSInitialize(""));
            
            } else if (SCORM.version == "2004") {
            
                result = SCORM.UTILS.StringToBoolean(API.Initialize(""));
            
            }
            
			
            if (result){
            
				//Double-check that connection is active and
				//working before returning 'true' boolean
				errorCode = SCORM.debug.getCode();
				
				if(errorCode !== null && errorCode === 0){
					
	                SCORM.connection.isActive = true;
				
				} else {
					
					result = false;
					SCORM.debug.displayInfo("SCORM.connection.initialize failed. \n"
										   +"Error code: " +errorCode +" \n"
										   +"Error info: " +SCORM.debug.getInfo(errorCode));
					
				}
                
            } else {
				
				errorCode = SCORM.debug.getCode();
            
				if(errorCode !== null && errorCode !== 0){

					SCORM.debug.displayInfo("SCORM.connection.initialize failed. \n"
										   +"Error code: " +errorCode +" \n"
										   +"Error info: " +SCORM.debug.getInfo(errorCode));
				} else {
					
					SCORM.debug.displayInfo("SCORM.connection.initialize failed. No response from server.");
				
				}
            }
              
        } else {
          
            SCORM.debug.displayInfo("SCORM.connection.initialize failed: API is null.");
     
        }
          
    } else {
     
          SCORM.debug.displayInfo("SCORM.connection.initialize aborted: Connection already active.");
          
     }

     return result;

};


/*
SCORM.connection.terminate() is used to tell the LMS to terminate the communication session

Parameters:  None
Returns:     Boolean
*/

SCORM.connection.terminate = function(){
     
    var result = false;

    if(SCORM.connection.isActive){
          
        var API = SCORM.API.getHandle(),
            errorCode = 0;
               
        if(API){
     
            if(SCORM.version == "1.2"){
            
                result = SCORM.UTILS.StringToBoolean(API.LMSFinish(""));
                
            } else if (SCORM.version == "2004") {
            
                result = SCORM.UTILS.StringToBoolean(API.Terminate(""));
            
            }
               
            if (result){
                    
                SCORM.connection.isActive = false;
               
            } else {
                    
                errorCode = SCORM.debug.getCode();
                    
                SCORM.debug.displayInfo("SCORM.connection.terminate failed. \n"
                                       +"Error code: " +errorCode +" \n"
                                       +"Error info: " +SCORM.debug.getInfo(errorCode));
   
            }
               
        } else {
          
            SCORM.debug.displayInfo("SCORM.connection.terminate failed: API is null.");
     
        }
          
    } else {
     
        SCORM.debug.displayInfo("SCORM.connection.terminate aborted: Connection already terminated.");

    }

    return result;

};


// ------------------------------------------------------------------------- //
// --- SCORM.data functions ------------------------------------------------ //
// ------------------------------------------------------------------------- //

/*
SCORM.data.get(parameter) requests information from the LMS.

Parameter: parameter (string, name of the data model defined category or element, e.g. cmi.core.learner_id)
Returns:   string (the value presently assigned to the specified data model element)
*/

SCORM.data.get = function(parameter){

    var value = null;
     
    if (SCORM.connection.isActive){
          
        var API = SCORM.API.getHandle(),
            errorCode = 0;
          
          if(API){
               
            if(SCORM.version == "1.2"){
            
                value = API.LMSGetValue(parameter);
                
            } else if (SCORM.version == "2004") {
               
                value = API.GetValue(parameter);
                    
            }
               
            errorCode = SCORM.debug.getCode();
               
            //GetValue returns an empty string on errors
            //Double-check errorCode to make sure empty string
            //is really an error and not field value
            if (value === "" && errorCode !== 0){
   
                SCORM.debug.displayInfo("SCORM.data.get(" +parameter +") failed. \n"
                                       +"Error code: " +errorCode +"\n"
                                       +"Error info: " +SCORM.debug.getInfo(errorCode));
               
            }
          
        } else {
          
            SCORM.debug.displayInfo("SCORM.data.get(" +parameter +") failed: API is null.");
     
        }
          
    } else {
     
        SCORM.debug.displayInfo("SCORM.data.get(" +parameter +") failed: API connection is inactive.");

    }
    
	SCORM.debug.displayInfo("SCORM.data.get(" +parameter +"): " +value);

    return String(value);

};
          
          
/*
SCORM.data.set() is used to tell the LMS to assign the value to the named data model element.

Parameters: parameter (string). Parameter of the data model defined category or element value
            value (string). The value that the named element or category will be assigned
Returns:    Boolean
*/

SCORM.data.set = function(parameter, value){

    var result = false;
     
    if (SCORM.connection.isActive){
          
        var API = SCORM.API.getHandle(),
            errorCode = 0;
               
        if (API){
               
            if(SCORM.version == "1.2"){
            
                result = SCORM.UTILS.StringToBoolean(API.LMSSetValue(parameter, value));
                
            } else if (SCORM.version == "2004") {
            
                result = SCORM.UTILS.StringToBoolean(API.SetValue(parameter, value));
                    
            }

            if(!result){

                SCORM.debug.displayInfo("SCORM.data.set(" +parameter +") failed. \n"
                                       +"Error code: " +errorCode +". \n"
                                       +"Error info: " +SCORM.debug.getInfo(errorCode));

            }
               
        } else {
          
            SCORM.debug.displayInfo("SCORM.data.set(" +parameter +") failed: API is null.");
     
        }
          
    } else {
     
        SCORM.debug.displayInfo("SCORM.data.set(" +parameter +") failed: API connection is inactive.");

    }
     
    return result;

};
          

/*
SCORM.data.save() instructs the LMS to persist all data to this point in the session

Parameters: None
Returns:    Boolean
*/

SCORM.data.save = function(){

    var result = false;

    if(SCORM.connection.isActive){

        var API = SCORM.API.getHandle();
          
        if (API){
          
            if(SCORM.version == "1.2"){
            
                result = SCORM.UTILS.StringToBoolean(API.LMSCommit(""));
                
            } else if (SCORM.version == "2004") {
            
                result = SCORM.UTILS.StringToBoolean(API.Commit(""));
                    
            }
          
        } else {
          
            SCORM.debug.displayInfo("SCORM.data.save failed: API is null.");
     
        }
          
    } else {
     
        SCORM.debug.displayInfo("SCORM.data.save failed: API connection is inactive.");

    }

    return result;

};


// ------------------------------------------------------------------------- //
// --- SCORM.debug functions ----------------------------------------------- //
// ------------------------------------------------------------------------- //

/*
SCORM.debug.getCode requests the error code for the current error state from the LMS

Parameters: None
Returns:    Integer (the last error code).
*/

SCORM.debug.getCode = function(){
     
    var API = SCORM.API.getHandle(),
        code = 0;

    if(API){

        if(SCORM.version == "1.2"){
        
            code = parseInt(API.LMSGetLastError(), 10);
               
        } else if (SCORM.version == "2004") {
          
            code = parseInt(API.GetLastError(), 10);
               
        }
     
    } else {
     
        SCORM.debug.displayInfo("SCORM.debug.getCode failed: API is null.");

    }
     
    return code;
    
};


/*
SCORM.debug.getInfo() "is used by a SCO to request the textual description
for the error code specified by the value of [errorCode]."

Parameters: errorCode (integer).  
Returns:    String.
*/

SCORM.debug.getInfo = function(errorCode){
     
    var API = SCORM.API.getHandle(),
        result = "";
     
    if(API){
          
        if(SCORM.version == "1.2"){
      
            result = API.LMSGetErrorString(errorCode.toString());
               
        } else if (SCORM.version == "2004") {
          
            result = API.GetErrorString(errorCode.toString());
               
        }
     
    } else {
     
        SCORM.debug.displayInfo("SCORM.debug.getInfo failed: API is null.");

    }
     
    return String(result);

};


/*
SCORM.debug.getDiagnosticInfo "exists for LMS specific use. It allows the LMS
to define additional diagnostic information through the API Instance."

Parameters: errorCode (integer).  
Returns:    String (Additional diagnostic information about the given error code).
*/

SCORM.debug.getDiagnosticInfo = function(errorCode){

    var API = SCORM.API.getHandle(),
        result = "";

    if (API){

        if(SCORM.version == "1.2"){
      
            result = API.LMSGetDiagnostic(errorCode);
               
        } else if (SCORM.version == "2004") {
          
            result = API.GetDiagnostic(errorCode);
               
        }
     
    } else {
     
        SCORM.debug.displayInfo("SCORM.debug.getDiagnosticInfo failed: API is null.");

    }

    return String(result);

};


/*
SCORM.debug.displayInfo() displays error messages when in debug mode.

Parameters: msg (string)  
Return:     None
*/

SCORM.debug.displayInfo = function(msg, htmlclass){

     if(SCORM.debug.isActive){
     
		// alert(msg);
		
		//Feel free to replace the default 'alert' with custom DOM calls such as:
		var debugDiv = document.getElementById("debugText");
		if(debugDiv){
			if(htmlclass){
				msg = "<span class='" +htmlclass +"'>" +msg +"</span>";	
			}
			debugDiv.innerHTML += "<br/>" +msg;
		}
		
		//Firefox users can use the 'Firebug' extension's console.
		if(window.console && console.firebug){
			console.log(msg);
		}
		
     }
};


// ------------------------------------------------------------------------- //
// --- SCORM.UTILS functions ----------------------------------------------- //
// ------------------------------------------------------------------------- //

/*
Most values returned from the API are the strings "true" and "false".
SCORM.UTILS.StringToBoolean() converts these strings back into valid booleans.

Parameters: String
Returns:    Boolean
*/
SCORM.UTILS.StringToBoolean = function(string){

     switch(string.toLowerCase()) {
          case "true":
          case "yes":
          case "1":
          return true;
          
          case "false":
          case "no":
          case "0":
          return false; 
          
          default: return Boolean(string);
     }     
};

// ======================
// = other random stuff =
// ======================
function resizeWindow(w,h) 
{
	ie7Width = w+12;
	ie7Height = h+95;
	
	ffWidth = w+2;
	ffHeight = h+15;
	
	browser = navigator.appName;
	browserVersion = parseInt(navigator.appVersion);
	
	if (browserVersion > 3) {
		if (browser == "Netscape") {
			top.innerWidth= ffWidth;
			top.innerHeight=ffHeight;
		}
		else {
			top.resizeTo(ie7Width,ie7Height);
		}
	}
}

function closeCourse() 
{
	// set the confirm msg based on lesson_status
	msg = "";
	if (SCORM.data.get("cmi.core.lesson_status") == "incomplete") 
	{
		msg = "You have not yet completed this course. If you exit now, the course will be marked as incomplete. Are you sure you want to exit?";
		// confirm close
		if (confirm(msg)) 
		{
			SCORM.data.save();
			SCORM.connection.terminate();
			window.top.close();
		}
	}
	else
	{
		SCORM.data.save();
		SCORM.connection.terminate();
		window.top.close();
	}
}